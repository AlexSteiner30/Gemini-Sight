const fs = require('fs');
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');
const helper = require('./func/helper.js');
const { Model } = require('./func/model.js');
const { Authentication } = require('./func/auth.js');
const path = require("path");
const { WebSocketServer } = require('ws');
const { query } = require('express');

const db = new Database();
const audio = new Audio('./audio/');
const ai = new Model();
const auth = new Authentication();

db.parseData();

const wss = new WebSocketServer({ port: 443 });
console.log('Websocket running on port 443');

wss.on('connection', function connection(ws) {  
    console.log(ws._socket.remoteAddress);
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

                            response = response.replace(',', '');
                            response = response.replace('"', '');
                            response = response.replace("'", '');
                            response = response.replace("\n", '');
                            response = response.replace("\\", '');

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
          
                            const textChunks = text.match(/.{1,150}/g) || [];
                            for (let chunk of textChunks) {
                                // await audio.pcm(chunk, access_key, i, uuid, ws);
                                 ws.send('Audio created'); // FIND OTHER FREE API
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

                    case 'send_data':
                        {   
                            const input = messageParts[2];
                            const additional_query = (await db.find('access_key', access_key)).query;
                            const response = await ai.process_input(input + '{' + additional_query + '}'); 
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
