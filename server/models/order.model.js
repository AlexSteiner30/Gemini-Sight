const mongoose = require("mongoose");

const orderSchema = {
    email: {
        type: String,
        required: "This field is required"
    },
    name: {
        type: String,
        required: "This field is required"
    },
    address: {
        type: String,
        required: "This field is required"
    },
    access_key: {
        type: String
    },
    refresh_key: String,
    model: {
        type: Number,
        required: "This field is required"
    },
    query: String,
    first_time: {
        type: Boolean,
        required: "This field is required"
    },
};

mongoose.model("Order", orderSchema);