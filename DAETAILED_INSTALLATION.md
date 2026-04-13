# 📘 The Complete AI Tutor Setup Guide

This guide will walk you through setting up your own local AI tutor from scratch. No coding knowledge required!

---

## 1. What is this project?
The **AI Tutor Launcher** is a "wrapper" script. It acts as the bridge between you and a powerful AI engine called `llama.cpp`. Instead of typing complex commands, you use a simple menu to talk to an AI that runs entirely on your computer—no internet required.

## 2. Setting Up the Folder Structure
For everything to work, your folders must look exactly like this:
- **[Main Folder]** (Can be named anything, e.g., "MyAITutor")
  - `Start_Tutor_Improved.bat` (The launcher script)
  - `Start_Tutor_Improved.bat` (The launcher script)
  - `engine-YOUR_CHOICE/` (e.g., `engine-cpu`, `engine-cuda`, `engine-hip`)
  - `models/` (Where the AI model files go)

*Note: You can have multiple engine folders! The launcher will automatically detect any folder that starts with `engine-`.*

## 3. Getting the Engine(s) (The "Brain")
The engine is what actually processes your questions. You can choose to download any engine type that matches your hardware:

- **CPU (`engine-cpu`):** Slower but guaranteed to work on any Windows PC natively.
- **CUDA (`engine-cuda`):** The absolute fastest option, requires a modern NVIDIA graphics card.
- **Vulkan (`engine-vulkan`):** Very fast, works on almost any dedicated or modern integrated graphics card (AMD, Intel, older NVIDIA).
- **Other specialized engines:** SYCL (Intel), HIP (AMD ROCm), OpenVINO, etc.

1. Go to: https://github.com/ggerganov/llama.cpp/releases
2. Download the `win-XXX-x64` zip file that corresponds to your hardware. 
   - For CPU, look for the basic `win-XXX-x64.zip`.
   - For others, look for the suffix (e.g., `-vulkan`, `-cu1220`, `-hip`, `-sycl`).
3. Create a new folder starting with `engine-` (for example: `engine-cpu` or `engine-hip`).
4. Extract **all** files from your downloaded zip into that folder. 
5. You should see `llama-cli.exe`, `llama-server.exe`, and some `.dll` files inside the folder you just populated.

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
5. Choose your Interface Mode:
   - **Terminal Mode:** The classic, fast CLI interface. Pick your personality next, and start chatting.
   - **Browser Mode (Web UI):** Opens a beautiful "ChatGPT-like" display in your web browser. You can configure personas and use vision models to upload images here!

---

## ❓ Troubleshooting
- **Error: Could not find any engine files!:** You didn't put the files in a folder starting with `engine-` (like `engine-cpu/` or `engine-cuda/`) correctly, or you didn't extract `llama-cli.exe` or `llama-server.exe`.
- **Error: No .gguf files found:** You need to download a model and put it in the `models/` folder.
- **AI is too slow:** Try a smaller model (under 3GB) or use "LOW" mode.