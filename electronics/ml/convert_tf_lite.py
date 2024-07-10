import tensorflow as tf
import numpy as np

model=tf.keras.models.load_model('model.keras')
tflite_converter = tf.lite.TFLiteConverter.from_keras_model(model)

tflite_model = tflite_converter.convert()
open("tf_lite_model.tflite", "wb").write(tflite_model)