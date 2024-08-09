const { WebSocketServer } = require('ws');
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
  for (let i = 0; i < numCPUs; i++) {
    cluster.fork();
  }
}else{
  const { Database } = require('./func/db.js');
  const { Audio } = require('./func/audio.js');
  const { Model } = require('./func/model.js');
  const { Authentication } = require('./func/auth.js');
  const { Stream } = require('./func/stream_song.js');
  const { Session } = require('./func/session.js');
  const { GoogleMaps } = require('./func/google_maps.js');

  const db = new Database();
  const maps = new GoogleMaps();
  const audio = new Audio('./audio/');
  const ai = new Model();
  const stream = new Stream();
  const auth = new Authentication();
    
  let sessions = new Map();

  const wss = new WebSocketServer({ port: process.env.PORT || 4000 });
  console.log('Websocket running!');

  wss.on('connection', function connection(ws) {  
    ws.on('message', async function message(data) {
      try {
        const messageParts = data.toString('utf8').split('¬');
        const command = messageParts[0];
        const access_key = messageParts[1];

        ws.access_key = access_key;

        if(!sessions.get(access_key)){
          let new_session = new Session(access_key, db, maps, audio, ai, stream, ws);
          sessions.set(access_key, new_session)
        }

        if(await db.find('access_key', access_key)){
          const active_session = sessions.get(access_key);

          switch (command) {
            case 'first_time': active_session.first_time(messageParts); break;
            case 'ble_id': active_session.ble_id(messageParts); break;
            case 'auth_code': active_session.auth_code(messageParts); break;
            case 'get_auth_code': active_session.get_auth_code(messageParts); break;
            case 'get_refresh_token': active_session.get_refresh_token(messageParts); break;
            case 'get_display_name': active_session.get_display_name(messageParts); break;
            case 'add_query': active_session.add_query(messageParts); break;
            case 'not_first_time': active_session.not_first_time(messageParts); break;
            case 'speak': active_session.speak(messageParts); break;
            case 'process': active_session.process(messageParts); break;
            case 'vision': active_session.vision(messageParts); break;
            case 'directions': active_session.directions(messageParts); break;
            case 'get_place': active_session.get_place(messageParts); break;
            case 'stream_song': active_session.stream_song(messageParts); break;
            case 'send_data': active_session.send_data(messageParts); break;
          }
        }else{
          if(command == "authentication"){
            if(messageParts.length == 2){
              const idToken = messageParts[1];
              const email = await auth.verifyIdToken(idToken);
              const user = await db.find('email', email);
              ws.send(user ? user.access_key : '');
            }
          }else{
            console.log('Request is not authenticated');
            ws.send('Request is not authenticated');
            ws.close();
          }
        }
      } catch (err) {
          console.log(err);
          ws.send('Internal server error');
      }
    });

    ws.on('close', () => {
      sessions.delete(ws.access_key);
    });
  });
}

cluster.on('exit', (worker, code, signal) => {
  console.log(`Worker ${worker.process.pid} died`);
  cluster.fork();
});