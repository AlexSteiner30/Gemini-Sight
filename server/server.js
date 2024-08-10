require("dotenv").config();
const express = require('express');
const path = require("path");
const bodyparser = require("body-parser");
const cookieParser = require("cookie-parser");
const { jwtDecode } = require("jwt-decode");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const crypto = require("crypto");
const { initializeApp } = require("firebase/app");
const firestore = require("firebase/firestore");

const aboutUsText = {
    about_us: `
        <p>Our team created <a target="_blank" href="https://github.com/AlexSteiner30/Gemini-Sight/">this GitHub repository</a> which is our submission for the Gemini API Developer Competition by <a target="_blank" href="https://github.com/AlexSteiner30">Alex Steiner</a>, <a target="_blank" href="https://github.com/Epic-legend128">Fotios Vaitsopoulos</a>. We are a two students attending H-Farm International School of Treviso, challenging ourselves to enhance our skills and create a project we can be proud of by participating in the Gemini Developer Competition. This global competition, hosted by Google, showcases the real-world applications of the new Gemini model, with a cash prize for the winner.</p>
        <p>Although we joined the competition one month late due to internal exams, we began our project in early to mid-June. Our idea was to create smart glasses entirely powered by Gemini and fully integrated with Google services such as Google Docs, Google Sheets, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, and Google Meet, Google Messages and Calls. These glasses are designed to automate tasks through a single voice command. Additionally, equipped with a camera, they allow the user to ask for information about their surroundings, with the model responding in real time. Alex Steiner developed the Flutter application, the glasses' circuit and code, the two WebSockets and designed the 3D glasses. Fotios Vaitsopoulos designeda and developed the whole website.</p>
        <p>A special thanks also to my dad, <a target="_blank" href="https://www.facebook.com/marcodirimini/">Marco Baroni</a>, who helped me through the entire process by supporting me finaccialy, moraly, helping me with the planning and designing the glasses.</p>    
    `,

    alex_steiner: `
        <p><strong><em>"Alex, get off the computer!"</em></strong> That's probably the sentence I heard the most in my entire life. At only 16 years old, my mum would always shout from the kitchen for me to stop being on the computer and do something else. It’s not as if I was on my computer all day long—I was also really into sports, especially basketball. However, whenever I had the opportunity or spare time, I would spend it on my computer, learning something new every day. This is more or less how I ended up here, competing in a Google competition. I guess those hours spent on the computer weren’t that bad, right mum?</p>
        <p>But let’s take a step back. My journey dates back to 2015 when I was 9 years old. I received one of those all-in-one, crappy ACER computers. For no reason at all, I went on YouTube and searched <strong><em>"How To Make A Video Game."</em></strong> From there, my adventure began. Coding is fun for me but sometimes it turns out it’s actually my biggest nightmare and the amount of pain it creates makes me wonder what went wrong in that 9-year-old head. I created a very wonky top-down racing game and messed around with Scratch, before moving on to Python, Node.js, C#, and the Unity Engine. I focused on developing video games and backend applications over the next few years. I even created a copy of the Among Us game (by reverse-engineering the assets from the game) but spiced it up by developing it for the best video game console ever created: the Nintendo 3DS.</p>
        <p>In 2021, I left the beautiful country of San Marino to attend H-Farm International School. I think this was the turning point in my <strong><em>"career,"</em></strong> if you can call it that. With the many opportunities the campus offered, I started developing project after project. I also picked up machine learning using TensorFlow and PyTorch. The school, being focused on business and technology, has these competitions that every first-year high school student attends. We are randomly divided into groups and have to create a startup. My group developed a 3D GAN that was able to create 3D models from a given text, although it was limited by the very small dataset I had access to. Long story short, my group won the competition.</p>
        <p>I also learned about electronics and how painful it is. One of my most notable projects is a vertical farm system that automatically handles water, light, and air systems, and can be controlled remotely with an integrated camera. Furthermore, multiple farms can be added.</p>
        <p>And yeah, this is how I got here, competing in a Google competition. I appreciate everyone for checking out Gemini Sight!</p>
        <p style="font-style: italic;">P.S. Please don’t judge my code. I am more than aware it's bad.</p>
    `,

    fotios_vaitsopoulos: `
    <p>I am a young Greek developer who got interested in programming and coding at an early age. In 5th grade there was a national Mathematics competition in my country and I participated in getting 100%, through that achievement of mine I was noticed by a robotics and programming teacher who offered to help me cultivate my skills.  Through that mentor, I was able to learn a lot and gain even more passion for not only mathematics but also robotics and programming which is why I started participating in some national lego robotics competitions organised by the <a href=”https://wrohellas.gr/wro-hellas-home/about-us/?lang=en” target=”_blank”>WRO Hellas</a> in which I earned first place in 6th grade using Wedo 2.0 in a team of 6 and 3rd place in 7th grade and 2nd in 8th grade where I used EV3 and was in a team of 3. I tied in 1st place in a WRO robotics simulation competition called Robomarathon in which 4 countries participated where we had to use Trik Studio to solve 6 different problems in under 3 hours where I participated in a solo team. Furthermore, grades 7-10 I have been participating, using C++, in the Panhellenic IT Competition(<a href=”” target=”http://pdp.gr/”_blank”>PDP</a>) which is a Greek national competition focused on selecting skillful young programmers and recruiting them for the International Olympiads in Informatics(IOI) to represent Greece. Throughout these years I was able to pass in 8th grade all 3 phases of the competition of PDP but I was still not chosen for the Olympics team. Of course, just passing the national level was motivational enough for me to keep on growing which is why ever since then, I have been constantly studying different fields of programming, from web and game development, by creating simple games and feature-heavy websites, to algorithms, data structures and graphs.</p>
    
    <p>A noteworthy project which I have completed is the <a href=”https://github.com/Epic-legend128/Game-Library” target=”_blank”>Game Library</a> website which I created and uploaded on my Github profile in which I uploaded 7 different games which I made using Unity Engine. Those games include the classic Snake game, Flappy Bird, Minesweeper, Tic-Tac-Toe(both PVP and AI) and even Chess. It also included 2 other games, a platformer and a simple rpg. All of these games and the website hosting them were created within half a year as it was my submission for my Personal Project for MYP5 in the IB. Of course, I have been able to also create other projects which can all be viewed on my Github profile.</p>
    
    <p>With the rise of AI, I began to show some interest in this field which is why the moment I learnt of this Gemini API competition I was immediately eager to join together with my friend and classmate Alex Steiner.</p>

    <p>I envision that with this project I will be able to greatly increase my knowledge of the Gemini API as well as some aspects of app and web development. I am also hoping to make some sort of impact on society if this product manages to gain some traction.</p>
    `,
};
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash", systemInstruction: "You are an ai chatbot built through the use of the Gemini API of Google. You have been integrated into a website of a product called Gemini Sight. Your task is to help users interacting with you understand more about how the product is used, what it is, information about the creation process or even about the team who created it. The information you are given is: "+`Competition:
This repository is the submission for the Gemini API Developer Competition by Alex Steiner, Fotios Vaitsopoulos. We are two students attending H-Farm International School of Treviso, challenging ourselves to enhance our skills and create a project we can be proud of by participating in the Gemini Developer Competition. This global competition, hosted by Google, showcases the real-world applications of the new Gemini model, with a cash prize for the winner.

