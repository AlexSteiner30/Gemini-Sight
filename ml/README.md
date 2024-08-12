# Wake Word Model

This folder contains the code for a light weight model written in TensorFlow able to recognize the wake word "Hey Gemini" on device thanks to the TensorFlow Lite Micro Library. 
The data used in this project can be found in ```data/``` and which can be download from [here](ttps://storage.cloud.google.com/download.tensorflow.org/data/speech_commands_v0.02.tar.gz). Since the model is designed to run on edge devices due to the limited RAM it is recommended to not use more than 5 classes present in the zip archive.
The dataset however doesn't include files for "Hey Gemini", therefore in order to produce them I used Google's Text to Speech. In order to do this substitute the Google TTS API Key with your's in ```generate.py```.

```bash
# Generate Speech Data
$ python3 generate.py

# Train Model
$ python3 train.py

# Convert Model to TF Lite
$ python3 convert_tf_lite.py

# Generate C source file
$ xxd -i model.tflite > model_data.cc
```
