const { initializeApp } = require('firebase/app');

const firebaseConfig = {
  apiKey: "AIzaSyBiWsYKmk6cZopIAwxjle0j8Vpk3zX2PPc",
  authDomain: "sinuous-branch-426313-q6.firebaseapp.com",
  projectId: "sinuous-branch-426313-q6",
  storageBucket: "sinuous-branch-426313-q6.appspot.com",
  messagingSenderId: "910242255946",
  appId: "1:910242255946:web:d418dfe04fd3a47f7542b3",
  measurementId: "G-DXGBG8VP0B"
};

const app = initializeApp(firebaseConfig);

class Database{
    constructor(path){
        this.path = path;
        this.data = this.parseData();

        this.app = initializeApp(firebaseConfig);
    }

    async parseData(){
        const snapshot = await firebase.firestore().collection('events').get()
        console.log(snapshot.docs.map(doc => doc.data()));

        return JSON.parse(fs.readFileSync(this.path, 'utf8'));
    }

    find(filter, value){
        for(var i=0; i < this.data.length; i++){
            if(this.data[i][filter] == value){
                return this.data[i];
            }
        }

        return;
    }
}

module.exports = {
    Database
};