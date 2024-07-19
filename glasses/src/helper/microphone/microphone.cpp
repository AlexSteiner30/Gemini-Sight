#include "glasses.hpp"

void i2s_install() {
  const i2s_config_t i2s_config = {
    .mode = i2s_mode_t(I2S_MODE_MASTER | I2S_MODE_RX),
    .sample_rate = SAMPLE_RATE,
    .bits_per_sample = i2s_bits_per_sample_t(16),
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = i2s_comm_format_t(I2S_COMM_FORMAT_STAND_I2S),
    .intr_alloc_flags = 0,
    .dma_buf_count = 8,
    .dma_buf_len = 64,
    .use_apll = false
  };
  i2s_driver_install(I2S_PORT, &i2s_config, 0, NULL);
}

void i2s_setpin() {
  const i2s_pin_config_t pin_config = {
    .bck_io_num = I2S_SCK,
    .ws_io_num = I2S_WS,
    .data_out_num = -1,
    .data_in_num = I2S_SD
  };
  i2s_set_pin(I2S_PORT, &pin_config);
}

void Glasses::setup_microphone(){
  i2s_install();
  i2s_setpin();
  i2s_start(I2S_PORT);
}

void Glasses::record_microphone() 
{
  current_state = speaking;

  Serial.println("speaking");

  size_t bytesRead = 0;

  int16_t* audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE && current_state == speaking) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, audioBuffer + (bytesRead / SAMPLE_SIZE), TOTAL_SAMPLES * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }
  }

  string textMessage = "speech_to_text¬" + string(AUTH_KEY)+ "¬";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + TOTAL_SAMPLES * SAMPLE_SIZE;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, audioBuffer, TOTAL_SAMPLES * SAMPLE_SIZE);

  Serial.println("spoke");

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;

  audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

  Serial.println("sent");

  get_wake_word();
}

std::vector<std::vector<double, PSRAMAllocator<double>>, PSRAMAllocator<std::vector<double, PSRAMAllocator<double>>>> Glasses::get_speech_command() {
    const uint16_t samplesPerChunk = 1024;
    const uint16_t numChunks = SAMPLE_RATE / samplesPerChunk;

    ArduinoFFT<double> FFT = ArduinoFFT<double>();
    
    std::vector<double, PSRAMAllocator<double>> vReal(samplesPerChunk);
    std::vector<double, PSRAMAllocator<double>> vImag(samplesPerChunk);

    std::vector<std::vector<double, PSRAMAllocator<double>>, PSRAMAllocator<std::vector<double, PSRAMAllocator<double>>>> fullSpectrogram;
    fullSpectrogram.reserve(numChunks);

    int16_t* buffer = (int16_t*)heap_caps_malloc(samplesPerChunk * SAMPLE_SIZE, MALLOC_CAP_SPIRAM);

    for (int chunk = 0; chunk < numChunks; chunk++) {
        size_t bytesRead = 0;
        
        while (bytesRead < samplesPerChunk * SAMPLE_SIZE) {
            size_t bytesIn = 0;
            esp_err_t result = i2s_read(I2S_PORT, buffer + (bytesRead / SAMPLE_SIZE), samplesPerChunk * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
            if (result == ESP_OK) {
                bytesRead += bytesIn;
            }
        }
        
        for (uint16_t i = 0; i < samplesPerChunk; i++) {
            vReal[i] = (double)buffer[i];
            vImag[i] = 0.0;
        }
        
        FFT.windowing(vReal.data(), samplesPerChunk, FFT_WIN_TYP_HAMMING, FFT_FORWARD);
        FFT.compute(vReal.data(), vImag.data(), samplesPerChunk, FFT_FORWARD);
        FFT.complexToMagnitude(vReal.data(), vImag.data(), samplesPerChunk);
        
        fullSpectrogram.push_back(vReal);
        
        yield();
    }

    heap_caps_free(buffer);

    return fullSpectrogram;
}