Although we joined the competition one month late due to internal exams, we began our project in early to mid-June. Our idea was to create smart glasses entirely powered by Gemini and fully integrated with Google services such as Google Docs, Google Sheets, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, and Google Meet, Google Messages and Calls. These glasses are designed to automate tasks through a single voice command. Additionally, equipped with a camera, they allow the user to ask for information about their surroundings, with the model responding in real time.

Alex Steiner developed the Flutter application, the glasses' circuit and code, the two WebSockets and designed the 3D glasses. Fotios Vaitsopoulos designed and developed the whole website.

Submission

Gemini Sight is an innovative application that leverages the Gemini language model to create AI-powered smart glasses integrated with various Google services. The core features of our submission include:

Voice Commands Integration: Users can perform tasks such as sending emails, scheduling events, and retrieving documents using voice commands.
Real-Time Visual Recognition: The glasses' camera can recognize objects and provide information about them in real time.
Google Services Connectivity: Seamless integration with Google Docs, Drive, Gmail, YouTube Music, Maps, Calendar, and Events to enhance productivity.
Secure Data Handling: User data is securely managed and encrypted, ensuring privacy and protection.
Our submission demonstrates the practical applications of the Gemini model in everyday life, enhancing user convenience and accessibility through advanced AI technology.

Glasses

