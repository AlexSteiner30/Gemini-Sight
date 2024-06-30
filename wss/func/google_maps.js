require('dotenv').config({ path: './database/.env' });
const axios = require('axios');
const { Client } = require('@googlemaps/google-maps-services-js');

class GoogleMaps{
  constructor(){
    this.apiKey = process.env.GOOGLE_MAPS_API;
    this.client = new Client({});
  }

  async searchPlaces(query, location, ws) {
    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=${this.apiKey}&location=${location}&radius=500&keyword=${encodeURIComponent(query)}`;
    var places;
    try {
      await this.client
      .findPlaceFromText({
        params: {
          input: query, 
          inputtype: "textquery",
          key: this.apiKey,
        },
      })
      .then(async (response) =>  {
        if(response.data && response.data.candidates && response.data.candidates.length > 0)
          places = location == '' ? response.data.candidates : (await axios.get(url)).data.results.slice(0, 3);
        else
          places = (await axios.get(url)).data.results.slice(0, 3);

        const placeDetailsList = [];
    
        for (const place of places) {
          const placeDetails = await this.getPlaceDetails(place.place_id);
          placeDetailsList.push(placeDetails);
        }
    
        console.log(JSON.stringify(placeDetailsList));
    
        ws.send(JSON.stringify(placeDetailsList));
      })

    } catch (error) {
      console.error('Error fetching places:', error);
      throw error;
    }
  }
  
  async getPlaceDetails(placeId) {
    const url = `https://maps.googleapis.com/maps/api/place/details/json?key=${this.apiKey}&placeid=${placeId}`;

    try {
      const response = await axios.get(url);
      const result = response.data.result;
      const placeInfo = {
        address: result.formatted_address || 'N/A',
        phone_number: result.formatted_phone_number || 'N/A',
        name: result.name || 'N/A',
        website: result.website || 'N/A',
      };

      return placeInfo;
    } catch (error) {
      console.error('Error fetching place details:', error);
      throw error;
    }
  }

  // google maps integration
  // client request 
  // origin
  // destination
  // ws send next two
  // client parse
  // request another one
  // printe first if different or closer than 50 m and didnt call yet
  // if different print error route 
  // new route
  // if equal to done stop

  async getDirections(origin, destination, ws) {
      try {
          const params = {
              origin: origin,  
              destination: destination,  
              key: this.apiKey,
          };

          const response = await this.client.directions({
              params: params
          });

          const route = response.data.routes[0];

          //ws.send(`Distance: ${route.legs[0].distance.text} Duration: ${route.legs[0].duration.text}`);
          ws.send(`${route.legs[0].steps[0].html_instructions.replace(/<[^>]*>/g, '')}¬${route.legs[0].steps[1].html_instructions.replace(/<[^>]*>/g, '') == null ? 'Arrived' : route.legs[0].steps[1].html_instructions.replace(/<[^>]*>/g, '')} `);

      } catch (error) {
          console.error('Error fetching directions:', error);
      }
  }
}

module.exports = {
  GoogleMaps
};