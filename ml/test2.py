import pathlib
import os
import numpy as np
import tensorflow as tf

from tensorflow.keras import layers
from tensorflow.keras import models

import numpy as np
from pydub import AudioSegment

seed = 42
tf.random.set_seed(seed)
np.random.seed(seed)

DATASET_ORIGIN = "http://download.tensorflow.org/data/speech_commands_v0.01.tar.gz"
DATASET_PATH = 'data'
EPOCHS = 10

desired_sample_rate = 16000
desired_record_time = 1
desired_sample_size = 16  
desired_channel_num = 1

data_dir = pathlib.Path(DATASET_PATH)

if not data_dir.exists():
    tf.keras.utils.get_file(
        'speech_commands_v0.01.tar.gz',
        origin=DATASET_ORIGIN,
        extract=True,
        cache_dir='.', cache_subdir='data'
    )
  
commands = np.array(tf.io.gfile.listdir(str(data_dir)))

def reshape_audio(file_name):
    audio = AudioSegment.from_wav(file_name)

    original_sample_rate = audio.frame_rate
    original_sample_size = audio.sample_width * 8  
    original_channel_num = audio.channels
    original_record_time = len(audio) / 1000.0 

    if original_channel_num != desired_channel_num:
        if desired_channel_num == 1:
            audio = audio.set_channels(1)
        else:
            audio = audio.set_channels(2)

    if original_sample_size != desired_sample_size:
        audio = audio.set_sample_width(desired_sample_size // 8)

    if original_sample_rate != desired_sample_rate:
        audio = audio.set_frame_rate(desired_sample_rate)

    if original_record_time != desired_record_time:
        if original_record_time > desired_record_time:
            audio = audio[:desired_record_time * 1000]  
        else:
            padding = AudioSegment.silent(duration=(desired_record_time - original_record_time) * 1000)
            audio = audio + padding  
    frames = audio.raw_data
    audio_data = np.frombuffer(frames, dtype=np.int16)

    return audio_data

commands = ['gemma']
def create_data():
    data = np.empty((0,2))
    labels = np.array([])

    for i in range(len(commands)):
        print(i)
        for root, directories, files in os.walk('data/' + commands[i]):
            for file_name in files:
                data = np.append(data,[reshape_audio(os.path.join(root, file_name))], axis=0)
                labels = np.append(labels,[i])

                print(data.shape)
                print(labels.shape)
    return data, labels

data, labels = create_data()        
dataset = tf.data.Dataset.from_tensor_slices((data, labels))

num_labels = len(commands)

norm_layer = layers.Normalization()
norm_layer.adapt(data=data.map(map_func=lambda spec, label: spec))

model = models.Sequential([
    layers.Input(shape=data[0].shape),
    layers.Resizing(32, 32),
    norm_layer,
    layers.Conv2D(4, 3, activation='relu'),
    layers.MaxPooling2D(),
    layers.Flatten(),
    layers.Dense(16, activation='relu'),
    layers.Dense(num_labels),
])

model.summary()

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
    loss=tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True),
    metrics=['accuracy'],
)

history = model.fit(
    dataset,
    epochs=EPOCHS,
    batch_size=32
)

model.save('model.keras')