Download the glasses printable STL file from the models/ folder, after printing the 3D model use this circuit diagram to create the wiring. It is not necessary to solder the pieces together however it is highly recommended for space optimation.

The glasses can connect in two different ways, through Bluetooth and WiFi. Bluetooth is used to share data between the app and the glasses (location, access key, contacts or sending commands), on the other hand, the glasses connect to the WiFi by scanning a QR Code which is created in the app in order to connect to the websockets. The cost for the final distributed-product is $200.

Backend

Gemini Sight functions thanks to two different web sockets, one written in JavaScript and the other in Dart. This setup provides additional security and separates the two main background tasks. This concept is visualized in the following sketch:



At the first login, information from the user's emails and docs is gathered to enhance a personalized experience. The application then sends the login authorization code to the JavaScript website, which the server processes to get the refresh token, which is encrypted and saved in the database. Once the glasses are connected through Bluetooth, data such as access keys, location, and contacts are shared with the glasses. This is also used as a communication channel for tasks like making phone calls or sending messages.

When the user connects the glasses to WiFi, an initial request is made to the Dart websocket to check for an active user with the unique access key. If an active connection is not found, a new user is added to the session. The Dart websocket parses the content generated from the Gemini API by executing the provided commands, serving as a bridge between the client and the JavaScript websocket, adding an additional security layer.

The user's input from the microphone is transcribed using Google's Speech-to-Text Module, then passed to the Dart websocket for processing and request to the JavaScript websocket, which checks for an active session or creates a new one to maintain a chatting history between Gemini and the user. The response is then parsed by the Dart websocket and executed accordingly. For Google Services, it checks the authorization code's expiration and generates a new one if needed using the saved refresh token.

# Example Conversation
Input: Hey Gemma, retrieve the project document
Response: speak(|I am retrieving information about the project document|)¬ speak(get_document(|project|))
Set up your own project by visiting the Google Cloud Console and creating a new project.



Navigate to API and Services and add Gmail, Calendar, Docs, Sheet, Drive, Tasks, YouTube Analytics, Google Maps Places and Google Maps Directions. Then create a new API key and OAuth client IDs (one for mobile devices and one for the web) and save them for later use.

  

Next, go to Firebase, create a new project on https://console.firebase.google.com/ and copy the connection variablesI.

Website

The website was created to expand upon our product's publicity, enable its distribution and provide further insight into its creation and abilities through the AI chatbot which has been set up to answer questions related to Gemini Sight. The website can be accessed online https://geminisight-58e89465e495.herokuapp.com which was uploaded through the use of Heroku.
In total the website offers 5 pages. The first one is the "Home" and the second one is the "About Us" section where you are provided with some information about our team. Then there is the "Product" page which describes how the glasses work although the Gtihub repository does a better job at it. Then the "Order" section is where you can order the glasses for a price of $200 and finally a "Sign In" part of the site which is required for you to order the glasses and access the chatbot feature.

You can also run the website locally on your computer by installing the required packages and setting up the right environment variables.
For the environment variables you need to have the following:

