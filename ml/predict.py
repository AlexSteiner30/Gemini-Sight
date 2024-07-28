import tensorflow as tf
import numpy as np
import matplotlib.pyplot as plt

model_path = 'model.keras'
model = tf.keras.models.load_model(model_path)

def get_spectrogram(audio):
    audio = audio - tf.reduce_mean(audio)
    audio = audio / tf.reduce_max(tf.abs(audio))
    spectrogram = tf.signal.stft(audio, frame_length=255, frame_step=128)
    spectrogram = tf.abs(spectrogram)
    return spectrogram[..., tf.newaxis]

def predict_audio(file_path):
    x = tf.io.read_file(file_path)
    x, _ = tf.audio.decode_wav(x, desired_channels=1, desired_samples=16000)
    x = tf.squeeze(x, axis=-1)
    waveform = x
    x = get_spectrogram(x)
    x = x[tf.newaxis, ...]
    prediction = model(x)
    return waveform, prediction

waveform, prediction = predict_audio('test3.wav')

x_labels = ['other','sheila']
plt.bar(x_labels, prediction[0])
plt.title('Prediction')
plt.show()

model.save('model.keras')