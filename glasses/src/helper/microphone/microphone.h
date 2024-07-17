#ifndef __Microphone__
#define __Microphone__

#include <driver/i2s.h>
#include <vector>

#include "glasses.h"

class Microphone
{
  public:
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

        void i2s_install();
        void i2s_setpin();

    public:
        std::vector<double> processAudioData(int16_t* audioBuffer, size_t bufferSize);
        std::vector<double> get_speech_command(Glasses glasses);

        void record_microphone(Glasses glasses);
};

#endif