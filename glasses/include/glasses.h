#ifndef __Glasses__
#define __Glasses__

#include <WebSocketsClient.h>

#include "helper/microphone/microphone.h"
#include "helper/camera/camera_recording.h"
#include "helper/audio/audio.h"

#include "helper/wifi.hpp"
#include "helper/helper.hpp"

#include "helper/wake_word/wake_word.h"

class Glasses
{
  public:
    WebSocketsClient client;
    const char* AUTH_KEY = "9e323100603908714f50f2a254cbf3cab972d40361d83f53dce0d214cc0df1707e1cb0c7c7bd98c4e2135d16abf79527de834abdbeff2ba2bcaa57c82a187dea2306e670a03803374a8d325956961f280350e727e8822f7ae973541f895a6a9e0c5fadc3e15afaa19d583dd50c89ca8d7a8b82713f17d276c4ee4cd5f1831000";

    bool isConnected = false;
    bool isTalking = false;
    int volume = 100;

    void webSocketEvent(WStype_t type, uint8_t *payload, size_t length);
    void connect();

    CameraRecording camera_recording;
    Microphone microphone;
    Audio audio;
};

#endif