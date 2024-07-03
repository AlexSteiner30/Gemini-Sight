const WebSocket = require('ws');

const ws = new WebSocket('ws://localhost:4040/ws');

ws.on('open', function open() {
  console.log('Connected to WebSocket server');
  
  // Send messages to the server
  ws.send('Hello, Server!');
  ws.send('How are you?');
});

ws.on('message', function incoming(message) {
  console.log(`Received from server: ${message}`);
});

ws.on('close', function close() {
  console.log('WebSocket connection closed');
});

ws.on('error', function error(err) {
  console.error(`WebSocket error: ${err}`);
});
