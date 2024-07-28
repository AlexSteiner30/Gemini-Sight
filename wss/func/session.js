const querystring = require('querystring');
const axios = require('axios');
const helper = require('./helper.js')
class Session{
    constructor(access_key, db, maps, audio, ai, stream, ws){
        this.access_key = access_key;
        this.db = db;
        this.maps = maps;
        this.audio = audio;
        this.ai = ai;
        this.stream = stream;
        this.ws = ws;
    }

    async first_time(messageParts){
        if(messageParts.length == 3){
            const email = messageParts[2];
            this.ws.send((await this.db.find('email', email)).first_time ? "true": "false");
        }
    }
    
    async ble_id(messageParts){
        this.ws.send((await this.db.find('access_key', this.access_key)).ble_id);
    }
    
    async auth_code(messageParts){
        if(messageParts.length == 3){
            const auth_code = messageParts[2];
        
            const response = await axios.post('https://oauth2.googleapis.com/token',querystring.stringify({'client_id': process.env.CLIENT_ID,'client_secret': process.env.CLIENT_SECRET,'code': auth_code,'grant_type': 'authorization_code'}),{headers: {'Content-Type': 'application/x-www-form-urlencoded'}});
        
            const refresh_key = response.data.refresh_token;
            const filter = { access_key: this.access_key };
        
            await this.db.Order.updateOne(filter, { refresh_key: refresh_key});
        
            this.ws.send('Refresh key was successful');
        }
    }
    
    async get_auth_code(messageParts){
        if(messageParts.length == 3){
            const refresh_key = messageParts[2];
        
            const params = new URLSearchParams();
            params.append('client_id', process.env.CLIENT_ID);
            params.append('client_secret', process.env.CLIENT_SECRET);
            params.append('refresh_token', refresh_key);
            params.append('grant_type', 'refresh_token');
        
            const response = await axios.post('https://oauth2.googleapis.com/token', params,{headers: {'Content-Type': 'application/x-www-form-urlencoded',}});
            
            this.ws.send(response.data.access_token);
        }
    }
    
    
    async get_refresh_token(messageParts){
        this.ws.send((await this.db.find('access_key', this.access_key)).refresh_key);
    }
    
    async get_display_name(messageParts){
        this.ws.send((await this.db.find('access_key', this.access_key)).name);
    }
    
    async add_query(messageParts){
        if(messageParts.length == 3){
            const data = messageParts[2];
        
            var response = await this.ai.process_data(`${data + (await this.db.find('access_key', this.access_key)).query} Represent the full data in a json provide all necessary information and reply only with that. You can use this as a reference ${process.env.QUERY_PAYLOAD}`);
            const filter = { access_key: this.access_key };
        
            await this.db.Order.updateOne(filter, { query: response});
        }
    }
    
    async not_first_time(messageParts){
        const filter = { access_key: this.access_key };        
        await this.db.Order.updateOne(filter, { first_time: false });
    }
    
    async speak(messageParts){
        this.ws.send((await this.db.find('access_key', this.access_key)).name);
    }
    
    async speak(ws,access_key, messageParts){
        this.ws.send((await this.db.find('access_key', this.access_key)).name);
    }
    
    async speak(ws,access_key, messageParts){
        this.ws.send((await this.db.find('access_key', this.access_key)).name);
    }
    
    async speak(messageParts){
        if(messageParts.length == 3){
            const text = messageParts[2];
            const uuid = helper.uuidv4();
        
            const textChunks = text.split('. ');
            for (var i=0; i < textChunks.length; i++) {
                await audio.pcm(textChunks[i], this.access_key, i, uuid, ws);
            }
        }
    }
    
    async process(messageParts){
        if(messageParts.length == 3){
            const text = messageParts[2];
            const response = await this.ai.process_data(text);
            this.ws.send('r' + response);
        }
    }
    
    async vision(messageParts){
        if(messageParts.length == 4){
            const task = messageParts[2];
            const base64Data = messageParts[3];
            const response = await this.ai.model.generateContent([
                task,{ inlineData: { data: Buffer.from(base64Data, 'base64').toString("base64"), mimeType: 'image/png' } }
            ]);
            
            this.ws.send('v' + response.response.text());
        }
    }
    
    async directions(messageParts){
        if(messageParts.length == 4){
            const origin = messageParts[2];
            const destination = messageParts[3];
        
            await maps.getDirections(origin, destination, ws);
        }
    }
    
    async get_place(messageParts){
        if(messageParts.length == 4){
            const query = messageParts[2];
            var location = messageParts[3];
        
            const encodedAddress = encodeURIComponent(location);
            
            if(location !== ''){
                const response = await axios.get(`https://maps.googleapis.com/maps/api/geocode/json?address=${encodedAddress}&key=${process.env.GOOGLE_MAPS_API}`);
                if (response.data.status === 'OK') {
                    location = `${response.data.results[0].geometry.location.lat},${response.data.results[0].geometry.location.lng}`;
                }
            }
        
            await maps.searchPlaces(query, location, ws);
        }   
    }
    
    async stream_song(messageParts){
        if(messageParts.length == 3){
            const query = messageParts[2];
            await this.stream.stream_song(query, ws, this.access_key);
        }
    }
    
    async send_data(messageParts){
        if(messageParts.length == 3){
            const input = messageParts[2];
            console.log(input);
            const additional_query = (await this.db.find('access_key', this.access_key)).query;
        
            const response = await sessions.get(this.access_key).additional_query == additional_query ? await sessions.get(this.access_key).ai.process_input(input) : await sessions.get(this.access_key).ai.process_input(input + '{' + additional_query + '}'); 
            this.ws.send(response);
        }
    }
}

module.exports = {
    Session
};
  