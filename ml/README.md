# Wake Word Model

This folder contains the code for a light weight model written in TensorFlow able to recognize the wake word "Hey Gemini" on device thanks to the TensorFlow Lite Micro Library. 
The data used in this project can be found in ```data/``` and which can be download from [here](https://storage.cloud.google.com/download.tensorflow.org/data/speech_commands_v0.02.tar.gz). Since the model is designed to run on edge devices due to the limited on device RAM it is recommended to not use more than 5 classes present in the zip archive.
The dataset however doesn't include files for "Hey Gemini", therefore in order to produce them I used [Home Word Wake Word Generation](https://colab.research.google.com/drive/1q1oe2zOyZp7UsB3jJiQ1IFn8z5YfjwEb?usp=sharing#scrollTo=1cbqBebHXjFD). Open the Google Colab and change the ```target_phrase``` to ```hey_gemini```, additionaly change ```number_of_examples``` to ```2000```

```bash
# Train Model
$ python3 train.py

# Convert Model to TF Lite
$ python3 convert_tf_lite.py

# Generate C source file
$ xxd -i model.tflite > model_data.cc
```
