#ifndef GLASSES_H
#define GLASSES_H

#include <WebSocketsClient.h>

#include "helper/audio/audio.h"

#include "helper/helper.hpp"
#include "helper/wake_word/wake_word.h"

class Microphone;
class CameraRecording;
class Glasses
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

  public:
    Glasses();

    WebSocketsClient client;
    const char* AUTH_KEY = "9e323100603908714f50f2a254cbf3cab972d40361d83f53dce0d214cc0df1707e1cb0c7c7bd98c4e2135d16abf79527de834abdbeff2ba2bcaa57c82a187dea2306e670a03803374a8d325956961f280350e727e8822f7ae973541f895a6a9e0c5fadc3e15afaa19d583dd50c89ca8d7a8b82713f17d276c4ee4cd5f1831000";

    bool isConnected = false;
    bool isTalking = false;
    int volume = 100;

    void connect();

  public:
    std::vector<double> get_speech_command();
    void take_picture();

    Audio audio;
    NeuralNetwork nn;
  
  private:
    void i2s_install();
    void i2s_setpin();

    std::vector<double> processAudioData(int16_t* audioBuffer, size_t bufferSize);
    void record_microphone();

};

#endif