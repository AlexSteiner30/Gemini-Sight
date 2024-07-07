#include <driver/i2s.h>

#define I2S_SD 14
#define I2S_WS 12
#define I2S_SCK 13
#define I2S_PORT I2S_NUM_0

#define bufferCnt 10
#define bufferLen 1024
int16_t sBuffer[bufferLen];