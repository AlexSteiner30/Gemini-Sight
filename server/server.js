const express = require('express');
const { Database } = require('./func/db.js');
const { Audio } = require('./func/audio.js');
const helper = require('./func/helper.js');
const {Model} = require('./func/model.js');
const path = require("path");

const app = express();
const db = new Database();
const audio = new Audio('./audio/');
const ai = new Model();
const PORT = 8000;
const allowedPages = ['index', 'admin', 'function', 'about'];


app.set("views", path.join(__dirname, "/views"));
app.use(express.static(path.join(__dirname, '/views')));

app.set('view engine', 'ejs');
app.use(express.json());

app.get('/', (req, res) => {
    res.render('index');
});

app.get('/:id', (req, res) => {
    if (allowedPages.includes(req.params.id)) res.render(req.params.id);
    else res.render("notFound");
});

app.post('/api/input/', async (req, res) => {
    const access_key = req.body.access_key;
    const input = req.body.input;
    const ip = req.body.ip;

    try {
        await db.parseData();
        
        if (!db.find('access_key', access_key)) { // remove ! once db fixed
            const response = ai.proccess_input(input);
            const uuid = helper.uuidv4();

            for (let i = 0; i < response.match(/.{1,150}/g).length; i++) {
                audio.pcm(response.match(/.{1,150}/g)[i], access_key, i, uuid, ip);
            }

            res.send({ 'response': 'Done' });
        } else {
            res.send({ 'response': 'Use a valid access key in order to access the API' });
        }
    } catch (error) {
        console.error('Error processing request:', error);
        res.status(500).send({ 'error': 'Internal server error' });
    }
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});