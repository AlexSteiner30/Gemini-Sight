import wave
import os

def wav_to_header(input_file, output_file):
    with wave.open(input_file, 'rb') as wav_file:
        # Read the WAV file data
        n_channels, sampwidth, framerate, n_frames, _, _ = wav_file.getparams()
        frames = wav_file.readframes(n_frames)

    # Create a C header file
    with open(output_file, 'w') as header_file:
        header_file.write(f"const unsigned int wav_size = {len(frames)};\n")
        header_file.write("const unsigned char wav_data[] PROGMEM = {\n")
        
        # Write the byte array data
        for i, byte in enumerate(frames):
            if i % 12 == 0:
                header_file.write("    ")
            header_file.write(f"0x{byte:02x},")
            if i % 12 == 11:
                header_file.write("\n")
        
        if len(frames) % 12 != 0:
            header_file.write("\n")
        
        header_file.write("};\n")

    print(f"Header file created: {output_file}")

# Usage
input_wav = "boot.wav"
output_header = "wav_data.h"

wav_to_header(input_wav, output_header)