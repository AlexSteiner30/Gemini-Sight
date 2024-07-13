const mongoose = require("mongoose");

require('dotenv').config();

mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true
});

require("./user.model");
require("./order.model");