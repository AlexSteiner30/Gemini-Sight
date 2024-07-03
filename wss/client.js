const WebSocket = require('ws');
const ws = new WebSocket('ws://localhost:4040/ws');

// message authentication_key¬authentication_header¬data
const authentication_header = "{Authorization: Bearer ya29.a0AXooCguyy5eXEGMlOok7iZ6qEvVOMxWbP6gN18zt0Rfs8BFC6t4mNuH1wkxHq8-kkaWZnlcyXtsR2b_ChgFrayMB0hKHI_v4ooufPTgaC6hxmvV-OPKr8eVaUIzBv21wIZvyrZdqTF3AX7b5yMxi7gnG3o0wpseMzYT3vQaCgYKAZISARMSFQHGX2Mi9cHhKqNJv-3pWIlq87Xk3A0173, X-Goog-AuthUser: 0}";
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
