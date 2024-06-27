const wav = require('wav');
const PlayHT = require('playht');
const fs = require('fs');
const helper = require('./helper.js');

class Audio {
    constructor(path) {
        PlayHT.init({
            apiKey: '96e73ab231164b3a8cdffb07d02c3092',
            userId: '2FybridC37WMAVXVaTsjomh0GXb2',
            defaultVoiceId: 's3://peregrine-voices/oliver_narrative2_parrot_saad/manifest.json',
            defaultVoiceEngine: 'PlayHT2.0',
        });

        this.path = path;
    }

    async pcm(input, key, i, uuid, ws) {
        const path = `${this.path}${key}/${uuid}_${i}.wav`;

        if (!fs.existsSync(`${this.path}${key}`)) {
            fs.mkdirSync(`${this.path}${key}`);
        }

        const fileStream = fs.createWriteStream(path);

        const stream = await PlayHT.stream(input, {
            voiceEngine: 'PlayHT2.0-turbo',
            voiceId: 's3://voice-cloning-zero-shot/d9ff78ba-d016-47f6-b0ef-dd630f59414e/female-cs/manifest.json',
            outputFormat: 'wav',
        });
        
        return new Promise((resolve, reject) => {
            stream.pipe(fileStream).on('finish', async function () {
                try {
                    const file = fs.createReadStream(path);
                    const reader = new wav.Reader();

                    const pcmData = [];

                    reader.on('data', (chunk) => {
                        for (let i = 0; i < chunk.length; i += 2) {
                            const sample = chunk.readInt16LE(i);
                            pcmData.push(sample);
                        }
                    });

                    reader.on('error', (err) => {
                        console.error('Error reading WAV file:', err);
                    });

                    reader.on('end',  () => {
                        ws.send('p' + pcmData.toString());
                    });

                    file.pipe(reader);
                } catch (error) {
                    reject(error);
                }
            }).on('error', reject);
        });
    }
}

module.exports = {
    Audio
};