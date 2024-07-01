require("dotenv").config();
require("./models/db");
const express = require('express');
const path = require("path");
const mongoose = require("mongoose");
const User = mongoose.model("User");
const bodyparser = require("body-parser");
const cookieParser = require("cookie-parser");

const { OAuth2Client } = require("google-auth-library");
const client = new OAuth2Client(process.env.CLIENT_ID);

const app = express();
const PORT = 8080;
const allowedPages = ['index', 'admin', 'function', 'about', 'order', 'notFound'];

app.set("views", path.join(__dirname, "/views/ejs"));
app.use(express.static(path.join(__dirname, '/views')));

app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser());

app.get('/', (req, res) => {
    res.render('index');
});

app.get('/:id', (req, res) => {
    if (allowedPages.includes(req.params.id)) res.render(req.params.id, {
        isLoggedIn: req.cookies["cookie-token"]
    });
    else res.redirect("notFound");
});

app.post('/signin', bodyparser.urlencoded(), async (req, res) => {
    let token = req.body.token;
    
    async function verify() {
        const ticket = await client.verifyldToken({
            idToken: token,
            audience: process.env.CLIENT_ID,
        });
    }
    verify().then(_ => {
        res.cookie("cookie-token", token);
        let found = false;
        let email = req.body.email;
        User.find({}).then(users => {
            users.forEach(user => {
                if (email == user.email) found = true;
            });
            if (found) res.render("index");
            else {
                let user = new User();
                user.email = email;
                user.save().then(_ => {
                    res.render("index");
                });
            }
        });
    }).catch(console.error);
});

app.get("/logout", async (req, res) => {
    res.clearCookie('session-token');
    res.redirect("index");
});

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));