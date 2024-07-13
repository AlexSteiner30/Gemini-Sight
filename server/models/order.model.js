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
    }
};

mongoose.model("Order", orderSchema);