#ifndef CAMERARECORDING_H
#define CAMERARECORDING_H

#include "camera.hpp"
#include "glasses.h"

class Glasses;
class CameraRecording
{
  private:
    CameraRecording();

  public:
    void take_picture(Glasses glasses);
};

#endif