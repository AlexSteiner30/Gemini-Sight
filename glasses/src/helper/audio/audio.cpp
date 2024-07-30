#include "glasses.hpp"

void Glasses::play_file(char* path){
  SampleSource *sampleSource = new WAVFileReader('/' + path);

  I2SOutput *output = new I2SOutput();
  output->start(I2S_NUM_1, i2sPins, sampleSource);
}

void Glasses::play_audio(uint8_t* buffer) {
    const size_t chunkSize = 1024;
    size_t bufferSize = sizeof(bufferSize);
    for (size_t i = 0; i < bufferSize; i += chunkSize) {
        size_t chunk = (bufferSize - i < chunkSize) ? (bufferSize - i) : chunkSize;
        //writeI2S(&buffer[i], chunk);
    }
}

void Glasses::set_volume(string volume){
    int volume_temp = stoi(volume);
    volume = (volume_temp > 100) ? volume_temp : (volume_temp < 0) ? 0 : volume_temp;
}