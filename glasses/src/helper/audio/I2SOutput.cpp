
#include <Arduino.h>
#include "driver/i2s.h"
#include <math.h>
#include <SPIFFS.h>
#include <FS.h>

#include "SampleSource.h"
#include "I2SOutput.h"
#include <I2S.h>

// number of frames to try and send at once (a frame is a left and right sample)
#define NUM_FRAMES_TO_SEND 512

void i2sWriterTask(void *param)
{
    I2SOutput *output = (I2SOutput *)param;
    int availableBytes = 0;
    int buffer_position = 0;
    Frame_t *frames = (Frame_t *)malloc(sizeof(Frame_t) * NUM_FRAMES_TO_SEND);
    while (true)
    {
        // wait for some data to be requested
        i2s_event_t evt;
        if (xQueueReceive(output->m_i2sQueue, &evt, portMAX_DELAY) == pdPASS)
        {
            if (evt.type == I2S_EVENT_TX_DONE)
            {
                size_t bytesWritten = 0;
                do
                {
                    if (availableBytes == 0)
                    {
                        // get some frames from the wave file - a frame consists of a 16 bit left and right sample
                        output->m_sample_generator->getFrames(frames, NUM_FRAMES_TO_SEND);
                        // how maby bytes do we now have to send
                        availableBytes = NUM_FRAMES_TO_SEND * sizeof(uint32_t);
                        // reset the buffer position back to the start
                        buffer_position = 0;
                    }
                    // do we have something to write?
                    if (availableBytes > 0)
                    {
                        // write data to the i2s peripheral
                        /*
                        i2s_write(output->m_i2sPort, buffer_position + (uint8_t *)frames,
                                  availableBytes, &bytesWritten, portMAX_DELAY);
                        */

                        I2S.write(buffer_position + (uint8_t *)frames, availableBytes);
                        
                        availableBytes -= bytesWritten;
                        buffer_position += bytesWritten;
                    }
                } while (bytesWritten > 0);
            }
        }
    }
}

void I2SOutput::start(SampleSource *sample_generator)
{
    m_sample_generator = sample_generator;
    
    // start a task to write samples to the i2s peripheral
    TaskHandle_t writerTaskHandle;
    xTaskCreate(i2sWriterTask, "i2s Writer Task", 4096, this, 1, &writerTaskHandle);
}
