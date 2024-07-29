import pathlib
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import matplotlib.pyplot as plt
import random
import os
import shutil

SEED = 42
DATASET_ORIGIN = "http://download.tensorflow.org/data/speech_commands_v0.01.tar.gz"
DATASET_PATH = 'data'
EPOCHS = 20
BATCH_SIZE = 32
VALIDATION_SPLIT = 0.2
AUDIO_LENGTH = 16000

tf.random.set_seed(SEED)
np.random.seed(SEED)
random.seed(SEED)

data_dir = pathlib.Path(DATASET_PATH)
if not data_dir.exists():
    keras.utils.get_file(
        'speech_commands_v0.01.tar.gz',
        origin=DATASET_ORIGIN,
        extract=True,
        cache_dir='.',
        cache_subdir='data'
    )

commands = np.array(tf.io.gfile.listdir(str(data_dir)))
commands = commands[~np.isin(commands, ['README.md', '.DS_Store'])]
print('Commands:', commands)

train_ds, val_ds = keras.utils.audio_dataset_from_directory(
    directory=DATASET_PATH,
    batch_size=BATCH_SIZE,
    validation_split=VALIDATION_SPLIT,
    seed=SEED,
    output_sequence_length=AUDIO_LENGTH,
    subset='both'
)

label_names = np.array(train_ds.class_names)

def squeeze(audio, labels):
    return tf.squeeze(audio, axis=-1), labels

def get_mel_spectrogram(audio):
    audio = audio - tf.reduce_mean(audio)
    audio = audio / tf.reduce_max(tf.abs(audio))
    spectrogram = tf.signal.stft(audio, frame_length=255, frame_step=128)
    spectrogram = tf.abs(spectrogram)
    mel_spectrogram = tf.tensordot(spectrogram, tf.signal.linear_to_mel_weight_matrix(
        num_mel_bins=128,
        num_spectrogram_bins=spectrogram.shape[-1],
        sample_rate=16000,
        lower_edge_hertz=80,
        upper_edge_hertz=7600), 1)
    log_mel_spectrogram = tf.math.log(mel_spectrogram + 1e-6)
    return log_mel_spectrogram[..., tf.newaxis]

def make_spec_ds(ds):
    return ds.map(
        lambda audio, label: (get_mel_spectrogram(audio), label),
        num_parallel_calls=tf.data.AUTOTUNE
    )

train_ds = train_ds.map(squeeze, tf.data.AUTOTUNE)
val_ds = val_ds.map(squeeze, tf.data.AUTOTUNE)
test_ds, val_ds = val_ds.shard(num_shards=2, index=0), val_ds.shard(num_shards=2, index=1)

train_spectrogram_ds = make_spec_ds(train_ds).cache().shuffle(10000).prefetch(tf.data.AUTOTUNE)
val_spectrogram_ds = make_spec_ds(val_ds).cache().prefetch(tf.data.AUTOTUNE)
test_spectrogram_ds = make_spec_ds(test_ds).cache().prefetch(tf.data.AUTOTUNE)

for example_spectrograms, _ in train_spectrogram_ds.take(1):
    input_shape = example_spectrograms.shape[1:]
    break

print('Input shape:', input_shape)

num_labels = len(label_names)

model = keras.Sequential([
    layers.Input(shape=input_shape),
    layers.Resizing(64,64),
    layers.Conv2D(32, 3, activation='relu'),
    layers.BatchNormalization(),
    layers.Conv2D(64, 3, activation='relu'),
    layers.BatchNormalization(),
    layers.MaxPooling2D(),
    layers.Conv2D(128, 3, activation='relu'),
    layers.BatchNormalization(),
    layers.Conv2D(256, 3, activation='relu'),
    layers.BatchNormalization(),
    layers.MaxPooling2D(),
    layers.Dropout(0.5),
    layers.Flatten(),
    layers.Dense(256, activation='relu'),
    layers.BatchNormalization(),
    layers.Dropout(0.5),
    layers.Dense(num_labels, activation='softmax'),
])

model.summary()

model.compile(
    optimizer=keras.optimizers.Adam(),
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['accuracy'],
)

callbacks = [
    keras.callbacks.ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=3),
    keras.callbacks.EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
]

history = model.fit(
    train_spectrogram_ds,
    validation_data=val_spectrogram_ds,
    epochs=EPOCHS,
    callbacks=callbacks
)

def predict_audio(file_path):
    x = tf.io.read_file(file_path)
    x, _ = tf.audio.decode_wav(x, desired_channels=1, desired_samples=AUDIO_LENGTH)
    x = tf.squeeze(x, axis=-1)
    waveform = x
    x = get_mel_spectrogram(x)
    x = x[tf.newaxis, ...]
    prediction = model(x)
    return waveform, prediction

waveform, prediction = predict_audio('test.wav')

plt.bar(label_names, prediction[0])
plt.title('Prediction')
plt.show()

model.save('model.keras')
