import tensorflow as tf
import numpy as np

commands = np.array(tf.io.gfile.listdir(str('data/')))
label_names = commands[(commands != 'README.md') & (commands != '.DS_Store')]
label_names = ['_background_noise_', 'gemma', 'go', 'marvin', 'sheila', 'stop']
print(label_names)
def get_spectrogram(waveform):
    spectrogram = tf.signal.stft(waveform, frame_length=255, frame_step=128)
    spectrogram = tf.abs(spectrogram)
    spectrogram = spectrogram[..., tf.newaxis]

    return spectrogram

model = tf.keras.models.load_model('model.keras')

def preprocess_audio():
    audio = [2, 0, 2, 0, 4, 0, 4, 0, 4, 0, 4, 0, 8, 0, 8, 0, 6, 0, 6, 0, 4, 0, 4, 0, 2, 0, 2, 0, 0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 4, 0, 4, 0, 4, 0, 4, 0, 2, 0, 2, 0, 0, 0, 0, 0, 254, 255, 254, 255, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 2, 0, 4, 0, 4, 0, 2, 0, 2, 0, 254, 255, 254, 255, 0, 0, 0, 0, 2, 0, 2, 0, 254, 255, 254, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 254, 255, 254, 255, 0, 0, 0, 0, 254, 255, 254, 255, 0, 0, 0, 0, 2, 0, 2, 0, 254, 255, 254, 255, 252, 255, 252, 255, 254, 255, 254, 255, 252, 255, 252, 255, 252, 255, 252, 255, 252, 255, 252, 255, 252, 255, 252, 255, 254, 255, 254, 255, 250, 255, 250, 255, 248, 255, 248, 255, 248, 255, 248, 255, 250, 255, 250, 255, 250, 255, 250, 255, 252, 255, 252, 255, 252, 255, 252, 255, 250, 255, 250, 255, 250, 255, 250, 255, 252, 255, 252, 255, 254, 255, 254, 255, 0, 0, 0, 0, 0, 0, 0, 0, 254, 255, 254, 255, 252, 255, 252, 255, 250, 255, 250, 255, 250, 255, 250, 255, 252, 255, 252, 255, 252, 255, 252, 255, 250, 255, 250, 255, 250, 255, 250, 255, 248, 255, 248, 255, 250, 255, 250, 255, 250, 255, 250, 255, 250, 255, 250, 255, 254, 255, 254, 255, 250, 255, 250, 255, 248, 255, 248, 255, 248, 255, 248, 255, 246, 255, 246, 255, 246, 255, 246, 255, 248, 255, 248, 255, 250, 255, 250, 255, 248, 255, 248, 255, 252, 255, 252, 255, 250, 255, 250, 255, 252, 255, 252, 255, 254, 255, 254, 255, 0, 0, 0, 0, 0, 0, 0, 0, 252, 255, 252, 255, 254, 255, 254, 255, 252, 255, 252, 255, 0, 0, 0, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 4, 0, 4, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 4, 0, 4, 0, 2, 0, 2, 0, 4, 0, 4, 0, 4, 0, 4, 0, 0, 0, 0, 0, 254, 255, 254, 255, 252, 255, 252, 255, 254, 255, 254, 255, 254, 255, 254, 255, 254, 255, 254, 255, 0, 0, 0, 0, 252, 255, 252, 255, 248, 255, 248, 255, 250, 255, 250, 255, 250, 255, 250, 255, 250, 255, 250, 255, 248, 255, 248, 255, 248, 255, 236, 255, 236, 255, 236, 255, 232, 255, 232, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 236, 255, 236, 255, 234, 255, 234, 255, 234, 255, 234, 255, 236, 255, 236, 255, 236, 255, 236, 255, 234, 255, 234, 255, 238, 255, 238, 255, 234, 255, 234, 255, 234, 255, 234, 255, 238, 255, 238, 255, 234, 255, 234, 255, 234, 255, 234, 255, 236, 255, 236, 255, 234, 255, 234, 255, 236, 255, 236, 255, 234, 255, 234, 255, 232, 255, 232, 255, 234, 255, 234, 255, 228, 255, 228, 255, 228, 255, 228, 255, 230, 255, 230, 255, 230, 255, 230, 255, 232, 255, 232, 255, 230, 255, 230, 255, 226, 255, 226, 255, 228, 255, 228, 255, 230, 255, 230, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 226, 255, 226, 255, 230, 255, 230, 255, 232, 255, 232, 255, 230, 255, 230, 255, 232, 255, 232, 255, 230, 255, 230, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 232, 255, 232, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 236, 255, 236, 255, 236, 255, 236, 255, 234, 255, 234, 255, 236, 255, 236, 255, 238, 255, 238, 255, 236, 255, 236, 255, 238, 255, 238, 255, 236, 255, 236, 255, 238, 255, 238, 255, 238, 255, 238, 255, 238, 255, 238, 255, 234, 255, 234, 255, 236, 255, 236, 255, 234, 255, 234, 255, 232, 255, 232, 255, 236, 255, 236, 255, 232, 255, 232, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 234, 255, 232, 255, 232, 255, 232, 255, 232, 255, 228, 255, 228, 255, 230, 255, 230, 255, 228, 255, 228, 255, 230, 255, 230, 255, 230, 255, 230, 255, 234, 255, 234, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 230, 255, 230, 255, 232, 255, 232, 255, 232, 255, 232, 255, 234, 255, 234, 255, 232, 255, 232, 255, 230, 255, 230, 255, 232, 255, 232, 255, 234, 255, 234, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 230, 255, 230, 255, 230, 255, 230, 255, 228, 255, 228, 255, 226, 255, 226, 255, 230, 255, 230, 255, 228, 255, 228, 255, 224, 255, 224, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 232, 255, 232, 255, 236, 255, 236, 255, 234, 255, 234, 255, 232, 255, 232, 255, 234, 255, 234, 255, 236, 255, 236, 255, 234, 255, 234, 255, 236, 255, 236, 255, 234, 255, 234, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 236, 255, 236, 255, 236, 255, 236, 255, 234, 255, 234, 255, 234, 255, 234, 255, 236, 255, 236, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 236, 255, 236, 255, 230, 255, 230, 255, 230, 255, 230, 255, 228, 255, 228, 255, 228, 255, 228, 255, 226, 255, 226, 255, 226, 255, 226, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 224, 255, 224, 255, 224, 255, 224, 255, 222, 255, 222, 255, 222, 255, 222, 255, 222, 255, 222, 255, 220, 255, 220, 255, 216, 255, 216, 255, 220, 255, 220, 255, 222, 255, 222, 255, 222, 255, 222, 255, 224, 255, 224, 255, 222, 255, 222, 255, 224, 255, 224, 255, 224, 255, 224, 255, 224, 255, 224, 255, 226, 255, 226, 255, 224, 255, 224, 255, 228, 255, 228, 255, 228, 255, 228, 255, 226, 255, 226, 255, 228, 255, 228, 255, 226, 255, 226, 255, 228, 255, 228, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 234, 255, 234, 255, 228, 255, 228, 255, 234, 255, 234, 255, 232, 255, 232, 255, 234, 255, 234, 255, 230, 255, 230, 255, 232, 255, 232, 255, 234, 255, 234, 255, 234, 255, 234, 255, 232, 255, 232, 255, 228, 255, 228, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 232, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 228, 255, 230, 255, 230, 255, 230, 255, 230, 255, 228, 255, 228, 255, 226, 255, 226, 255, 228, 255, 228, 255, 230, 255, 230, 255, 230, 255, 230, 255, 226, 255, 226, 255, 228, 255, 228, 255, 224, 255, 224, 255, 224, 255, 224, 255, 224, 255, 224, 255, 224, 255, 224, 255, 226, 255, 226, 255, 228, 255, 228, 255, 222, 255, 222, 255, 224, 255, 224, 255, 226, 255, 226, 255, 220, 255, 220, 255, 220, 255, 220, 255, 220, 255, 220, 255, 218, 255, 218, 255, 220, 255, 220, 255, 218, 255, 218, 255, 220, 255, 220, 255, 220, 255, 220, 255, 218, 255, 218, 255, 222, 255, 222, 255, 222, 255, 222, 255, 218, 255, 218, 255, 222, 255, 222, 255, 220, 255, 220, 255, 222, 255, 222, 255, 222, 255, 222, 255, 220, 255, 220, 255, 224, 255, 224, 255, 224, 255, 224, 255, 228, 255, 228, 255, 224, 255, 224, 255, 226, 255, 226, 255, 226, 255, 226, 255, 226, 255, 226, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 230, 255, 232, 255, 232, 255, 232, 255, 232, 255, 236, 255, 236, 255, 234, 255, 234, 255, 234, 255, 234, 255, 238, 255, 238, 255, 236, 255, 236, 255, 238, 255, 238, 255, 236, 255, 236, 255, 236, 255, 236, 255, 238, 255, 238, 255, 238, 255, 238, 255, 240, 255, 240, 255, 240, 255, 240, 255, 238, 255, 238, 255, 238, 255, 238, 255, 236, 255, 236, 255, 234, 255, 234, 255]
    audio = np.random.randn(16000)
    audio = np.array(audio, dtype=np.float32)
    spectrogram = get_spectrogram(audio)
   
    return spectrogram

def predict_class():
    audio_spectrogram = preprocess_audio()
    audio_spectrogram = tf.expand_dims(audio_spectrogram, 0)  
    predictions = model.predict(audio_spectrogram)
    print(predictions)
    predicted_class = label_names[np.argmax(predictions[0])]
    print(np.argmax(predictions[0]))

    return predicted_class, predictions[0][np.argmax(predictions[0])]

predicted_class, confidence = predict_class()
print(f"Predicted class: {predicted_class}")
print(f"Confidence: {confidence:.2f}")