const wav = require('wav-decoder');
const PlayHT = require('playht');
const fs = require('fs');

class Audio {
    constructor(path) {
        PlayHT.init({
            apiKey: '2df332bcf51246dc8752e1ec9bd88439',
            userId: 'WxRQWevofQgDSIXMKLQXzvSgCcu1',
            defaultVoiceId: 's3://peregrine-voices/oliver_narrative2_parrot_saad/manifest.json',
            defaultVoiceEngine: 'PlayHT2.0',
        });

        this.path = path;
    }

    async pcm(input, key, i, uuid) {
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
                    const buffer = fs.readFileSync(path);
                    const audioData = await wav.decode(buffer);
                    const pcmData = audioData.channelData;

                    resolve(pcmData);
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