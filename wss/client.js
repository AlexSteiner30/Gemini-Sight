const WebSocket = require('ws');
const ws = new WebSocket('ws://192.168.88.12:4040/ws');

// message authentication_key¬authentication_header¬data
const authentication_header = "{Authorization: Bearer ya29.a0AXooCgszm_HyBKUZtPrX8jOV5-CHHl65uKZIWFx3GwMXC-8YsLJRDq3y-mTztIGRIhnF6ekQPSa3OPftDzg0LspL-OF-E69_Og3WR4kdc1TSe67tOh4mjMZYdv1RxWgiszdB-LQiabkuitvpJGQOQnsoBKBZtXrU2FayaCgYKAaASARMSFQHGX2Miswjhff8M84uZtBC37eG54A0171, X-Goog-AuthUser: 0}";
const authentication_key = "dpVYZBSFPRcHd9yGCNDzQT3mHDDEVv54seSNiv6KovFb8Qfw54zMPBzIZ0RAUSHOgOKgdeECEaWqi6hoEy6Vkk2P5rexd5fPVNTrIUEqmo8R7TAxU4eCCJSS8ZPMa9HbMbiFAYpmY2ewZGFMaQf6b0qPJeOrCxXLeXIDjEBXQDGgYgXC4cie9qZhMwkQjEsaP01EXlqR";

ws.on('open', function open() {
  console.log('Connected to WebSocket server');
  
  ws.send(`${authentication_header}¬${authentication_key}`);
  ws.send(`${authentication_header}¬${authentication_key}¬Write an email to alex.steiner@student.h-is.com saying okay`);
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
