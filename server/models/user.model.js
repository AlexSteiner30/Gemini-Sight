const mongoose = require("mongoose");

const userSchema = {
    email: {
        type: String,
        required: "This field is required"
    }
};

mongoose.model("User", userSchema);