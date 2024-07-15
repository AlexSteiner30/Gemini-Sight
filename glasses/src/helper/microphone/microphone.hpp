#include <driver/i2s.h>
 
#define I2S_WS 2
#define I2S_SCK 14
#define I2S_SD 15
#define I2S_PORT I2S_NUM_0
 
#define SAMPLE_RATE 16000
#define RECORD_TIME 90
#define SAMPLE_SIZE 2
#define CHANNEL_NUM 1
#define TOTAL_SAMPLES (SAMPLE_RATE * RECORD_TIME)

int16_t* audioBuffer = (int16_t*)malloc(TOTAL_SAMPLES * SAMPLE_SIZE);
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