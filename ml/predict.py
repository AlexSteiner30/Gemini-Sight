import tensorflow as tf
import numpy as np
import librosa

model_path = 'model.keras'
model = tf.keras.models.load_model(model_path)

def get_spectrogram(waveform):
    spectrogram = tf.signal.stft(waveform, frame_length=255, frame_step=128)
    spectrogram = tf.abs(spectrogram)
    spectrogram = spectrogram[..., tf.newaxis]

    return spectrogram

def predict_from_wav(wav_file_path, label_names):
    # Load the trained model

    # Load and preprocess the WAV file
    audio, sr = librosa.load(wav_file_path, sr=16000, duration=1.0)
    
    # Pad or truncate the audio to 16000 samples (1 second)
    if len(audio) < 16000:
        audio = np.pad(audio, (0, 16000 - len(audio)))
    else:
        audio = audio[:16000]
    
    # Get the spectrogram
    spectrogram = get_spectrogram(audio)
    
    # Add batch dimension
    spectrogram = spectrogram[np.newaxis, ...]
    
    # Make prediction
    prediction = model.predict(spectrogram)

    print(prediction)
    
    # Get the predicted label index and probability
    predicted_index = np.argmax(prediction)
    predicted_probability = prediction[0][predicted_index]
    
    # Get the predicted label name
    predicted_label = label_names[predicted_index]
    
    return predicted_label, predicted_probability

# Usage example:
wav_file_path = 'test2.wav'
predicted_label, probability = predict_from_wav(wav_file_path,['_background_noise_' , 'gemma', 'sheila' ,'stop'])
print(f"Predicted label: {predicted_label}")
print(f"Probability: {probability:.4f}")

x = 'test2.wav'
x = tf.io.read_file(str(x))
x, sample_rate = tf.audio.decode_wav(x, desired_channels=1, desired_samples=16000,)
x = tf.squeeze(x, axis=-1)
waveform = x
x = get_spectrogram(x)
x = x[tf.newaxis,...]

prediction = model(x)
print(prediction)