GEMINI_API = "YOUR GEMINI API"
CLIENT_ID = "YOUR CLIENT ID"
API_KEY="YOUR API KEY"
AUTH_DOMAIN="YOUR AUTH DOMAIN"
PROJECT_ID="YOUR PROJECT ID"
STORAGE_BUCKET="YOUR STORAGE BUCKET"
MESSAGING_SENDER_ID="YOUR MESSAGING SENDER ID"
APP_ID="YOUR APP ID"
MEASUREMENT_ID="YOUR MEASUREMENT ID"
The GEMINI_API is just the Gemini API key which you can just create by going to https://aistudio.google.com/app/apikey. Finally, the CLIENT_ID is the client ID for the Google authentication which you can access by going to the Google developer console as shown in the backend section. The rest are just all of the values needed for the Firebase configuration.
Then you will need to head to the server directory, install some packages and run the site like so:

# head to the right directory
$ cd server

# install the required packages
$ npm install

# run the site
$ node server.js
After that just head to localhost:3000 where your site will be running.

Homepage

Note: It is important to mention that the ordering of the glasses, although already set up on the website with Google Pay, does not work due to the fact that there is currently no way for our team to mass produce and distribute these glasses to a wider audience, so it has just been created as a demo part of the site and is in test mode so no payments will be accepted.

Flutter App

The Flutter app serves multiple functions to enhance the capabilities of your smart glasses. Initially, thanks to it you can connect your glasses to a WiFi network via Bluetooth module. The app also functions as a control system, allowing Gemini to learn about you and your writing style for emails or documents using your Google data, activate blind mode to enhance and simplify daily tasks for the blind through the Gemini vision model, and access recordings and pictures taken by the glasses stored on your Google Drive. Additionally, when the glasses are connected to Bluetooth, the app serves as a bridge in order for Gemini to automatize services on your phone, such as sending texts and making calls.

      

How To Use

To clone and run this application, you'll need Git, Node.js (which comes with npm), and Flutter installed on your computer. From your command line:

# Clone this repository
$ git clone https://github.com/AlexSteiner30/Gemini-Sight/

# Go into the repository
$ cd Gemini-Sight

# Go into the wss directory
$ cd wss

# Install dependencies 
$ npm install
Create a new environment file under ./database/.env and save the following environment variables:

CLIENT_ID = "YOUR CLIENT ID"
CLIENT_SECRET = "YOUR CLIENT SECRET"
GEMINI_API = "YOUR GEMINI API KEY"
API_KEY = "YOUR API KEY"
AUTH_DOMAIN="YOUR AUTH DOMAIN"
PROJECT_ID="YOUR PROJECT ID"
STORAGE_BUCKET="YOUR STORAGE BUCKET"
MESSAGING_SENDER_ID="YOUR MESSAGING SENDER ID"
APP_ID="YOUR APP ID"
MEASUREMENT_ID="YOUR MEASUREMENT ID"
PAYLOAD="YOUR PAYLOAD"
Additionally, copy and paste the payload from the google doc with a link of https://docs.google.com/document/d/1vSDI1GnhkzvIxU8-Ivmz65zpxOH9fXzmfSPuA8jI8OY/edit?usp=sharing into the ./commands.js file.

To start the websocket server, run the following:

# Run the local server
$ npm start
Navigate to the /Gemini-Sight/app directory and set up your application as follows:

# Get device IP address
$ ifconfig en0

# Update the IP address in the websocket configuration
$ open lib/helper/socket.dart

# On line 4, change to
Uri.parse('ws://<your IP address>:443'),
Replace the Client ID and Server Client ID with your own by executing:

$ open lib/main

# On line 5, change to
const String CLIENT_ID = '<your client id>';

# On line 6, change to
const String SERVER_CLIENT_ID = '<your server client id>';
Ensure that you can deploy the application to a physical or virtual device by following this guide and verifying with the flutter doctor command. Once completed, run:

flutter run --web-port 8080 --observatory-port 8080
Note: Currently, the Flutter app was developed and tested only on iOS systems, but it should still be able to run on the most recent Android devices.

After setting up the circuit for the glasses, install and set up PlatformIO from https://docs.platformio.org/en/latest/integration/ide/vscode.html#installation. Build your project and then upload it to the ESP32 XIAO Board.

You have successfully set up the project! Use the app to connect your glasses and test Gemini Sight.

