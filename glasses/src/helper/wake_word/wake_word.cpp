#include "glasses.hpp"

const int kArenaSize = 90000;

const int FRAME_SIZE = 512;
const int NUM_FRAMES = 16000 / FRAME_SIZE;

/**
 * Setup TensorFlow Lite Micro
 * Allocate memory 
 * Create Model
 * Input and Output dimensions 
 */
void Glasses::setup_tf()
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

    m_resolver = new tflite::MicroMutableOpResolver<9>();
    m_resolver->AddConv2D();
    m_resolver->AddMaxPool2D();
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

/*
Glasses::~Glasses()
{
    delete m_interpreter;
    delete m_resolver;
    free(m_tensor_arena);
    delete m_error_reporter;
}
*/

/**
 * Predict Wake Word
 * 
 * @param input_buffer 16Hz audio buffer
 * @return true when class is 2 hence "Hey Gemini" and confidence is above 95% 
 */
bool Glasses::predict(int16_t* input_buffer) {
    TfLiteTensor* input_tensor = m_interpreter->input(0);

    int input_size = input_tensor->bytes / sizeof(float);
    std::vector<float> input_data(input_size, 0.0f);

    for(int i = 0; i < sizeof(input_buffer); i++){
        input_data[i] = static_cast<float>(input_buffer[i]);
    }

    memcpy(input_tensor->data.f, input_data.data(), input_size * sizeof(float));
    m_interpreter->Invoke();

    TfLiteTensor* output = m_interpreter->output(0);

    float* results = output->data.f;
    int num_results = output->bytes / sizeof(float);

    int max_index = 0;
    float max_value = results[0];

    for (int i = 1; i < num_results; i++) {
        if (results[i] > max_value) {
            max_value = results[i];
            max_index = i;
        }
    }

    return max_index == 2 && max_value > 0.95;
}