#include "wake_word.h"

const double pi = 3.14159265358979323846;

void NeuralNetwork::fft_recursive(std::vector<std::complex<double>>& x) {
    int n = x.size();
    if (n <= 1) return;

    std::vector<std::complex<double>> even(n / 2), odd(n / 2);
    for (int i = 0; i < n / 2; i++) {
        even[i] = x[2 * i];
        odd[i] = x[2 * i + 1];
    }

    fft_recursive(even);
    fft_recursive(odd);

    for (int k = 0; k < n / 2; k++) {
        std::complex<double> t = std::polar(1.0, -2 * pi * k / n) * odd[k];
        x[k] = even[k] + t;
        x[k + n / 2] = even[k] - t;
    }
}

std::vector<std::complex<double>> NeuralNetwork::fft(const std::vector<double>& input) {
    int n = input.size();
    int padded_size = 1;
    while (padded_size < n) padded_size *= 2;
    
    std::vector<std::complex<double>> padded_input(padded_size);
    for (int i = 0; i < n; i++) {
        padded_input[i] = std::complex<double>(input[i], 0.0);
    }
    for (int i = n; i < padded_size; i++) {
        padded_input[i] = std::complex<double>(0.0, 0.0);
    }

    fft_recursive(padded_input);
    return padded_input;
}

std::vector<std::vector<double>> NeuralNetwork::stft(const std::vector<double>& waveform, int frame_length, int frame_step) {
    int n_frames = 1 + (waveform.size() - frame_length) / frame_step;
    int fft_length = frame_length;
    
    std::vector<std::vector<double>> spectrogram(n_frames, std::vector<double>(fft_length / 2 + 1));
    
    for (int i = 0; i < n_frames; ++i) {
        std::vector<double> frame(frame_length);
        for (int j = 0; j < frame_length; ++j) {
            if (i * frame_step + j < waveform.size()) {
                frame[j] = waveform[i * frame_step + j];
            } else {
                frame[j] = 0.0;
            }
        }
        
        for (int j = 0; j < frame_length; ++j) {
            frame[j] *= 0.5 * (1 - std::cos(2 * pi * j / (frame_length - 1)));
        }
        
        std::vector<std::complex<double>> fft_result = fft(frame);
        
        for (int j = 0; j <= fft_length / 2; ++j) {
            spectrogram[i][j] = std::abs(fft_result[j]);
        }
    }
    
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