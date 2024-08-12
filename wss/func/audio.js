const wav = require('wav');
const axios = require('axios');
const fs = require('fs');

require('dotenv').config({ path: './database/.env' });

class Audio {
    constructor(path) {
        this.apiKey = process.env.API_KEY;
        this.path = path;
    }

    /**
     * Create PCM values (16Hz) from text using Google's TTS
     * The return generated values chunk by chunk to the ws client
     * 
     * @param {String} input 
     * @param {String} key 
     * @param {int} i 
     * @param {String} uuid 
     * @param {*} ws 
     */
    async pcm(input, key, i, uuid, ws) {
        const path = `${this.path}${key}/${uuid}_${i}.wav`;

        if (!fs.existsSync(`${this.path}${key}`)) {
            fs.mkdirSync(`${this.path}${key}`);
        }

        try{
            const request = {
                audioConfig: {
                audioEncoding: "LINEAR16",
                effectsProfileId: [
                        "small-bluetooth-speaker-class-device"
                ],
                pitch: 0,
                    speakingRate: 1
                },
                input: {
                    text: input
                },
                voice: {
                    languageCode: "en-US",
                    name: "en-US-Journey-O"
                }
            };
            
            const response = await axios.post(
                `https://texttospeech.googleapis.com/v1/text:synthesize?key=${this.apiKey}`,
                request
            );
            
            const audioContent = response.data.audioContent;
            const audioBuffer = Buffer.from(audioContent, 'base64');
            const pcmData = [];

            fs.writeFileSync(path, audioBuffer);

            const reader = new wav.Reader();

            reader.on('data', (chunk) => {
                for (let i = 0; i < chunk.length; i += 2) {
                    const sample = chunk.readInt16LE(i);
                    pcmData.push(sample);
                }         
            });

            reader.on('end',  () => {
                ws.send('p' + pcmData.toString());
            });

            const stream = require('stream');
            const bufferStream = new stream.PassThrough();
            bufferStream.end(audioBuffer);

            bufferStream.pipe(reader);
        }
        catch{
            
        }
    }
}

module.exports = {
    Audio
};