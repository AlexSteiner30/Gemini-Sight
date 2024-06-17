const express = require('express');
const bodyParser = require('body-parser')
const helper = require('./func/helper.js')
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');

const app = express();
const db = new Database('./database/key_access.json')
const audio = new Audio('./audio/');
const PORT = 8000;

app.set('view engine', 'ejs');
app.use(express.json());

app.get('/', function(req, res){
    res.render('index');
});

app.post('/api/input/', async function(req, res){
    if(db.find('access_key', req.body.access_key)){
        var input = req.body.input;
        // run model
        var response = "I'd be glad to help! 3 plus 3 equals 6.";
        var uuid = helper.uuidv4();

        for(var i=0; i<response.match(/.{1,150}/g).length; i++){
            var path = './audio/' + req.body.access_key + '/' + uuid + '_' + i + '.wav';

            await audio.pcm(response.match(/.{1,150}/g)[i], req.body.access_key, i, uuid);
        }

        var hz = 128;

        res.send({'response': '127 275 589 382'});
    }else{
        res.send({'response': 'Use a valid access key in order to access the API'});
    }
});

app.listen(PORT, function(){
    console.log(`Server running on port ${PORT}`);
});