Download

You can download the latest installable iOS version of the Gemini Sight App.

Future

Unfortunately, the GPS module didn't arrive in time meaning that the functionalities such as Google Maps directions or recording the speed are not functioning however from a coding point of view they are already developed and functioning only the actual data from the GPS that needs to be passed is missing. We plan to implement it and many other features if the project keeps getting maintained. One major problem furthermore is the Google Sheets API as the Gemini model performs poorly with creating 2D arrays from a given input, this however can be improved by feeding the model with more training data.

Credits

This software uses the following open-source packages and tools:
Flutter
Node.js
PlatformIO
ESP32
ArduinoWebsockets
Google Cloud Platform
EJS
Google Pay
Firebase
I2S WAV File
Heroku

Contact Us:
You can contact us at alex.steiner@student.h-is.com and fotios.vaitsopoulos@gmail.com.

About the Team:
Fotios Vaitsopoulos: 
I am a young developer who got interested in programming and coding at an early age through a mentor which I used to have. Ever since then, I have been constantly studying different fields of programming, from web and game development, by creating simple games and feature-heavy websites, to algorithms, data structures and graphs, which I have used to participate in multiple competitions and to improve my problem-solving skills. Now with the rise of AI, I have also begun to show some interest in this field which is why the moment I learnt of this competition I was immediately eager to join.
I envision that with this project I will be able to greatly increase my knowledge of the Gemini API as well as some aspects of app and web development. I am also hoping to make some sort of impact on society if this product manages to gain some traction.
Alex Steiner:
"Alex, get off the computer!" That's probably the sentence I heard the most in my entire life. At only 16 years old, my mum would always shout from the kitchen for me to stop being on the computer and do something else. It’s not as if I was on my computer all day long—I was also really into sports, especially basketball. However, whenever I had the opportunity or spare time, I would spend it on my computer, learning something new every day. This is more or less how I ended up here, competing in a Google competition. I guess those hours spent on the computer weren’t that bad, right mum?
But let’s take a step back. My journey dates back to 2015 when I was 9 years old. I received one of those all-in-one, crappy ACER computers. For no reason at all, I went on YouTube and searched "How To Make A Video Game." From there, my adventure began. Coding is fun for me but sometimes it turns out it’s actually my biggest nightmare and the amount of pain it creates makes me wonder what went wrong in that 9-year-old head. I created a very wonky top-down racing game and messed around with Scratch, before moving on to Python, Node.js, C#, and the Unity Engine. I focused on developing video games and backend applications over the next few years. I even created a copy of the Among Us game (by reverse-engineering the assets from the game) but spiced it up by developing it for the best video game console ever created: the Nintendo 3DS.
In 2021, I left the beautiful country of San Marino to attend H-Farm International School. I think this was the turning point in my "career," if you can call it that. With the many opportunities the campus offered, I started developing project after project. I also picked up machine learning using TensorFlow and PyTorch. The school, being focused on business and technology, has these competitions that every first-year high school student attends. We are randomly divided into groups and have to create a startup. My group developed a 3D GAN that was able to create 3D models from a given text, although it was limited by the very small dataset I had access to. Long story short, my group won the competition.
I also learned about electronics and how painful it is. One of my most notable projects is a vertical farm system that automatically handles water, light, and air systems, and can be controlled remotely with an integrated camera. Furthermore, multiple farms can be added.
And yeah, this is how I got here, competing in a Google competition. I appreciate everyone for checking out Gemini Sight!
P.S. Please don’t judge my code. I am more than aware it's bad.


