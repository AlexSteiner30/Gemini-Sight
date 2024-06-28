const fs = require('fs');
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');
const helper = require('./func/helper.js');
const {Model} = require('./func/model.js');
const {Authentication} = require('./func/auth.js');
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
        try{
            if(data.toString('utf8').split('¬')[0] == 'authentication'){
                const idToken = data.toString('utf8').split('¬')[1];
                const email = await auth.verifyIdToken(idToken);
                if(await db.find('email', email)){
                    ws.send((await db.find('email', email)).access_key);
                }
                else{
                    ws.send('');
                }
            }
            else if(data.toString('utf8').split('¬')[0] == 'speak'){
                const access_key = data.toString('utf8').split('¬')[1];
    
                if (await db.find('access_key', access_key)) {
                    const text = data.toString('utf8').split('¬')[2];
                    const uuid = helper.uuidv4();

                    try{
                        for (let i = 0; i < text.match(/.{1,150}/g).length; i++) {
                            //await audio.pcm(text.match(/.{1,150}/g)[i], access_key, i, uuid, ws);
                            ws.send('Audio created'); // FIND OTHER FREE API
                        }
                    }
                    catch{

                        ws.send('Internal server error');
                    }
                } else {
                    ws.send('Use a valid access key in order to access the API');
                }
            }
            else if(data.toString('utf8').split('¬')[0] == 'process'){
                const access_key = data.toString('utf8').split('¬')[1];

                if (await db.find('access_key', access_key)) {
                    try{             
                        const text = data.toString('utf8').split('¬')[2];
                        const response = (await ai.process_data(text));

                        ws.send('r' + response);
                    }
                    catch{
                        ws.send('Internal server error');
                    }
                } else {
                    ws.send('Use a valid access key in order to access the API');
                }
            }
            else if(data.toString('utf8').split('¬')[0] == 'media'){
                const access_key = data.toString('utf8').split('¬')[1];

                if (await db.find('access_key', access_key)) {
                    try{                                   
                        var base64Data = data.toString('utf8').split('¬')[2];
                        const uuid = helper.uuidv4();
                        const path = `./media/${access_key}`;

                        if (!fs.existsSync(`${path}`)) {
                            fs.mkdirSync(`${path}`);
                        }

                        // Decrypt later on safety

                        fs.writeFileSync(`${path}/${uuid}.png`, Buffer.from(base64Data, 'base64'));
                    }
                    catch{
                        ws.send('Internal server error');
                    }
                } else {
                    ws.send('Use a valid access key in order to access the API');
                }
            }
            else if(data.toString('utf8').split('¬')[0] == 'vision'){
                const access_key = data.toString('utf8').split('¬')[1];

                if (await db.find('access_key', access_key)) {
                    try{                                   
                        const task = data.toString('utf8').split('¬')[2];
                        const base64Data = data.toString('utf8').split('¬')[3].toString("base64");

                        const response = await ai.model.generateContent([
                            task,
                            {inlineData: {data: Buffer.from(fs.readFileSync('out.png')).toString("base64"),
                            mimeType: 'image/png'}}]
                            );

                        ws.send('v' + response.response.text());
                    }
                    catch{
                        ws.send('Internal server error');
                    }
                } else {
                    ws.send('Use a valid access key in order to access the API');
                }
            }
            else{
                const access_key = data.toString('utf8').split('¬')[0];
                const input = data.toString('utf8').split('¬')[1];
                
                try {
                    if (await db.find('access_key', access_key)) {
                        const response = (await ai.process_input(input));
                        const uuid = helper.uuidv4();

                        try{
                            console.log(response.split("```dart")[1].split("```")[0]);
                            ws.send(response.split("```dart")[1].split("```")[0]);
                        }
                        catch{
                            try{
                                console.log(response);
                                ws.send(response);
                            }
                            catch{
                                ws.send('Internal server error');
                            }
                        }
                    } else {
                        ws.send('Use a valid access key in order to access the API');
                    }
                } catch (error) {
                    console.error('Error processing request:', error);
                    ws.send('Internal server error');
                }
            }
        }
        catch(err){
            console.log(err);
            ws.send('Wrong connection');
        }
    });
});
