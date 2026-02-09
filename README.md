# 📘 The Complete AI Tutor Setup Guide

This guide will walk you through setting up your own local AI tutor from scratch. No coding knowledge required!

---

## 1. What is this project?
The **AI Tutor Launcher** is a "wrapper" script. It acts as the bridge between you and a powerful AI engine called `llama.cpp`. Instead of typing complex commands, you use a simple menu to talk to an AI that runs entirely on your computer—no internet required.

## 2. Setting Up the Folder Structure
For everything to work, your folders must look exactly like this [cite: image_95c43b.png]:
- **[Main Folder]** (Can be named anything, e.g., "MyAITutor")
  - `Start_Tutor_Improved.bat` (The launcher script)
  - `engine/` (Where the "brain" software goes) [cite: image_95c43d.png]
  - `models/` (Where the AI model files go)

## 3. Getting the Engine (The "Brain")
The engine is what actually processes your questions.
1. Go to: https://github.com/ggerganov/llama.cpp/releases
2. Download the latest version for Windows. Look for a file containing `win-avx2-x64.zip`.
3. Open that zip file and copy **all** files into your `engine/` folder [cite: image_95c43d.png].
4. You should see files like `llama-cli.exe` and many `.dll` files inside [cite: image_95c43d.png].

## 4. Getting the Models (The "Knowledge")
Models are the AI's memory. They end in `.gguf`.
1. Go to: https://huggingface.co/models?search=gguf
2. Recommended for slow/standard PCs:
   - **Phi-3 Mini:** Great for logic and coding.
   - **Llama-3.2-1B/3B:** Very fast and smart.
3. Download the `.gguf` file and put it in your `models/` folder.

## 5. Launching your AI
1. Double-click `Start_Tutor_Improved.bat` [cite: 1, 29].
2. The script will check if you have everything ready [cite: 2, 30].
3. Select your model from the list [cite: 6, 34].
4. Choose a performance mode [cite: 16, 44]:
   - **LOW:** Uses 1 core. Best if you have 4GB RAM [cite: 10, 38].
   - **MEDIUM:** Uses 2 cores. Good for most tasks [cite: 12, 40].
   - **HIGH:** Uses 4 cores. Fastest, but uses more RAM [cite: 14, 42].
5. Pick a personality (e.g., Python Tutor) and start chatting! [cite: 19, 47]

---

## ❓ Troubleshooting
- **Error: llama-cli.exe not found:** You didn't put the files in the `engine/` folder correctly [cite: 2, 30].
- **Error: No .gguf files found:** You need to download a model and put it in the `models/` folder [cite: 5, 33].
- **AI is too slow:** Try a smaller model (under 3GB) or use "LOW" mode [cite: 10, 38].
