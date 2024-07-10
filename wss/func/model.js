const { GoogleGenerativeAI } = require("@google/generative-ai");
const axios = require('axios');
require('dotenv').config({ path: './database/.env' });

class Model {
  constructor() {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    this.model = model;

    const chat = model.startChat({
      history: [
        {
          role: "user",
          parts: [{text: process.env.PAYLOAD}],
        },
        {
          role: "model",
          parts: [{text: "Absolutely! I'm Gemma, your virtual assistant, ready to help you with anything you need. Here's what I can do to assist you today: Manage your schedule: I can add, update, or delete events from your calendar, and retrieve upcoming events. Compose and send emails: I can draft, send, and reply to emails based on your instructions. Navigate and explore: I can find places near you and start navigation for you. Make calls and texts: I can call or text anyone in your contacts list. Record and analyze: I can record your speed or surroundings and analyze them based on your request. Document creation and editing: I can create documents, write to them, or retrieve information from them. Manage tasks: I can add, update, or delete tasks from your to-do list. Let me know how I can help you today!"}],
        },
      ],
      generationConfig: {
        maxOutputTokens: 8192,
      },
    });

    this.chat = chat;

    const speech_to_text_url = `https://speech.googleapis.com/v1/speech:recognize?key=${process.env.API_KEY}`;
    this.speech_to_text_url = speech_to_text_url;
  }

  async process_input(prompt) {
    try {
      const result = await this.chat.sendMessage(prompt);
      const response = await result.response;

      const out = response.text();

      return out;

      // streaming -> split )¬ -> append [] send
    } catch (error) {
      console.error('Error processing input:', error);
      throw error;
    }
  }

  async process_data(prompt) {
    try {
      const result = await this.model.generateContent(prompt);
      const response = await result.response;
      const out = response.text();

      return out;
    } catch (error) {
      console.error('Error processing data:', error);
      throw error;
    }
  }

  async speech_to_text(data){
    const audioBytes = data.toString('base64');

    const requestPayload = {
      audio: {
        content: audioBytes,
      },
      config: {
        encoding: 'LINEAR16',
        sampleRateHertz: 16000,
        languageCode: 'en-US',
      },
    };

    axios.post(this.speech_to_text_url, requestPayload)
    .then(response => {
      const transcription = response.data.results
        .map(result => result.alternatives[0].transcript)
        .join('\n');
      console.log(transcription);
      return transcription;
    })
    .catch(error => {
      return ('Error:', error.response ? error.response.data : error.message);
    });
  }
}

module.exports = {
  Model
};
