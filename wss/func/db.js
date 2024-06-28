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

    const productSchema = new mongoose.Schema({
      access_key: String,
      model: Number,
      query: String,
      email: String,
      first_time: Boolean
    });

    this.Product = mongoose.model('Product', productSchema);
  }

  async parseData() {
    try {
      const products = await this.Product.find();
      return products;
    } catch (err) {
      console.error('Error retrieving products:', err);
      return [];
    }
  }

  async find(filter, value) {
    try {
      const result = await this.Product.findOne({ [filter]: value });
      return result;
    } catch (err) {
      console.error('Error finding product:', err);
      return null;
    }
  }

  async addDoc(data) {
    try {
      const newProduct = new this.Product(data);
      await newProduct.save();
      return newProduct;
    } catch (err) {
      console.error('Error adding product:', err);
      return null;
    }
  }

  async updateDoc(id, data) {
    try {
      const updatedProduct = await this.Product.findByIdAndUpdate(id, data, { new: true });
      return updatedProduct;
    } catch (err) {
      console.error('Error updating product:', err);
      return null;
    }
  }

  async deleteDoc(id) {
    try {
      await this.Product.findByIdAndDelete(id);
      return true;
    } catch (err) {
      console.error('Error deleting product:', err);
      return false;
    }
  }
}

module.exports = {
  Database
};