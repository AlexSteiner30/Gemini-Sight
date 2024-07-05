require("dotenv").config();
require("./models/db");
const express = require('express');
const path = require("path");
const mongoose = require("mongoose");
const User = mongoose.model("User");
const bodyparser = require("body-parser");
const cookieParser = require("cookie-parser");
const { jwtDecode } = require("jwt-decode");


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
    if (allowedPages.includes(req.params.id)) res.render(req.params.id, {
        isLoggedIn: req.cookies["cookie-token"]
    });
    else if (req.params.id == "logout") {
        res.clearCookie('cookie-token');
        res.redirect("index");
    }
    else res.redirect("notFound");
});

app.post('/signin', bodyparser.urlencoded(), async (req, res) => {
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

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));