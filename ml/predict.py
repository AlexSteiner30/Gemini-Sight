import pathlib
import librosa
import numpy as np
import tensorflow as tf
from keras.models import load_model
from sklearn.preprocessing import LabelEncoder

SAMPLE_RATE = 16000

def load_audio(file_path):
    samples, _ = librosa.load(file_path, sr=SAMPLE_RATE)
    if len(samples) > SAMPLE_RATE:
        samples = samples[:SAMPLE_RATE]
    elif len(samples) < SAMPLE_RATE:
        samples = np.pad(samples, (0, max(0, SAMPLE_RATE - len(samples))), "constant")
    return np.array(samples).reshape(-1, SAMPLE_RATE, 1)

def predict(model, audio, classes):
    prob = model.predict(audio.reshape(1, SAMPLE_RATE, 1))
    print(prob[0][1])
    index = np.argmax(prob[0])
    return classes[index], prob[0][index]

def load_classes(train_dir):
    labels = sorted([label.name for label in train_dir.iterdir() if label.is_dir()])
    le = LabelEncoder()
    le.fit(labels)
    return le.classes_

TRAIN_DIR = pathlib.Path('data')
classes = load_classes(TRAIN_DIR)

# Load the pre-trained model
model = load_model('model.keras')

# Load and preprocess the test audio
test_audio = load_audio('test.wav')

# Make a prediction
predicted_class, confidence = predict(model, test_audio, classes)
print(f"Predicted Class: {predicted_class}, Confidence: {confidence}")