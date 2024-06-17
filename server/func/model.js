const { GoogleGenerativeAI } = require("@google/generative-ai");
require('dotenv').config({ path: './database/.env' });

class Model{
  constructor(){
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash"});
    this.model = model
  }

  async process_input(input) {
    try {
      const result = await this.model.generateContent(input);
      const response = await result.response;
      const out = await response.text();
  
      return out;
    } catch (error) {
      console.error('Error processing input:', error);
      throw error;
    }
  }
}

module.exports = {
  Model
};