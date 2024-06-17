const { initializeApp, getApps, getApp } = require('firebase/app');
const { getFirestore, collection, doc, addDoc, getDoc, getDocs, updateDoc, deleteDoc, } = require('firebase/firestore');

require('dotenv').config({ path: './database/.env' });

const firebaseConfig = {
  apiKey: process.env.API_KEY,
  authDomain: process.env.AUTH_DOMAIN,
  projectId: process.env.PROJECT_ID,
  storageBucket: process.env.STORAGE_BUCKET,
  messagingSenderId: process.env.MESSAGING_SENDER_ID,
  appId: process.env.APP_ID,
  measurementId: process.env.MEASUREMENT_ID
};

class Database {
  constructor() {
    this.data = [];

    this.firebase = initializeApp(firebaseConfig);
    this.db = getFirestore();

    console.log('Successfully connected to DB!');
  }

  async parseData() {
    const products = await getDocs(collection(this.db, 'api'));
    const productArray = [];

    products.forEach((doc) => {
        productArray.push(doc);
    });

    return productArray;
  }

  find(filter, value) {
    return this.data.find(item => item[filter] === value);
  }
}

module.exports = {
  Database
};