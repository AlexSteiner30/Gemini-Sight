const { WebSocketServer } = require('ws');
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
}else{
    const fs = require('fs');
    const axios = require('axios');
    const { Database } = require('./func/db.js');
    const { Audio } = require('./func/audio.js');
    const helper = require('./func/helper.js');
    const { Model } = require('./func/model.js');
    const { Authentication } = require('./func/auth.js');
    const { Stream } = require('./func/stream_song.js');
    const { GoogleMaps } = require('./func/google_maps.js');

    const db = new Database();
    const maps = new GoogleMaps();
    const audio = new Audio('./audio/');
    const ai = new Model();
    const stream = new Stream();
    const auth = new Authentication();

    db.parseData();

    const wss = new WebSocketServer({ port: 443 });
    console.log('Websocket running on port 443');

    wss.on('connection', function connection(ws) {  
        ws.on('message', async function message(data) {
            try {
                const messageParts = data.toString('utf8').split('¬');
                const command = messageParts[0];
                const access_key = messageParts[1];

                if(await db.find('access_key', access_key)){
                    switch (command) {
                        case 'first_time':
                            {
                                const email = messageParts[2];
                                const user = await db.find('email', email);

                                ws.send(user ? "true": "false");
                            }
                            break;

                        case 'add_query':
                            {
                                const data = messageParts[2];
                                var response = await ai.process_data(`Fully summarize this data for me, do not use amy formatting, do not include any expression such as the document includes, just provide the information with no context, furthermore never use ' or " or. Data: ` + data + ' ' + (await db.find('access_key', access_key)).query);
                                const filter = { access_key: access_key };

                                await db.Product.updateOne(filter, { query: response });
                            }
                            break;

                        case 'not_first_time':
                            {
                                const filter = { access_key: access_key };
            
                                await db.Product.updateOne(filter, { first_time: false });
                            }
                            break;

                        case 'speak':
                            {
                                const text = messageParts[2];
                                const uuid = helper.uuidv4();
            
                                const textChunks = text.split('.');
                                var count = 0;
                                for (let chunk of textChunks) {
                                    await audio.pcm(chunk, access_key, count, uuid, ws);
                                    count++;
                                }
                            }
                            break;

                        case 'process':
                            {
                                const text = messageParts[2];
                                const response = await ai.process_data(text);
                                ws.send('r' + response);
                            }
                            break;

                        case 'media':
                            {
                                const base64Data = messageParts[2];
                                const uuid = helper.uuidv4();
                                const dirPath = `./media/${access_key}`;
                                if (!fs.existsSync(dirPath)) {
                                    fs.mkdirSync(dirPath);
                                }
                                fs.writeFileSync(`${dirPath}/${uuid}.png`, Buffer.from(base64Data, 'base64'));
                            }
                            break;

                        case 'vision':
                            {

                                const task = messageParts[2];
                                const base64Data = messageParts[3];
                                const response = await ai.model.generateContent([
                                    task,{ inlineData: { data: Buffer.from(base64Data, 'base64').toString("base64"), mimeType: 'image/png' } }
                                ]);
                                
                                ws.send('v' + response.response.text());
                            }
                            break;

                        case 'directions':
                            {
                                const origin = messageParts[2];
                                const destination = messageParts[3];

                                await maps.getDirections(origin, destination, ws);
                            }
                            break;

                        case 'get_place':
                            {
                                const query = messageParts[2];
                                var location = messageParts[3];

                                const encodedAddress = encodeURIComponent(location);
                                
                                if(location !== ''){
                                    const response = await axios.get(`https://maps.googleapis.com/maps/api/geocode/json?address=${encodedAddress}&key=${process.env.GOOGLE_MAPS_API}`);
                                    if (response.data.status === 'OK') {

                                        location = `${response.data.results[0].geometry.location.lat},${response.data.results[0].geometry.location.lng}`;
                                    }
                                }

                                await maps.searchPlaces(query, location, ws);
                            }
                            break;

                        case 'stream_song':
                            {
                                const query = messageParts[2];
                                await stream.stream_song(query, ws);
                            }
                            break;
    
                        case 'send_data':
                            {   
                                const input = messageParts[2];
                                const additional_query = (await db.find('access_key', access_key)).query;

                                const dateObj = new Date();
                                const year = dateObj.getFullYear();
                                const month = String(dateObj.getMonth() + 1).padStart(2, '0');
                                const day = String(dateObj.getDate()).padStart(2, '0');
                                const hours = String(dateObj.getHours()).padStart(2, '0');
                                const minutes = String(dateObj.getMinutes()).padStart(2, '0');
                                const formattedDate = `${year}-${month}-${day}T${hours}:${minutes}`;

                                const response = await ai.process_input(input + '{' + additional_query + '}' + `[date: ${formattedDate}]`); 
                                ws.send(response);

                                console.log(response);
                            }
                            break;
                    }
                }else{
                    if(command == "authentication"){
                        const idToken = messageParts[1];
                        const email = await auth.verifyIdToken(idToken);
                        const user = await db.find('email', email);
                        ws.send(user ? user.access_key : '');
                    }else{
                        ws.send('Request is not authenticated');
                        ws.close();
                    }
                }
            } catch (err) {
                console.log(err);
                ws.send('Internal server error');
            }
        });
    });
}

cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    cluster.fork();
});