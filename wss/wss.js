const express = require('express');
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');
const helper = require('./func/helper.js');
const {Model} = require('./func/model.js');
const path = require("path");
const { WebSocketServer } = require('ws');

const app = express();
const db = new Database();
const audio = new Audio('./audio/');
const ai = new Model();


const wss = new WebSocketServer({ port: 9000 });
console.log('Websocket running on port 9000');

wss.on('connection', function connection(ws) {
    console.log('New conn')
  ws.on('message', async function message(data) {
    try{
        console.log(data.toString('utf8'));

        const access_key = data.toString('utf8').split(',')[0];
        const input = data.toString('utf8').split(',')[1];
        const ip = data.toString('utf8').split(',')[3];
    
        try {
            await db.parseData();
            
            if (db.find('access_key', access_key)) {
                //const response = await ai.process_input(input);
                const response = "test";
                const uuid = helper.uuidv4();
    
                for (let i = 0; i < response.match(/.{1,150}/g).length; i++) {
                    await audio.pcm(response.match(/.{1,150}/g)[i], access_key, i, uuid, ip);
                }
            } else {
                ws.send({ 'response': 'Use a valid access key in order to access the API' });
            }
        } catch (error) {
            console.error('Error processing request:', error);
            ws.send({ 'error': 'Internal server error' });
        }
    }
    catch{
        ws.send('Wrong connection');
    }
  });
});
