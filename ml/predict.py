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

waveform, prediction = predict_audio('test.wav')

print(tf.nn.softmax(prediction[0]))
x_labels = ['_background_noise_','backward','bed','bird','cat','dog','down','eight','five','follow','forward','four','go','happy','house','learn','left','marvin','nine','no','off','on','one','right','seven','sheila','six','stop','three','tree','two','up','visual','wow','yes','zero']
plt.bar(x_labels, tf.nn.softmax(prediction[0]))
plt.title('Prediction')
plt.show()


model.save('model.keras')