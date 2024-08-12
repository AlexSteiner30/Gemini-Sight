require('dotenv').config({ path: './database/.env' });
const axios = require('axios');
const { Client } = require('@googlemaps/google-maps-services-js');

class GoogleMaps {
  constructor() {
    this.apiKey = process.env.API_KEY;
    this.client = new Client({});
  }

  /**
   * Search for a place given the user location and query
   * 
   * @param {String} query 
   * @param {String} location 
   * @param {*} ws 
   */
  async searchPlaces(query, location, ws) {
    try {
      const params = {
        input: query,
        inputtype: 'textquery',
        key: this.apiKey,
      };

      const response = await this.client.findPlaceFromText({ params });
      let places = response.data.candidates || [];
      
      // If a location is passed add it to the request encoding it
      if (location !== "''") {
        const encodedAddress = encodeURIComponent(location);
        var url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodedAddress}&key=${this.apiKey}`;

        const response = await axios.get(url);
        location = `${response.data.results[0].geometry.location.lat},${response.data.results[0].geometry.location.lng}`;
        
        // Append to nearby responses the first 5 for semplicity
        url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=${this.apiKey}&location=${location}&radius=500&keyword=${encodeURIComponent(query)}`;
        const nearbyResponse = await axios.get(url);
        places = nearbyResponse.data.results.slice(0, 5);
      }

      // Get details about the places
      const placeDetailsList = await Promise.all(places.map(place => this.getPlaceDetails(place.place_id)));
      ws.send(JSON.stringify(placeDetailsList));
    } catch (error) {
      console.error('Error fetching places:', error);
      throw error;
    }
  }

  /**
   * Return address, phone number, name, website of place give its ID using the Google Maps Places API
   * 
   * @param {String} placeId 
   * @returns 
   */
  async getPlaceDetails(placeId) {
    try {
      const url = `https://maps.googleapis.com/maps/api/place/details/json?key=${this.apiKey}&placeid=${placeId}`;
      const response = await axios.get(url);
      const result = response.data.result;

      return {
        address: result.formatted_address || 'N/A',
        phone_number: result.formatted_phone_number || 'N/A',
        name: result.name || 'N/A',
        website: result.website || 'N/A',
      };
    } catch (error) {
      console.error('Error fetching place details:', error);
      throw error;
    }
  }

  async getDirections(origin, destination, ws) {
    try {
      const params = {
        origin,
        destination,
        key: this.apiKey,
      };

      const response = await this.client.directions({ params });
      const route = response.data.routes[0];
      const instructions = route.legs[0].steps.map(step => step.html_instructions.replace(/<[^>]*>/g, '')).join(' ');

      ws.send(instructions);
    } catch (error) {
      console.error('Error fetching directions:', error);
      throw error;
    }
  }
}

module.exports = {
  GoogleMaps
};