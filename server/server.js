const express = require('express');
const path = require("path");

const app = express();
const PORT = 8080;
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

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});