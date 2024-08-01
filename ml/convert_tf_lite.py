import tensorflow as tf
import numpy as np

model = tf.keras.models.load_model('model.keras')
converter = tf.lite.TFLiteConverter.from_keras_model(model)

converter.optimizations = [tf.lite.Optimize.DEFAULT]
dynamic_range_model = converter.convert()

with open("model.tflite", "wb") as f:
    f.write(dynamic_range_model)