const {OAuth2Client} = require('google-auth-library');
require('dotenv').config({ path: './database/.env' });

class Authentication{
    constructor(){
        this.client = new OAuth2Client(process.env.CLIENT_ID);
    }
    
    /** Verifies the user when asking for authentication key via google auth library given the client id
     * 
     * @param {String} idToken 
     * @returns verifcation payload
     */
    async verifyIdToken(idToken){
        const ticket = await this.client.verifyIdToken({idToken: idToken, audience:process.env.CLIENT_ID});
        const payload = ticket.getPayload();

        return payload['email'];
    }
}

module.exports = {
    Authentication
  };