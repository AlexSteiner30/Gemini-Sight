#include <WebSocketsClient.h>
#include <driver/i2s.h>
#include <WiFi.h>

#include <vector>
#include <string>
#include <iostream>

#include <EEPROM.h>

#include <arduinoFFT.h>

#include "helper/wake_word/model.h"

#include "tensorflow/lite/micro/all_ops_resolver.h"
#include "tensorflow/lite/micro/micro_error_reporter.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"

#include <esp_heap_caps.h>

#include <vector>
#include <string>
#include <iostream>

using namespace std;

template <typename T>
struct PSRAMAllocator {
    typedef T value_type;
    PSRAMAllocator() = default;
    template <typename U> PSRAMAllocator(const PSRAMAllocator<U>&) {}
    T* allocate(std::size_t n) {
        return (T*)heap_caps_malloc(n * sizeof(T), MALLOC_CAP_SPIRAM);
    }
    void deallocate(T* p, std::size_t n) {
        heap_caps_free(p);
    }
};

namespace tflite
{
    template <unsigned int tOpCount>
    class MicroMutableOpResolver;
    class ErrorReporter;
    class Model;
    class MicroInterpreter;
} 

struct TfLiteTensor;


using namespace std;

#define LRC 7
#define BCLK 8
#define DIN 9

#define I2S_PORT I2S_NUM_0
 
#define SAMPLE_RATE 16000
#define RECORD_TIME 5
#define SAMPLE_SIZE 2
#define CHANNEL_NUM 1

class Glasses{
  public:
    WebSocketsClient client;

    const char* AUTH_KEY = "9e323100603908714f50f2a254cbf3cab972d40361d83f53dce0d214cc0df1707e1cb0c7c7bd98c4e2135d16abf79527de834abdbeff2ba2bcaa57c82a187dea2306e670a03803374a8d325956961f280350e727e8822f7ae973541f895a6a9e0c5fadc3e15afaa19d583dd50c89ca8d7a8b82713f17d276c4ee4cd5f1831000";

    int volume = 100;

    enum current_state {
      not_connected,
      wake_word,
      speaking
    };

    current_state current_state = not_connected;

    bool is_recording = false;

  private:
    tflite::MicroMutableOpResolver<9> *m_resolver;
    tflite::ErrorReporter *m_error_reporter;
    const tflite::Model *m_model;
    tflite::MicroInterpreter *m_interpreter;
    TfLiteTensor *input;
    TfLiteTensor *output;
    uint8_t *m_tensor_arena;

  public:
      void setup_tf();
      void setup_ble();

      void setup_camera();
      void take_picture();
      void record_video();
      void setup_microphone();
      void record_audio();
      void record_microphone(bool is_listening);
      void play_audio(uint8_t *buffer);

      void set_volume(string volume);

      std::vector<std::vector<double, PSRAMAllocator<double>>, PSRAMAllocator<std::vector<double, PSRAMAllocator<double>>>> get_speech_command();
      int predict(const std::vector<std::vector<double, PSRAMAllocator<double>>, PSRAMAllocator<std::vector<double, PSRAMAllocator<double>>>>& resizedSpectrogram);
      
      void connect_wifi(const char *ssid, const char *password);
      void get_wake_word();

      void invoke_error(const char* err);
      void listen_ble();
      void send_ble(char* payload);

      void save_string(int addrOffset, const string &strToWrite);
      String read_string(int addrOffset);
      vector<string> split(string s, string delimiter);
};