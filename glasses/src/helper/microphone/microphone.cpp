#include "glasses.hpp"
#include <I2S.h>

void Glasses::setup_microphone(){
  I2S.setAllPins(-1, 42, 41, -1, -1);
  if (!I2S.begin(PDM_MONO_MODE, 16000, 16)) {
    invoke_error("Failed Initializing Microphone");
  }
}

void Glasses::record_audio(){
  string textMessage = "record_audio|" + string(AUTH_KEY)+ "|";

  while(is_recording){
    size_t bytesRead = 0;
    int16_t* audioBuffer = (int16_t*)malloc(SAMPLE_RATE);

    while (bytesRead < SAMPLE_RATE) {
      int sample = I2S.read();
      audioBuffer[bytesRead] = sample ? sample : 0;

      bytesRead++;
    }
    size_t textSize = textMessage.length();
    size_t totalSize = textSize + SAMPLE_RATE * SAMPLE_SIZE;

    uint8_t* combinedBuffer = new uint8_t[totalSize];

    memcpy(combinedBuffer, textMessage.c_str(), textSize);
    memcpy(combinedBuffer + textSize, audioBuffer, SAMPLE_RATE * SAMPLE_SIZE);

    client.sendBIN(combinedBuffer, totalSize);

    delete[] combinedBuffer;

    audioBuffer = (int16_t*)malloc(SAMPLE_RATE * SAMPLE_SIZE);
  }
}

void Glasses::record_microphone(bool is_listening) 
{
  current_state = speaking;

  Serial.println("speaking");

  size_t bytesRead = 0;
  int16_t* audioBuffer = (int16_t*)malloc(SAMPLE_RATE * SAMPLE_SIZE);

  while (bytesRead < SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE && current_state == speaking) {
    int sample = I2S.read();
    audioBuffer[bytesRead] = sample ? sample : 0;

    bytesRead++;
  }

  string textMessage = is_listening ? "listen|" + string(AUTH_KEY)+ "|" : "speech_to_text|" + string(AUTH_KEY)+ "|";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, audioBuffer, SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE);

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;

  audioBuffer = (int16_t*)malloc(SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE);

  Serial.println("sent");

  if(!is_listening)
    get_wake_word();
}

int16_t* Glasses::get_speech_command() {
  int16_t* buffer = (int16_t*)malloc(SAMPLE_RATE * SAMPLE_SIZE);
  size_t bytesRead = 0;


  while (bytesRead < SAMPLE_RATE * SAMPLE_SIZE) {
    int sample = I2S.read();
    buffer[bytesRead] = (sample && sample != -1 && sample != 1) ? sample : 0;

    bytesRead++;
  }

  return buffer;
}