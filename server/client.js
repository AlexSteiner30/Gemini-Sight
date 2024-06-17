const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 9000 });

wss.on('connection', function connection(ws) {
  console.log('Client connected');

  ws.on('message', function incoming(message) {
    try {
      const data = JSON.parse(message);
      console.log(data.pcm);

      // play pcm

      ws.send(JSON.stringify({ response: 'Done' }));
    } catch (error) {
      console.error('Error parsing message:', error);
    }
  });
});

console.log('WebSocket Server running on port 9000');

async function postData(url = '', data = {}) {
  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });
  return response.json();
}

postData("http://localhost:8000/api/input/", {
  access_key: 'HghVcPRAzR6n1YUiy0rGTX3DoqxgydA',
  input: 'Come up with a product name for a new app that helps people learn how to play the violin.',
  ip: '172.28.16.2'
}).then(data => {
  console.log(data);
});