#ifndef __NeuralNetwork__
#define __NeuralNetwork__

#include <stdint.h>
#include <iostream>
#include <vector>
#include <cmath>
#include <complex>
#include <algorithm>
#include <string>
#include <typeinfo>

#include "kissfft.hh"
#include "tools/kiss_fftr.h"

#include "model.h"

#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

namespace tflite
{
    template <unsigned int tOpCount>
    class MicroMutableOpResolver;
    class ErrorReporter;
    class Model;
    class MicroInterpreter;
} // namespace tflite

struct TfLiteTensor;

class NeuralNetwork
{
private:
    tflite::MicroMutableOpResolver<7> *m_resolver;
    tflite::ErrorReporter *m_error_reporter;
    const tflite::Model *m_model;
    tflite::MicroInterpreter *m_interpreter;
    TfLiteTensor *input;
    TfLiteTensor *output;
    uint8_t *m_tensor_arena;

public:
    NeuralNetwork();
    ~NeuralNetwork();
    int predict(std::vector<double> audio);

private:
    void fft(std::vector<double> &frame, std::vector<double> &real, std::vector<double> &imag);
    void computeMagnitude(const std::vector<double> &real, const std::vector<double> &imag, std::vector<double> &magnitude);
    std::vector<std::vector<double>> stft(const std::vector<double> &waveform, int frame_length, int frame_step);
    std::vector<std::vector<std::vector<double>>> add_new_axis(const std::vector<std::vector<double>> &spectrogram);
    std::vector<std::vector<std::vector<std::vector<double>>>> expand_dims(const std::vector<std::vector<std::vector<double>>> &spectrogram);
};

#endif