#include "wake_word.h"

#include <vector>
#include <cmath>

const double pi = 3.14159265358979323846;

// Function to perform FFT (Cooley-Tukey algorithm)
void NeuralNetwork::fft(std::vector<double>& frame, std::vector<double>& real, std::vector<double>& imag) {
    int n = frame.size();
    if (n <= 1) return;

    // Split into even and odd indices
    std::vector<double> even(n/2), odd(n/2);
    for (int i = 0; i < n/2; ++i) {
        even[i] = frame[2*i];
        odd[i] = frame[2*i + 1];
    }

    // Recursively compute FFT on even and odd parts
    std::vector<double> even_real(n/2), even_imag(n/2);
    std::vector<double> odd_real(n/2), odd_imag(n/2);
    fft(even, even_real, even_imag);
    fft(odd, odd_real, odd_imag);

    // Combine the results
    for (int k = 0; k < n/2; ++k) {
        double theta = -2 * pi * k / n;
        double w_real = std::cos(theta);
        double w_imag = std::sin(theta);

        real[k] = even_real[k] + w_real * odd_real[k] - w_imag * odd_imag[k];
        imag[k] = even_imag[k] + w_real * odd_imag[k] + w_imag * odd_real[k];

        real[k + n/2] = even_real[k] - (w_real * odd_real[k] - w_imag * odd_imag[k]);
        imag[k + n/2] = even_imag[k] - (w_real * odd_imag[k] + w_imag * odd_real[k]);
    }
}

// Function to compute magnitude of complex FFT output
void NeuralNetwork::computeMagnitude(const std::vector<double>& real, const std::vector<double>& imag, std::vector<double>& magnitude) {
    int n = real.size();
    for (int i = 0; i < n; ++i) {
        magnitude[i] = std::sqrt(real[i] * real[i] + imag[i] * imag[i]);
    }
}

// STFT function without using KissFFT
std::vector<std::vector<double>> NeuralNetwork::stft(const std::vector<double>& waveform, int frame_length, int frame_step) {
    int n_frames = 1 + (waveform.size() - frame_length) / frame_step;
    int fft_length = frame_length;
    std::vector<std::vector<double>> spectrogram(n_frames, std::vector<double>(fft_length / 2 + 1));

    for (int i = 0; i < n_frames; ++i) {
        std::vector<double> frame(frame_length, 0.0);
        for (int j = 0; j < frame_length && i * frame_step + j < waveform.size(); ++j) {
            frame[j] = waveform[i * frame_step + j];
        }

        // Apply Hann window
        for (int j = 0; j < frame_length; ++j) {
            frame[j] *= 0.5 * (1.0 - std::cos(2.0 * pi * j / (frame_length - 1)));
        }

        // Perform FFT
        std::vector<double> real(fft_length);
        std::vector<double> imag(fft_length);
        fft(frame, real, imag);

        // Compute magnitude and store in spectrogram
        computeMagnitude(real, imag, spectrogram[i]);
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