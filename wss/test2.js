const fs = require('fs');
const path = require('path');

// Function to parse WAV file and extract PCM data in 8-bit unsigned format
function parseWavFile(filePath, outputFilePath) {
    // Read the WAV file
    const wavBuffer = fs.readFileSync(filePath);

    // Check the RIFF header
    if (wavBuffer.toString('utf8', 0, 4) !== 'RIFF') {
        throw new Error('Invalid WAV file');
    }

    // Check the WAVE header
    if (wavBuffer.toString('utf8', 8, 12) !== 'WAVE') {
        throw new Error('Invalid WAV file');
    }

    // Read the format information
    const format = wavBuffer.readUInt16LE(20);
    const numChannels = wavBuffer.readUInt16LE(22);
    const sampleRate = wavBuffer.readUInt32LE(24);
    const byteRate = wavBuffer.readUInt32LE(28);
    const blockAlign = wavBuffer.readUInt16LE(32);
    const bitsPerSample = wavBuffer.readUInt16LE(34);

    console.log('Format:', format);
    console.log('Channels:', numChannels);
    console.log('Sample Rate:', sampleRate);
    console.log('Byte Rate:', byteRate);
    console.log('Block Align:', blockAlign);
    console.log('Bits per Sample:', bitsPerSample);

    // Find the data chunk
    let offset = 12;
    let chunkSize = 0;
    while (offset < wavBuffer.length) {
        const chunkId = wavBuffer.toString('utf8', offset, offset + 4);
        chunkSize = wavBuffer.readUInt32LE(offset + 4);
        if (chunkId === 'data') {
            offset += 8;
            break;
        }
        offset += 8 + chunkSize;
    }

    // Extract PCM data
    if (chunkSize === 0) {
        throw new Error('Data chunk not found in WAV file');
    }
    const pcmData = wavBuffer.slice(offset, offset + chunkSize);

    // Convert PCM data to an array of 8-bit unsigned samples
    const samples = new Uint8Array(pcmData.length);
    pcmData.copy(samples);

    // Convert samples to a plain text format
    const textData = Array.from(samples).join(','); // Join with newline for readability

    // Save the text data to a file
    fs.writeFileSync(outputFilePath, textData, 'utf8');
    console.log(`PCM data saved as text to ${outputFilePath}`);
}

// Path to your WAV file and output text file
const filePath = path.join('/Users/alex.steiner/Documents/GitHub/Gemini-Sight/wss/', 'boot.wav');
const outputFilePath = path.join('/Users/alex.steiner/Documents/GitHub/Gemini-Sight/wss/', 'pcm_data.txt');

// Parse the WAV file and save PCM data as plain text
parseWavFile(filePath, outputFilePath);
