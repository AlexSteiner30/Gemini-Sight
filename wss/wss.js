const fs = require('fs');
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');
const helper = require('./func/helper.js');
const { Model } = require('./func/model.js');
const { Authentication } = require('./func/auth.js');
const path = require("path");
const { WebSocketServer } = require('ws');

const db = new Database();
const audio = new Audio('./audio/');
const ai = new Model();
const auth = new Authentication();

db.parseData();

const wss = new WebSocketServer({ port: 9000 });
console.log('Websocket running on port 9000');

wss.on('connection', function connection(ws) {  
    ws.on('message', async function message(data) {
        try {
            const messageParts = data.toString('utf8').split('¬');
            const command = messageParts[0];

            switch (command) {
                case 'authentication':
                    {
                        const idToken = messageParts[1];
                        const email = await auth.verifyIdToken(idToken);
                        const user = await db.find('email', email);
                        ws.send(user ? user.access_key : '');
                    }
                    break;

                case 'speak':
                    {
                        const access_key = messageParts[1];
                        if (await db.find('access_key', access_key)) {
                            const text = messageParts[2];
                            const uuid = helper.uuidv4();
                            try {
                                const textChunks = text.match(/.{1,150}/g) || [];
                                for (let chunk of textChunks) {
                                    // await audio.pcm(chunk, access_key, i, uuid, ws);
                                    ws.send('Audio created'); // FIND OTHER FREE API
                                }
                            } catch {
                                ws.send('Internal server error');
                            }
                        } else {
                            ws.send('Use a valid access key in order to access the API');
                        }
                    }
                    break;

                case 'process':
                    {
                        const access_key = messageParts[1];
                        if (await db.find('access_key', access_key)) {
                            try {
                                const text = messageParts[2];
                                const response = await ai.process_data(text);
                                ws.send('r' + response);
                            } catch {
                                ws.send('Internal server error');
                            }
                        } else {
                            ws.send('Use a valid access key in order to access the API');
                        }
                    }
                    break;

                case 'media':
                    {
                        const access_key = messageParts[1];
                        if (await db.find('access_key', access_key)) {
                            try {
                                const base64Data = messageParts[2];
                                const uuid = helper.uuidv4();
                                const dirPath = `./media/${access_key}`;
                                if (!fs.existsSync(dirPath)) {
                                    fs.mkdirSync(dirPath);
                                }
                                fs.writeFileSync(`${dirPath}/${uuid}.png`, Buffer.from(base64Data, 'base64'));
                            } catch {
                                ws.send('Internal server error');
                            }
                        } else {
                            ws.send('Use a valid access key in order to access the API');
                        }
                    }
                    break;

                case 'vision':
                    {
                        const access_key = messageParts[1];
                        if (await db.find('access_key', access_key)) {
                            try {
                                const task = messageParts[2];
                                const base64Data = messageParts[3];
                                const response = await ai.model.generateContent([
                                    task,
                                    { inlineData: { data: Buffer.from(base64Data, 'base64').toString("base64"), mimeType: 'image/png' } }
                                ]);
                                ws.send('v' + response.response.text());
                            } catch {
                                ws.send('Internal server error');
                            }
                        } else {
                            ws.send('Use a valid access key in order to access the API');
                        }
                    }
                    break;

                default:
                    {
                        const access_key = command;
                        const input = messageParts[1];
                        try {
                            if (await db.find('access_key', access_key)) {
                                const response = await ai.process_input(input);
                                const uuid = helper.uuidv4();
                                try {
                                    const result = response.split("```dart")[1].split("```")[0];
                                    console.log(result);
                                    ws.send(result);
                                } catch {
                                    console.log(response);
                                    ws.send(response);
                                }
                            } else {
                                ws.send('Use a valid access key in order to access the API');
                            }
                        } catch (error) {
                            console.error('Error processing request:', error);
                            ws.send('Internal server error');
                        }
                    }
                    break;
            }
        } catch (err) {
            console.log(err);
            ws.send('Wrong connection');
        }
    });
});
