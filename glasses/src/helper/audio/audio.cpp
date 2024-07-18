#include "glasses.hpp"

#define LRC 16
#define BCLK 12 
#define DIN 14

i2s_config_t i2sConfig = {
    .mode = (i2s_mode_t)(I2S_MODE_MASTER | I2S_MODE_TX),
    .sample_rate = 44100,
    .bits_per_sample = I2S_BITS_PER_SAMPLE_16BIT,
    .channel_format = I2S_CHANNEL_FMT_ONLY_LEFT,
    .communication_format = I2S_COMM_FORMAT_I2S_MSB,
    .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1,
    .dma_buf_count = 8,
    .dma_buf_len = 1024,
    .use_apll = false,
    .tx_desc_auto_clear = true,
};

i2s_pin_config_t pinConfig = {
    .bck_io_num = BCLK,
    .ws_io_num = LRC,
    .data_out_num = DIN,
    .data_in_num = -1,
};

void writeI2S(const uint8_t* data, size_t len) {
    size_t bytesWritten;
    i2s_write(I2S_NUM_0, data, len, &bytesWritten, portMAX_DELAY);
}

void Glasses::play_audio(uint8_t* buffer) {
    i2s_driver_install(I2S_NUM_0, &i2sConfig, 0, NULL);
    i2s_set_pin(I2S_NUM_0, &pinConfig);
    i2s_set_sample_rates(I2S_NUM_0, 44100);

    const size_t chunkSize = 512; // Adjust this based on your needs and available memory
    size_t bufferSize = sizeof(bufferSize);
    for (size_t i = 0; i < bufferSize; i += chunkSize) {
        size_t chunk = (bufferSize - i < chunkSize) ? (bufferSize - i) : chunkSize;
        writeI2S(&buffer[i], chunk);
    }
}