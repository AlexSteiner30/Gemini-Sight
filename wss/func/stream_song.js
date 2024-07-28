const yts = require("yt-search");
const ytdl = require('ytdl-core');

class Stream{
    async stream_song(query, ws, access_key){
        const videos = (await yts(query)).videos

        if(videos.length > 0){
            const songIds = videos[0].videoId;

            const stream = ytdl(`http://www.youtube.com/watch?v=${songIds}`, {
                filter: 'audioonly',
            });

            stream.on('data', (chunk) => {
                ws.send(`play¬${access_key}¬${chunk.toString()}`);
            });

            stream.on('end', () => {

            });

            stream.on('error', (err) => {
                console.error('Error occurred:', err);
            });
        }
        else{
            ws.send(`error¬${access_key}¬No song named ${query} was found`);
        } 
    }
}

module.exports = {
    Stream
};