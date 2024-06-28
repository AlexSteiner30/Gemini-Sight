const {OAuth2Client} = require('google-auth-library');
require('dotenv').config({ path: './database/.env' });

class Authentication{
    constructor(){
        this.client = new OAuth2Client(process.env.CLIENT_ID);
    }

    async verifyIdToken(idToken){
        const ticket = await this.client.verifyIdToken({idToken: idToken, audience:process.env.CLIENT_ID});
        const payload = ticket.getPayload();

        return payload['email'];
    }
}

module.exports = {
    Authentication
  };