import tensorflow as tf
from keras.layers import Dense, Dropout, Flatten, Conv1D, Input, MaxPooling1D
from keras.models import Model
from keras.callbacks import EarlyStopping
from keras import backend as K

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
