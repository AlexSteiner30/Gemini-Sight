import pathlib
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import matplotlib.pyplot as plt


SEED = 42
DATASET_ORIGIN = "http://download.tensorflow.org/data/speech_commands_v0.01.tar.gz"
DATASET_PATH = 'data'
EPOCHS = 30
BATCH_SIZE = 64
VALIDATION_SPLIT = 0.2
AUDIO_LENGTH = 16000

tf.random.set_seed(SEED)
np.random.seed(SEED)

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
    directory=data_dir,
    batch_size=BATCH_SIZE,
    validation_split=VALIDATION_SPLIT,
    seed=SEED,
    output_sequence_length=AUDIO_LENGTH,
    subset='both'
)

label_names = np.array(train_ds.class_names)

def squeeze(audio, labels):
    return tf.squeeze(audio, axis=-1), labels

def get_spectrogram(waveform):
    spectrogram = tf.signal.stft(waveform, frame_length=255, frame_step=128)
    spectrogram = tf.abs(spectrogram)
    return spectrogram[..., tf.newaxis]

def make_spec_ds(ds):
    return ds.map(
        lambda audio, label: (get_spectrogram(audio), label),
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
    layers.Resizing(32, 32),
    layers.Conv2D(32, 3, activation='relu'),
    layers.Conv2D(64, 3, activation='relu'),
    layers.MaxPooling2D(),
    layers.Dropout(0.25),
    layers.Flatten(),
    layers.Dense(128, activation='relu'),
    layers.Dropout(0.5),
    layers.Dense(num_labels),
])

model.summary()

model.compile(
    optimizer=keras.optimizers.Adam(),
    loss=keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['accuracy'],
)

history = model.fit(
    train_spectrogram_ds,
    validation_data=val_spectrogram_ds,
    epochs=EPOCHS
)

def predict_audio(file_path):
    x = tf.io.read_file(file_path)
    x, _ = tf.audio.decode_wav(x, desired_channels=1, desired_samples=AUDIO_LENGTH)
    x = tf.squeeze(x, axis=-1)
    waveform = x
    x = get_spectrogram(x)
    x = x[tf.newaxis, ...]
    prediction = model(x)
    return waveform, prediction

waveform, prediction = predict_audio('test2.wav')

print(tf.nn.softmax(prediction[0]))
x_labels = ['noise', 'gemma', 'stop']
plt.bar(x_labels, tf.nn.softmax(prediction[0]))
plt.title('Prediction')
plt.show()


model.save('model.keras')