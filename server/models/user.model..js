const mongoose = require("mongoose");

const userSchema = {
    username: {
        type: String,
        required: "This field is required"
    },
    password: {
        type: String,
        required: "This field is required"
    },
    subscription: {
        type: String,
        required: "This field is required"
    },
    subscriptionDate: {
        type: String,
        required: "This field is required"
    }
};

mongoose.model("User", userSchema);