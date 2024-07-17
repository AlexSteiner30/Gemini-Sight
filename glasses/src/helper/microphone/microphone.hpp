#include <driver/i2s.h>
#include <vector>

#define I2S_WS 15
#define I2S_SD 13
#define I2S_SCK 2
#define I2S_PORT I2S_NUM_0
 
#define SAMPLE_RATE 16000
#define RECORD_TIME 90
#define SAMPLE_SIZE 2
#define CHANNEL_NUM 1
#define TOTAL_SAMPLES (SAMPLE_RATE * RECORD_TIME)

int16_t* audioBuffer;
size_t bytesRead = 0;

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

std::vector<double> processAudioData(int16_t* audioBuffer, size_t bufferSize) {
    std::vector<double> audioVector;
    audioVector.reserve(bufferSize);

    for (size_t i = 0; i < bufferSize; ++i) {
        double sample = static_cast<double>(audioBuffer[i]) / 32768.0;
        audioVector.push_back(sample);
    }

    delete[] audioBuffer;

    return audioVector;
}


void record_microphone() {
  size_t bytesRead = 0;

  while (bytesRead < TOTAL_SAMPLES * SAMPLE_SIZE && isTalking) {
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

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;

  audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);

  isTalking = true;
}

std::vector<double> get_speech_command() {
  size_t bytesRead = 0;
  int16_t* buffer = (int16_t*)malloc(SAMPLE_RATE * SAMPLE_SIZE);

  while (bytesRead < SAMPLE_RATE * SAMPLE_SIZE && isTalking) {
    size_t bytesIn = 0;
    esp_err_t result = i2s_read(I2S_PORT, buffer + (bytesRead / SAMPLE_SIZE), SAMPLE_RATE * SAMPLE_SIZE - bytesRead, &bytesIn, portMAX_DELAY);
    if (result == ESP_OK) {
      bytesRead += bytesIn;
    }
  }

  return processAudioData(reinterpret_cast<int16_t*>(buffer), bytesRead / sizeof(int16_t));
}