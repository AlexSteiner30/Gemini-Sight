const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 9000 });

wss.on('connection', function connection(ws) {
  console.log('Client connected');

  ws.on('message', function incoming(message) {
    try {
      const data = JSON.parse(message);
      console.log(data.pcm);

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


try{
  postData("http://localhost:8000/api/input/", {
    access_key: 'HghVcPRAzR6n1YUiy0rGTX3DoqxgydA',
    input: 'What is three plus three',
    ip: '172.28.16.2'
  }).then(data => {
    console.log(data);
  });
}
catch{
  // request executed no need to report anything -> ws
}