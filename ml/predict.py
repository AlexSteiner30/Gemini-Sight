import tensorflow as tf
import numpy as np
import os
import librosa
from sklearn.preprocessing import LabelEncoder

train_dir = 'data'
labels = os.listdir(train_dir)
all_label = []

for label in labels:
    print(label)
    waves = [f for f in os.listdir(os.path.join(train_dir, label)) if f.endswith('.wav')]
    for wav in waves:
        samples, sample_rate = librosa.load(os.path.join(train_dir, label, wav), sr=16000)
        samples = librosa.resample(samples, orig_sr=sample_rate, target_sr=16000)
        if len(samples) == 16000:
            all_label.append(label)

le = LabelEncoder()
y = le.fit_transform(all_label)
classes = list(le.classes_)
print(classes)

tflite_model_path = 'model.tflite'

interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

def predict(audio):
    interpreter.set_tensor(input_details[0]['index'], audio.reshape(1, 16000, 1).astype(np.float32))
    interpreter.invoke()
    prob = interpreter.get_tensor(output_details[0]['index'])
    index = np.argmax(prob[0])
    print(index)
    print(prob)
    return classes[index], prob[0][index]

test, sample_rate = librosa.load('test_gemini.wav', sr=16000)
test = librosa.resample(test, orig_sr=sample_rate, target_sr=16000)
test = np.array(test).reshape(-1, 16000, 1)

print(predict(test))