A special thanks also to my dad, Marco Baroni, (https://www.facebook.com/marcodirimini/) who helped me through the entire process by supporting me financially, morally, helping me with the planning and designing the glasses.
`});
let previousChats = {};
let userData = {};

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
const db = firestore.getFirestore(appF);

const app = express();
const PORT = process.env.PORT || 3000;
const allowedPages = ['index', 'login', 'product', 'about', 'order', 'notFound'];

app.use(express.static(path.join(__dirname, 'public/')));

app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser());

const randomHex = n => Array(n).fill(0).map(() => Math.floor(Math.random()*16).toString(16).toUpperCase()).join('');

app.get('/', (req, res) => {
    res.redirect('index');
});

app.get('/:id', (req, res) => {
    if (req.params.id == "login" && req.cookies["cookie-token"]) res.redirect("index");
    else if (allowedPages.includes(req.params.id)) res.render(req.params.id, {
        isLoggedIn: req.hasOwnProperty("cookies") && req.cookies["cookie-token"] != undefined && req.cookies["cookie-token"].includes("@"),
        chats: JSON.stringify(previousChats[req.cookies["cookie-token"]]),
        title: (req.params.id == "about" ? (aboutUsText.hasOwnProperty(req.query.name) ? req.query.name.replace(/_/g, ' ').replace(/(^| )\w/g, match => match.toUpperCase()) : "About Us") : ""),
        text: (req.params.id == "about" ? aboutUsText[req.query.name]||aboutUsText["about_us"]: "")
    });
    else if (req.params.id == "logout") {
        previousChats[req.cookies["cookie-token"]] = [];
        userData[req.cookies["cookie-token"]] = {};
        res.clearCookie('cookie-token');
        res.redirect("index");
    }
    else res.redirect("notFound");
});

app.post('/signin', bodyparser.urlencoded({ extended: true }), async (req, res) => {
    let token = req.body.token;
    const decoded = jwtDecode(token);
    let email = decoded.email;
    try {
        let docRef = await firestore.doc(db, "users", email);
        let token = email;
        userData[token] = {};
        userData[token].name = decoded.name;
        userData[token].email = email;
        let document = await firestore.getDoc(docRef);
        if (!previousChats.hasOwnProperty(token) || previousChats[token].length == 0 || previousChats[token] == undefined) {
            previousChats[token] = [];
            previousChats[token].push({role: 'user', parts: [{text: "Who are you?"}]});
            previousChats[token].push({role: 'model', parts: [{text: "I'm an AI chatbot powered by Google's Gemini API, specifically designed to help you learn more about Gemini Sight. I can answer your questions about the product, its features, its creators, the development process, or anything else related to Gemini Sight. What would you like to know? 😊"}]});
        }
        res.cookie("cookie-token", token);
        if (!document.exists()) {
            firestore.setDoc(docRef, {
                active: true
            }).then(_ => {
                res.send("Done");
            });
        }
        else {
            res.send("Done");
        }
    } catch(err) {
        console.error("Sign in error: ", err);
        res.redirect("notFound");
    }
});

app.post('/chat', bodyparser.urlencoded({ extended: true }), async (req, res) => {
    try {
        let token = req.cookies['cookie-token'];
        let prompt = req.body.prompt;
        const chat = model.startChat({
            history: previousChats[token],
            generationConfig: {
            maxOutputTokens: 100,
            }
        });

        const result = await model.generateContent(prompt);
        previousChats[token].push({role: 'user', parts: [{text: prompt}]});
        previousChats[token].push({role: 'model', parts: [{text: result.response.text()}]});
    }
    catch (err) {
        console.error("Gemini API error: ", err);
        res.redirect("notFound");
    }
    res.redirect("/");
});

app.post('/order', bodyparser.urlencoded({ extended: true }), async (req, res) => {
    try {
        firestore.addDoc(firestore.collection(db, "orders"), {
            email: userData[req.cookies["cookie-token"]].email,
            name: userData[req.cookies["cookie-token"]].name,
            address: req.body.address,
            first_time: true,
            access_key: crypto.randomBytes(128).toString('hex'),
            model: 0.1,
            query: "",
            refresh_key: "",
            ble_id: randomHex(4) + '-' + randomHex(4) + '-' + randomHex(4) + '-' + randomHex(4) + '-' + randomHex(12)
        }).then(_ => {
            res.send(`Your Glasses will be shipped to ${req.body.address} as soon as possible`)
        });
    }
    catch(err) {
        res.send("Ordering error: ", err);
    }
});

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));