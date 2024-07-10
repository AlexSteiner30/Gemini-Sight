const WebSocket = require('ws');
const readline = require('node:readline');

const ws = new WebSocket('ws://localhost:4040/ws');
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const authentication_key = "peJ0AMmumNwHwk3U6IMcRqtLqFWO0Ao9oT3BaijuZA1s5f5NqPyvPnhyAGVPV8Kh64HxcNiux3Rq2lS6qMI6IhGztPPsvrahqux4MsxikyHCCPDsazVxJln7hJfDa4J2";

ws.onopen = async () => {
    console.log('Client connected');
    ws.send(authentication_key);
    await new Promise(resolve => setTimeout(resolve, 1000));
    promptUserInput();
};

ws.onmessage = async (message) => {
  console.log(`Gemma: ${message.data}`);

  promptUserInput();
};

function promptUserInput() {
  rl.question('You: ', (input) => {
    ws.send(`${authentication_key}¬Hey Gemma, ${input}`);
  });
}
