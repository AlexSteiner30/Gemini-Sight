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
    access_key: 'e6c2ce4f-7736-46f6-9693-6cb104c42b10',
    input: 'What is three plus three',
    ip: '172.20.10.2'
  }).then(data => {
    console.log(data);
  });
}
catch{
  // request executed no need to report anything -> ws
}