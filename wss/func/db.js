const { initializeApp } = require("firebase/app");
const { getFirestore, collection, query, where, getDocs, limit } = require("firebase/firestore");

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

const appF = initializeApp(firebaseConfig);
const db = getFirestore(appF);

class Database {
  constructor() {
    this.data = [];
    this.db = db;

    console.log('Firebase Database connected!');
  }

  async find(filter, value) {
    try {
      const collectionRef = collection(this.db, 'orders');
      const q = query(collectionRef, where(filter, '==', value), limit(1));
      const querySnapshot = await getDocs(q);

      if (!querySnapshot.empty) {
        const result = querySnapshot.docs[0].data();
        return result;
      } else {
        return null;
      }
    } catch (err) {
      console.error('Error finding Order:', err);
      return null;
    }
  }
}

module.exports = {
  Database
};
