// Create a new WebSocket instance
const socket = new WebSocket('ws://geminisight-3b0d77438896.herokuapp.com:4000');

// Event handler for when the connection is open
socket.addEventListener('open', function (event) {
    console.log('WebSocket is connected.');
    // You can send data to the server here if needed
    socket.send('Hello Server!');
});

// Event handler for when a message is received from the server
socket.addEventListener('message', function (event) {
    console.log('Message from server:', event.data);
});

// Event handler for when an error occurs
socket.addEventListener('error', function (event) {
    console.error('WebSocket error:', event);
});

// Event handler for when the connection is closed
socket.addEventListener('close', function (event) {
    console.log('WebSocket connection closed.');
});
