#ifndef __NeuralNetwork__
#define __NeuralNetwork__

#include <stdint.h>
#include <iostream>
#include <vector>
#include <cmath>
#include <complex>
#include <algorithm>
#include <string>

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
    tflite::MicroMutableOpResolver<10> *m_resolver;
    tflite::ErrorReporter *m_error_reporter;
    const tflite::Model *m_model;
    tflite::MicroInterpreter *m_interpreter;
    TfLiteTensor *input;
    TfLiteTensor *output;
    uint8_t *m_tensor_arena;

public:
    NeuralNetwork();
    ~NeuralNetwork();
    int predict(const std::vector<double> &audio);
};

#endif