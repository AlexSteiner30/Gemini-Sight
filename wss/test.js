const { Client } = require('@googlemaps/google-maps-services-js');

const client = new Client({});

async function getDirections() {
    try {
        const params = {
            origin: 'Strada San Michele 150 Borgo Maggiore',  
            destination: 'Bounty Rimini Italy',  
            key: '',
        };

        const response = await client.directions({
            params: params,
            timeout: 1000, 
        });

        const route = response.data.routes[0];
            console.log(`Distance: ${route.legs[0].distance.text}`);
            console.log(`Duration: ${route.legs[0].duration.text}`);
            console.log('Steps:');
            route.legs[0].steps.forEach((step, stepIndex) => {
                console.log(step.distance['value']);
                console.log(`${stepIndex + 1}. ${step.html_instructions.replace(/<[^>]*>/g, '')}`);
            });
            console.log('-----------------------');

    } catch (error) {
        console.error('Error fetching directions:', error);
    }
}

getDirections();


/*

const ytdl = require('ytdl-core');
const fs = require('fs');

const videoId = 'XNpGNykVZ6U'; // Replace with the ID of the YouTube video you want to stream

const stream = ytdl(`http://www.youtube.com/watch?v=${videoId}`, {
  quality: 'highest',
});

stream.on('data', (chunk) => {
  console.log('Received chunk of data:', chunk);
});

stream.on('end', () => {
  console.log('Streaming ended.');
});

stream.on('error', (err) => {
  console.error('Error occurred:', err);
});
*/