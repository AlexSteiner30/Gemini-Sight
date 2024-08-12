#include "glasses.hpp"
#include <I2S.h>

#define PIN_I2S_FS  2  //LCK - Word Select
#define PIN_I2S_SCK  3  //BCK - Bit Clock
#define PIN_I2S_SD_OUT  4  //DIN - Data stream

/**
 * Setup output speakers with I2S pins
 */
void Glasses::setup_audio(){
    I2S.setAllPins(PIN_I2S_SCK, PIN_I2S_FS, -1, PIN_I2S_SD_OUT, -1);
    if (!I2S.begin(I2S_PHILIPS_MODE, 16000, 16)) {
        invoke_error("Failed Initializing Audio");
    }
}

/**
 * Play WAV file
 * 
 * @param path wav file path
 */
void Glasses::play_file(char* path){
  SampleSource *sampleSource = new WAVFileReader('/' + path);

  I2SOutput *output = new I2SOutput();
  output->start(sampleSource);
}

/**
 * Play audio buffer on i2s, split it up in chunks of 512 bites, multiply values by the volume
 * 
 * @param buffer audio buffer to play 
 */
void Glasses::play_audio(uint8_t* buffer) {
    const size_t chunkSize = 512;
    size_t bufferSize = sizeof(buffer) / sizeof(buffer[0]);
    for (size_t i = 0; i < bufferSize; i += chunkSize) {
        size_t chunk = (bufferSize - i < chunkSize) ? (bufferSize - i) : chunkSize;

        for (size_t j = 0; j < chunk; j++) {
            int16_t sample = buffer[i + j];  
            sample = static_cast<int16_t>(sample * (volume / 100));
            buffer[i + j] = static_cast<uint8_t>(sample);
        }

        I2S.write(&buffer[i], chunk);
    }
}

/**
 * Change volume
 * 
 * @param volume_input new glasses volume
 * 
 * Limit volume between 0 and 100
 * Send new volume to ble to update app interface
 */
void Glasses::set_volume(string volume_input){
    int volume_temp = stoi(volume_input);
    volume = (volume_temp > 100) ? volume_temp : (volume_temp < 0) ? 0 : volume_temp;

    send_ble((char*)("volume|" + std::string(AUTH_KEY) + "|" + std::to_string(volume)).c_str());
}