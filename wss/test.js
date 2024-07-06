const { Client } = require('@googlemaps/google-maps-services-js');
const readline = require('readline');

const client = new Client({});
const POLLING_INTERVAL = 5000; // Polling interval in milliseconds
const THRESHOLD_DISTANCE = 50; // Distance threshold in meters

let currentStepIndex = 0;
let currentRoute = null;

async function getDirections(origin, destination) {
    try {
        const params = {
            origin: origin,
            destination: destination,
            key: 'AIzaSyBE8n70XnBigOGU34Lhd1YvrBAjs3TAI70',
        };

        const response = await client.directions({
            params: params,
            timeout: 1000,
        });

        return response.data.routes[0];
    } catch (error) {
        console.error('Error fetching directions:', error);
        throw error;
    }
}

function getDistance(pos1, pos2) {
    const R = 6371e3; 
    const lat1 = pos1.lat * Math.PI / 180;
    const lat2 = pos2.lat * Math.PI / 180;
    const deltaLat = (pos2.lat - pos1.lat) * Math.PI / 180;
    const deltaLon = (pos2.lng - pos1.lng) * Math.PI / 180;

    const a = Math.sin(deltaLat / 2) * Math.sin(deltaLat / 2) +
        Math.cos(lat1) * Math.cos(lat2) *
        Math.sin(deltaLon / 2) * Math.sin(deltaLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
}

function isWithinThreshold(currentPosition, polyline) {
    const path = decodePolyline(polyline);
    return path.some(point => getDistance(currentPosition, point) < THRESHOLD_DISTANCE);
}

function decodePolyline(encoded) {
    let points = [];
    let index = 0, len = encoded.length;
    let lat = 0, lng = 0;

    while (index < len) {
        let b, shift = 0, result = 0;
        do {
            b = encoded.charCodeAt(index++) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        let dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
            b = encoded.charCodeAt(index++) - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        let dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        points.push({ lat: lat / 1e5, lng: lng / 1e5 });
    }

    return points;
}

async function checkPositionAndUpdateRoute(currentPosition, destination) {
    if (currentStepIndex >= currentRoute.legs[0].steps.length) {
        console.log('You have arrived at your destination.');
        return true;
    }

    const nextStep = currentRoute.legs[0].steps[currentStepIndex];
    const distanceToNextStep = getDistance(currentPosition, nextStep.start_location);

    if (distanceToNextStep < THRESHOLD_DISTANCE) {
        console.log(`\nStep ${currentStepIndex + 1}: ${nextStep.html_instructions.replace(/<[^>]*>/g, '')}`);
        console.log(`Distance: ${nextStep.distance.text}`);
        console.log(`Duration: ${nextStep.duration.text}`);
        currentStepIndex++;
    } else {
        const isOffCourse = !isWithinThreshold(currentPosition, nextStep.polyline);
        if (isOffCourse) {
            console.log('User has deviated from the route. Recalculating...');
            currentRoute = await getDirections(currentPosition, destination);
            console.log(currentRoute.legs[0].steps[0].html_instructions.replace(/<[^>]*>/g, ''));
            currentStepIndex = 0;
        }
    }

    return false;
}

async function navigate(origin, destination) {
    currentRoute = await getDirections(origin, destination);

    console.log('Starting journey...');

    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });

    async function pollPosition() {
        rl.question('Enter current position as "lat,lng": ', async (input) => {
            const [lat, lng] = input.split(',').map(Number);
            const currentPosition = { lat, lng };

            const hasArrived = await checkPositionAndUpdateRoute(currentPosition, destination);

            if (!hasArrived) {
                setTimeout(pollPosition, POLLING_INTERVAL);
            } else {
                rl.close();
            }
        });
    }

    pollPosition();
}

const origin = 'Strada San Michele 150 Borgo Maggiore';
const destination = 'Bounty Rimini Italy';

navigate(origin, destination);
