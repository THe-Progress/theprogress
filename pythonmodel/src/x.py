import re
from transformers import GPT2LMHeadModel, GPT2Tokenizer
import os
from dotenv import load_dotenv
load_dotenv()
print("Loading model...")
# model_directory = r'C:\Users\suman\x\theprogress\pythonmodel\src\progressgpt2'
model_directory=os.getenv("MODEL_DIRECTORY")
if not model_directory:
    raise Exception("Model directory not found in environment variables.")


# Load the model
try:
    loaded_model = GPT2LMHeadModel.from_pretrained(model_directory)
    print("Model loaded successfully.")
except Exception as e:
    loaded_model = GPT2LMHeadModel.from_pretrained(model_directory)
    print(f"Error loading model: {e}")

# Load the tokenizer
try:
    loaded_tokenizer = GPT2Tokenizer.from_pretrained(model_directory)
    print("Tokenizer loaded successfully.")
except Exception as e:
    loaded_tokenizer = GPT2Tokenizer.from_pretrained(model_directory)
    print(f"Error loading tokenizer: {e}")



def remove_redundancies(text):
    sentences = text.split('. ')
    seen = set()
    for sentence in sentences:
        words = sentence.split()
        word_counts = {}
        for word in words:
            if word in word_counts:
                word_counts[word] += 1
            else:
                word_counts[word] = 1
        repeated_words = [word for word, count in word_counts.items() if count >= 3]
        if not repeated_words and sentence not in seen:
            seen.add(sentence)
            return sentence.strip()

def generate_message(task, app, severity):
    # Define the prompt for the loaded_model
    prompt = f"Task: {task}\nApp: {app}\nSeverity: {severity}\nMessage:"

    # Tokenize the prompt
    input_ids = loaded_tokenizer.encode(prompt, return_tensors='pt')

    # Generate text based on the prompt

    output = loaded_model.generate(
        input_ids,
        max_length=200,
        pad_token_id=loaded_tokenizer.eos_token_id,
        num_return_sequences=1,
        temperature=0.9,
        top_k=100,
        do_sample=True
    )
    # Decode the generated text
      # Decode the generated text
    generated_text = loaded_tokenizer.decode(output[0], skip_special_tokens=True)
    print("dumps from model \n \n \n ####### \n \n \n")
    print(generated_text)
    # Use regex to extract the message
    pattern = re.compile(rf"Task: {task}\nApp: {app}\nSeverity: {severity}\nMessage:(.*?)(?:\n|$)", re.DOTALL)
    matches = pattern.findall(generated_text)

    # Process each match to remove redundancies
    if matches:
      first_message = remove_redundancies(matches[0])
      print(first_message)
      return first_message
    else:
      return generated_text

# generate_message(task="swimming",app="facebook",severity="1")

