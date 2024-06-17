const express = require('express');
const helper = require('./func/helper.js')
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');

const app = express();
const db = new Database();
const audio = new Audio('./audio/');
const PORT = 8000;

app.set('view engine', 'ejs');
app.use(express.json());

app.get('/', function(req, res){
    res.render('index');
});

app.post('/api/input/', async function(req, res){
    const access_key = "uhv3Mu2Jo1CbTiNnetXbYdPfZdy4m93oWRYVej4eD1rmkIpgKDzNh8tT8Jn4BooNFcyBP8Dx34NQ2rzyzYKhleMDdYptC39kGjFqYWYEkycdMNhwSr7sLpQhEMyLAx2E";

    db.parseData().then(() => {
        const result = db.find('access_key', 'uhv3Mu2Jo1CbTiNnetXbYdPfZdy4m93oWRYVej4eD1rmkIpgKDzNh8tT8Jn4BooNFcyBP8Dx34NQ2rzyzYKhleMDdYptC39kGjFqYWYEkycdMNhwSr7sLpQhEMyLAx2E');

    });
      
    if(!db.find('access_key', access_key)){
        var input = req.body.input;
        // run model
        var response = "I'd be glad to help! 3 plus 3 equals 6.";
        var uuid = helper.uuidv4();

        var pcm_data = [];

        for(var i=0; i<response.match(/.{1,150}/g).length; i++){
            const result = await audio.pcm(response.match(/.{1,150}/g)[i], access_key, i, uuid);
            pcm_data = pcm_data.concat(Array.from(result[0]));
        }

        res.send({'response': pcm_data});
    }else{
        res.send({'response': 'Use a valid access key in order to access the API'});
    }
});

app.listen(PORT, function(){
    console.log(`Server running on port ${PORT}`);
});