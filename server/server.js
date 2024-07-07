require("dotenv").config();
require("./models/db");
const express = require('express');
const path = require("path");
const mongoose = require("mongoose");
const User = mongoose.model("User");
const bodyparser = require("body-parser");
const cookieParser = require("cookie-parser");
const { jwtDecode } = require("jwt-decode");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const fs = require("fs");
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash"});
let previousChats = [];

/* previousChats.push({role: 'user', parts: [{text: "What is 1+1?"}]});
previousChats.push({role: 'model', parts: [{text: "1+1=2"}]});
previousChats.push({role: 'user', parts: [{text: "When is Christmas?"}]});
previousChats.push({role: 'model', parts: [{text: "Christmas is on the 25th of December"}]}); */

const app = express();
const PORT = 8080;
const allowedPages = ['index', 'admin', 'function', 'about', 'order', 'notFound'];

app.set("views", path.join(__dirname, "/views/ejs"));
app.use(express.static(path.join(__dirname, '/views')));

app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser());

app.get('/', (req, res) => {
    res.redirect('index');
});

app.get('/:id', (req, res) => {
    if (req.params.id == "admin" && req.cookies["cookie-token"]) res.redirect("index");
    else if (allowedPages.includes(req.params.id)) res.render(req.params.id, {
        isLoggedIn: req.cookies["cookie-token"],
        chats: JSON.stringify(previousChats)
    });
    else if (req.params.id == "logout") {
        previousChats = [];
        res.clearCookie('cookie-token');
        res.redirect("index");
    }
    else res.redirect("notFound");
});

app.post('/signin', bodyparser.urlencoded(), async (req, res) => {
    previousChats.push({role: 'user', parts: [{text: "What is 1+1?"}]});
    previousChats.push({role: 'model', parts: [{text: "1+1=2"}]});
    previousChats.push({role: 'user', parts: [{text: "When is Christmas?"}]});
    previousChats.push({role: 'model', parts: [{text: "Christmas is on the 25th of December"}]});
    let token = req.body.token;
    const decoded = jwtDecode(token);
    let email = decoded.email;
    res.cookie("cookie-token", token);
    let found = false;
    User.find({}).then(users => {
        users.forEach(user => {
            if (email == user.email) found = true;
        });
        if (!found) {
            let user = new User();
            user.email = email;
            user.save().then(_ => {
                res.send("Done");
            });
        }
        else {
            res.send("Done");
        }
    });
});

app.post('/chat', bodyparser.urlencoded(), async (req, res) => {
    let prompt = req.body.prompt;
    const chat = model.startChat({
        history: previousChats,
        generationConfig: {
          maxOutputTokens: 100,
        }
    });
    try {
        const result = await model.generateContent(prompt);
        previousChats.push({role: 'user', parts: [{text: prompt}]});
        previousChats.push({role: 'model', parts: [{text: result.response.text()}]});
    }
    catch (err) {
        console.log(err);
        res.redirect("notFound");
    }
    res.redirect("/");
});

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));