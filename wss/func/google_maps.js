require('dotenv').config({ path: './database/.env' });
const axios = require('axios');


class GoogleMaps{

  constructor(){
    this.apiKey = process.env.GOOGLE_MAPS_API;
  }

  async searchPlaces(query, location, radius) {
    const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=${this.apiKey}&location=${location}&radius=${radius}&keyword=${query}`;

    try {
      const response = await axios.get(url);
      const places = response.data.results.slice(0, 3); 
      const placeDetailsList = [];

      for (const place of places) {
        const placeDetails = await getPlaceDetails(place.place_id);
        placeDetailsList.push(placeDetails);
      }

      return placeDetailsList;
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
}

  (async () => {
  try {
    const searchResults = await searchPlaces('restaurant', '37.7749,-122.4194', 500);
    console.log('Top 3 Search Results:', searchResults);
  } catch (error) {
    console.error('Error:', error);
  }
})();