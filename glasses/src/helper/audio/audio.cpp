#include "glasses.hpp"
#include <I2S.h>

#define PIN_I2S_FS  2  //LCK - Word Select
#define PIN_I2S_SCK  3  //BCK - Bit Clock
#define PIN_I2S_SD_OUT  4  //DIN - Data stream

void Glasses::setup_audio(){
    I2S.setAllPins(PIN_I2S_SCK, PIN_I2S_FS, -1, PIN_I2S_SD_OUT, -1);
    if (!I2S.begin(I2S_PHILIPS_MODE, 16000, 16)) {
        invoke_error("Failed Initializing Audio");
    }
}
void Glasses::play_file(char* path){
  SampleSource *sampleSource = new WAVFileReader('/' + path);

  I2SOutput *output = new I2SOutput();
  output->start(I2S_NUM_1, i2sPins, sampleSource);
}

void Glasses::play_audio(uint8_t* buffer) {
    const size_t chunkSize = 512;
    size_t bufferSize = sizeof(bufferSize);
    for (size_t i = 0; i < bufferSize; i += chunkSize) {
        size_t chunk = (bufferSize - i < chunkSize) ? (bufferSize - i) : chunkSize;
        I2S.write(&buffer[i], chunk);
    }
}

void Glasses::set_volume(string volume){
    int volume_temp = stoi(volume);
    volume = (volume_temp > 100) ? volume_temp : (volume_temp < 0) ? 0 : volume_temp;

    send_ble((char*)("volume|" + String(AUTH_KEY) + "|" + std::stoi(volume)).c_str());
}