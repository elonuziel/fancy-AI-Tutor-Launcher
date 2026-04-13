# 📘 The Complete AI Tutor Setup Guide

This guide will walk you through setting up your own local AI tutor from scratch. No coding knowledge required!

---

## 1. What is this project?
The **AI Tutor Launcher** is a "wrapper" script. It acts as the bridge between you and a powerful AI engine called `llama.cpp`. Instead of typing complex commands, you use a simple menu to talk to an AI that runs entirely on your computer—no internet required.

## 2. Setting Up the Folder Structure
For everything to work, your folders must look exactly like this:
- **[Main Folder]** (Can be named anything, e.g., "MyAITutor")
  - `Start_Tutor_Improved.bat` (The launcher script)
  - `engine/` (Where the "brain" software goes)
  - `models/` (Where the AI model files go)

## 3. Getting the Engine (The "Brain")
The engine is what actually processes your questions.
1. Go to: https://github.com/ggerganov/llama.cpp/releases
2. Download the latest version for Windows. Look for a file containing `win-XXX-x64.zip`. XXX is the version - if you have a GPU (even integrated), look for a file containing your appropiate GPU drivers (vulkan for general support).
3. Open that zip file and copy **all** files into your `engine/` folder.
4. You should see files like `llama-cli.exe` and many `.dll` files inside.

## 4. Getting the Models (The "Knowledge")
Models are the AI's memory. They end in `.gguf`.
1. Go to: https://huggingface.co/models?search=gguf
2. Recommended for slow/standard PCs:
   - **Phi-3 Mini:** Great for logic and coding.
   - **Llama-3.2-1B/3B:** Very fast and smart.
3. Download the `.gguf` file and put it in your `models/` folder.

## 5. Launching your AI
1. Double-click `Start_Tutor_Improved.bat`.
2. The script will check if you have everything ready.
3. Select your model from the list.
4. Choose a performance mode:
   - **LOW:** Uses 1 core. Best if you have 4GB RAM.
   - **MEDIUM:** Uses 2 cores. Good for most tasks.
   - **HIGH:** Uses 4 cores. Fastest, but uses more RAM.
5. Pick a personality (e.g., Python Tutor) and start chatting!

---

## ❓ Troubleshooting
- **Error: llama-cli.exe not found:** You didn't put the files in the `engine/` folder correctly.
- **Error: No .gguf files found:** You need to download a model and put it in the `models/` folder.
- **AI is too slow:** Try a smaller model (under 3GB) or use "LOW" mode.