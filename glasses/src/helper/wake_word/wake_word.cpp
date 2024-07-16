#include "wake_word.h"

#include "model.h"
#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

#include <Arduino.h>
#include "spectogram.hpp"

const int kArenaSize = 25000;

NeuralNetwork::NeuralNetwork()
{
    m_error_reporter = new tflite::MicroErrorReporter();

    m_tensor_arena = (uint8_t *)malloc(kArenaSize);
    if (!m_tensor_arena)
    {
        TF_LITE_REPORT_ERROR(m_error_reporter, "Could not allocate arena");
        return;
    }
    TF_LITE_REPORT_ERROR(m_error_reporter, "Loading model");

    m_model = tflite::GetModel(converted_model_tflite);
    if (m_model->version() != TFLITE_SCHEMA_VERSION)
    {
        TF_LITE_REPORT_ERROR(m_error_reporter, "Model provided is schema version %d not equal to supported version %d.",
                             m_model->version(), TFLITE_SCHEMA_VERSION);
        return;
    }

    m_resolver = new tflite::MicroMutableOpResolver<10>();
    m_resolver->AddConv2D();
    m_resolver->AddMaxPool2D();
    m_resolver->AddFullyConnected();
    m_resolver->AddMul();
    m_resolver->AddAdd();
    m_resolver->AddLogistic();
    m_resolver->AddReshape();
    m_resolver->AddQuantize();
    m_resolver->AddDequantize();

    m_interpreter = new tflite::MicroInterpreter(
        m_model, *m_resolver, m_tensor_arena, kArenaSize, m_error_reporter);

    TfLiteStatus allocate_status = m_interpreter->AllocateTensors();
    if (allocate_status != kTfLiteOk)
    {
        TF_LITE_REPORT_ERROR(m_error_reporter, "AllocateTensors() failed");
        return;
    }

    size_t used_bytes = m_interpreter->arena_used_bytes();
    TF_LITE_REPORT_ERROR(m_error_reporter, "Used bytes %d\n", used_bytes);

    input = m_interpreter->input(0);
    output = m_interpreter->output(0);
}


NeuralNetwork::~NeuralNetwork()
{
    delete m_interpreter;
    delete m_resolver;
    free(m_tensor_arena);
    delete m_error_reporter;
}

int NeuralNetwork::predict(const std::vector<double>& audio){
    int frame_length = 255;
    int frame_step = 128;

    std::vector<std::vector<double>> spectrogram = stft(audio, frame_length, frame_step);

    auto spectrogram_new_axis = add_new_axis(spectrogram);
    auto spectrogram_expanded = expand_dims(spectrogram_new_axis);

    Serial.print(spectrogram_expanded.size());
    Serial.print(" x ");
    Serial.print(spectrogram_expanded[0].size());
    Serial.print(" x ");
    Serial.print(spectrogram_expanded[0][0].size());
    Serial.print(" x " );
    Serial.println(spectrogram_expanded[0][0][0].size());

    //auto input_tensor = preprocess_audio(audio);
    TfLiteTensor* input = m_interpreter->input(0);
    
    Serial.println(input->bytes);
    //Serial.println(input_tensor.size());
    
    return 1;
}