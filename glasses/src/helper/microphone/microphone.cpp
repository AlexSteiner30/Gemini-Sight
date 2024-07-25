#include "glasses.hpp"
#include <I2S.h>

void Glasses::setup_microphone(){
  I2S.setAllPins(-1, 42, 41, -1, -1);
  if (!I2S.begin(PDM_MONO_MODE, 16000, 16)) {
    invoke_error("setup_microphone");
  }
}

void Glasses::record_audio(){
  string textMessage = "record_audio¬" + string(AUTH_KEY)+ "¬";

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

void Glasses::record_microphone() 
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

  string textMessage = "speech_to_text¬" + string(AUTH_KEY)+ "¬";

  size_t textSize = textMessage.length();
  size_t totalSize = textSize + SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE;

  uint8_t* combinedBuffer = new uint8_t[totalSize];

  memcpy(combinedBuffer, textMessage.c_str(), textSize);
  memcpy(combinedBuffer + textSize, audioBuffer, SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE);

  client.sendBIN(combinedBuffer, totalSize);

  delete[] combinedBuffer;

  audioBuffer = (int16_t*)malloc(SAMPLE_RATE * RECORD_TIME * SAMPLE_SIZE);

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
          int sample = I2S.read();
          buffer[bytesRead] = (sample && sample != -1 && sample != 1) ? sample : 0;

          bytesRead++;
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