const yts = require("yt-search");
const ytdl = require('ytdl-core');

class Stream{
    async stream_song(query, ws){
        const songIds = (await yts(query)).videos[0].videoId;
        var pcmData = [];

        const stream = ytdl(`http://www.youtube.com/watch?v=${songIds}`, {
            filter: 'audioonly',
        });

        stream.on('data', (chunk) => {
            pcmData.push(chunk);
        });

        stream.on('end', () => {
            ws.send('p' + pcmData.toString());
        });

        stream.on('error', (err) => {
            console.error('Error occurred:', err);
        });
    }
}

module.exports = {
    Stream
};