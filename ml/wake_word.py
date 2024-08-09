import pathlib
import librosa
import numpy as np
import tensorflow as tf
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from keras.layers import Dense, Dropout, Flatten, Conv1D, Input, MaxPooling1D
from keras.models import Model
from keras import backend as K

TRAIN_DIR = pathlib.Path('data')
SAMPLE_RATE = 16000

def load_audio_files(train_dir):
    all_wave = []
    all_label = []
    labels = [label for label in train_dir.iterdir() if label.is_dir()]
    
    for label in labels:
        waves = list(label.glob('*.wav'))
        for wav in waves:
            samples, _ = librosa.load(wav, sr=SAMPLE_RATE)
            if len(samples) == SAMPLE_RATE:
                all_wave.append(samples)
                all_label.append(label.name)
    
    return np.array(all_wave).reshape(-1, SAMPLE_RATE, 1), all_label

def prepare_labels(all_label):
    le = LabelEncoder()
    y = le.fit_transform(all_label)
    y_categorical = tf.keras.utils.to_categorical(y, num_classes=len(le.classes_))
    return y_categorical, le.classes_

def build_model(input_shape, num_classes):
    K.clear_session()
    inputs = Input(shape=input_shape)
    conv = Conv1D(4, 13, padding='valid', activation='relu', strides=1)(inputs)
    conv = MaxPooling1D(3)(conv)
    conv = Dropout(0.3)(conv)
    conv = Conv1D(8, 11, padding='valid', activation='relu', strides=1)(conv)
    conv = MaxPooling1D(3)(conv)
    conv = Dropout(0.3)(conv)
    conv = Flatten()(conv)
    outputs = Dense(num_classes, activation='softmax')(conv)

    model = Model(inputs, outputs)
    model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])
    return model

def train_model(model, x_tr, y_tr, x_val, y_val):
    history = model.fit(x_tr, y_tr, epochs=200, batch_size=32, validation_data=(x_val, y_val))
    return history

def predict(model, audio, classes):
    prob = model.predict(audio.reshape(1, SAMPLE_RATE, 1))
    index = np.argmax(prob[0])
    return classes[index], prob[0][index]

all_wave, all_label = load_audio_files(TRAIN_DIR)
y_categorical, classes = prepare_labels(all_label)

x_tr, x_val, y_tr, y_val = train_test_split(all_wave, y_categorical, stratify=all_label, test_size=0.2, random_state=777, shuffle=True)

model = build_model((SAMPLE_RATE, 1), len(classes))
model.summary()

history = train_model(model, x_tr, y_tr, x_val, y_val)

test, _ = librosa.load('test.wav', sr=SAMPLE_RATE)
test = np.array(test).reshape(-1, SAMPLE_RATE, 1)

model.save('model.keras')
print(predict(model, test, classes))