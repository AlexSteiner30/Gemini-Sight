const mongoose = require('mongoose');
require('dotenv').config({ path: './database/.env' });

const mongoURI = process.env.MONGODB_URI;


class Database {
  constructor() {
    this.data = [];

    mongoose.connect(mongoURI, {
    }).then(() => {
      console.log('Successfully connected to DB!');
    }).catch((err) => {
      console.error('Error connecting to DB:', err);
    });

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
          type: String,
          required: "This field is required"
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

    this.Order = mongoose.model('Order', mongoose.model("Order", orderSchema));
  }

  async find(filter, value) {
    try {
      const result = await this.Order.findOne({ [filter]: value });
      return result;
    } catch (err) {
      console.error('Error finding Order:', err);
      return null;
    }
  }

  async updateDoc(id, data) {
    try {
      const updatedOrder = await this.Order.findByIdAndUpdate(id, data, { new: true });
      return updatedOrder;
    } catch (err) {
      console.error('Error updating Order:', err);
      return null;
    }
  }
}

module.exports = {
  Database
};