#include "wake_word.h"

const double pi = 3.14159265358979323846;

std::vector<std::vector<float>> NeuralNetwork::stft(const std::vector<float>& waveform, int frame_length, int frame_step) {
    int n_frames = 1 + (waveform.size() - frame_length) / frame_step;
    int fft_length = frame_length;
    std::vector<std::vector<float>> spectrogram(n_frames, std::vector<float>(fft_length / 2 + 1));

    // Initialize KissFFT
    kiss_fftr_cfg cfg = kiss_fftr_alloc(fft_length, 0, nullptr, nullptr);
    std::vector<kiss_fft_cpx> fft_out(fft_length / 2 + 1);

    for (int i = 0; i < n_frames; ++i) {
        std::vector<float> frame(frame_length, 0.0f);
        for (int j = 0; j < frame_length && i * frame_step + j < waveform.size(); ++j) {
            frame[j] = waveform[i * frame_step + j];
        }

        // Apply Hann window
        for (int j = 0; j < frame_length; ++j) {
            frame[j] *= 0.5f * (1.0f - std::cos(2.0f * pi * j / (frame_length - 1)));
        }

        // Perform FFT using KissFFT
        kiss_fftr(cfg, frame.data(), fft_out.data());

        // Compute magnitude
        for (int j = 0; j <= fft_length / 2; ++j) {
            spectrogram[i][j] = std::sqrt(fft_out[j].r * fft_out[j].r + fft_out[j].i * fft_out[j].i);
        }
    }

    // Free KissFFT resources
    kiss_fftr_free(cfg);

    return spectrogram;
}

std::vector<std::vector<std::vector<double>>> NeuralNetwork::add_new_axis(const std::vector<std::vector<double>>& spectrogram) {
    std::vector<std::vector<std::vector<double>>> result;
    result.reserve(spectrogram.size());
    for (const auto& row : spectrogram) {
        result.push_back(std::vector<std::vector<double>>(1, row));
    }
    return result;
}

std::vector<std::vector<std::vector<std::vector<double>>>> NeuralNetwork::expand_dims(const std::vector<std::vector<std::vector<double>>>& spectrogram) {
    return std::vector<std::vector<std::vector<std::vector<double>>>>(1, spectrogram);
}