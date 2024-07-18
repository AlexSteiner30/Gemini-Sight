#include "glasses.hpp"

const int kArenaSize = 25000;

const int FRAME_SIZE = 512;
const int NUM_FRAMES = 16000 / FRAME_SIZE;

Glasses::Glasses()
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

    m_resolver = new tflite::MicroMutableOpResolver<7>();
    m_resolver->AddConv2D();
    m_resolver->AddMaxPool2D();
    m_resolver->AddReshape();
    m_resolver->AddFullyConnected();
    m_resolver->AddFullyConnected();
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


Glasses::~Glasses()
{
    delete m_interpreter;
    delete m_resolver;
    free(m_tensor_arena);
    delete m_error_reporter;
}

int Glasses::predict(std::vector<std::vector<double>> spectrogram){
    auto spectrogram_new_axis = add_new_axis(spectrogram);
    auto spectrogram_expanded = expand_dims(spectrogram_new_axis);

    auto& spec = spectrogram_expanded;

    Serial.println("process");

    spec.resize(1);
    spec[0].resize(32);
    for (auto& row : spec[0]) {
        row.resize(32);
        for (auto& col : row) {
            col.resize(1);
        }
    }

    const int kNumElements = 32 * 32 * 1;
    float input_data[kNumElements];


    int index = 0;
    for (const auto& dim1 : spec) {
        for (const auto& dim2 : dim1) {
            for (const auto& dim3 : dim2) {
                for (const auto& value : dim3) {
                    input_data[index++] = static_cast<float>(value);
                }
            }
        }
    }

    Serial.println("process");
    
    TfLiteTensor* input_tensor = m_interpreter->input(0);
    memcpy(input_tensor->data.f, input_data, kNumElements * sizeof(float));

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

    Serial.println(max_value);
    
    return max_index;
}