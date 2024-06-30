require("dotenv").config();
require("./models");
const express = require('express');
const path = require("path");
const mongoose = require("mongoose");
const User = mongoose.model("User");

const app = express();
const PORT = 8080;
const allowedPages = ['index', 'admin', 'function', 'about', 'signup', 'order'];

app.set("views", path.join(__dirname, "/views/ejs"));
app.use(express.static(path.join(__dirname, '/views')));

app.set('view engine', 'ejs');
app.use(express.json());

app.get('/', (req, res) => {
    res.render('index');
});

app.get('/:id', (req, res) => {
    if (req.params.id == admin) res.render("admin", {failed: false});
    else if (allowedPages.includes(req.params.id)) res.render(req.params.id);
    else res.render("notFound");
});

app.post('/signin', async (req, res) => {
    let name = req.body.username;
    let password = req.body.password;
    let found = false;
    User.find({}).then(users => {
        users.forEach(user => {
            if (name == users.username && password == users.password) found = true;
        });
        if (!found) res.render("admin", {failed: true});
        else {
            res.render("index");
            //sign user in later
        }
    });
});

app.post('/signup', async (req, res) => {
    let name = req.body.username;
    let password = req.body.password;
    let confirm = req.body.confirm;
    if (password != confirm) res.render("signup", {failed: true});
    let found = false;
    User.find({}).then(users => {
        users.forEach(user => {
            if (name == users.username && password == users.password) found = true;
        });
        if (found) res.render("signup", {failed: true});
        else {
            res.render("index");
            //sign user in later
        }
    });
});

app.post("/logout", async (req, res) => {

});

app.post("/delete", async (req, res) => {

});

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));