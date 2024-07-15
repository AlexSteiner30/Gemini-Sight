require("dotenv").config();
require("./models/db");
const express = require('express');
const path = require("path");
const mongoose = require("mongoose");
const User = mongoose.model("User");
const Order = mongoose.model("Order");
const bodyparser = require("body-parser");
const cookieParser = require("cookie-parser");
const { jwtDecode } = require("jwt-decode");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const fs = require("fs");
const crypto = require("crypto");
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash", systemInstruction: "You are an ai chatbot built through the use of the Gemini API of Google. You have been integrated into a website of a product called Gemin-eye. Your task is to help users interacting with you understand more about how the product is used, what it is, information about the creation process or even about the team who created it. The information you are given is: "+`Competition:
This repository is the submission for the Gemini API Developer Competition by Alex Steiner, Fotios Vaitsopoulos, and Lorenzo Dominijani. We are a group of students attending H-Farm International School of Treviso, challenging ourselves to enhance our skills and create a project we can be proud of by participating in the Gemini Developer Competition. This global competition, hosted by Google, showcases the real-world applications of the new Gemini model, with a cash prize for the winner.
Although we joined the competition one month late due to internal exams, we began our project in early to mid-June. Our idea was to create smart glasses entirely powered by Gemini and fully integrated with Google services such as Google Docs, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, and Google Events. These glasses are designed to automate tasks through a single voice command. Additionally, equipped with a camera, they allow the user to ask for information about their surroundings, with the model responding in real-time.
Alex Steiner developed the Flutter application, the glasses' circuit and code, and two WebSockets. Fotios Vaitsopoulos developed the entire website, while Lorenzo Dominijani created the video presentation and the 3D model for the glasses. The logo was designed by Lilian Piovesana.
Submission:
Gemin-Eye is an innovative application that leverages the Gemini language model to create AI-powered smart glasses integrated with various Google services. The core features of our submission include:
1. Voice Commands Integration: Users can perform tasks such as sending emails, scheduling events, and retrieving documents using voice commands.
2. Real-Time Visual Recognition: The glasses' camera can recognize objects and provide information about them in real-time.
3. Google Services Connectivity: Seamless integration with Google Docs, Drive, Gmail, YouTube Music, Maps, Calendar, and Events to enhance productivity.
4. Secure Data Handling: User data is securely managed and encrypted, ensuring privacy and protection.
Our submission demonstrates the practical applications of the Gemini model in everyday life, enhancing user convenience and accessibility through advanced AI technology.
Glasses:
Components needed, with how many in the brackets and the money needed after the comma:
1. XIAO ESP32S3 Sense(x1), €28.02
2. INMP441 Microphone(x1), €7.74
3. HM-10 Bluetooth Module(x1), €4.00
4. 2 8Ω Speakers(x1), €15.13
5. 3.7v Lithium Battery(x1), €9.33
6. Jumper Wire Cables(x1), €9.15
The glasses can connect in two different ways, through Bluetooth and WiFi. Bluethooth is used to share data between the app and the glasses (location, access key, contacts or sending commands), on the other hand, the glasses connect to the WiFi by scanning a QR Code which is created in the app in order to connect to the websockets.
Backend:
Gemin-Eye functions thanks to two different web sockets, one written in JavaScript and the other in Dart. This setup provides additional security and separates the two main background tasks.

At the first login, information from the user's emails and docs is gathered to enhance a personalized experience. The application then sends the login authorization code to the JavaScript website, which the server processes to get the refresh token, which is encrypted and saved in the database. Once the glasses are connected through Bluetooth, data such as access keys, location, and contacts are shared with the glasses. This is also used as a communication channel for tasks like making phone calls or sending messages.
When the user connects the glasses to WiFi, an initial request is made to the Dart websocket to check for an active user with the unique access key. If an active connection is not found, a new user is added to the session. The Dart websocket parses the content generated from the Gemini API by executing the provided commands, serving as a bridge between the client and the JavaScript websocket, adding an additional security layer.
The user's input from the microphone is transcribed using Google's Speech-to-Text Module, then passed to the Dart websocket for processing and request to the JavaScript websocket, which checks for an active session or creates a new one to maintain a chatting history between Gemini and the user. The response is then parsed by the Dart websocket and executed accordingly. For Google Services, it checks the authorization code's expiration and generates a new one if needed using the saved refresh token.
# Example Conversation
Input: Hey Gemma, retrieve the project document
Response: speak(|I am retrieving information about the project document|)¬ speak(get_document(|project|))

Creating you own project:
You can set up your own project by visiting the Google Cloud Console and creating a new project.
Navigate to API and Services and add Gmail, Calendar, Docs, Sheet, Drive, Tasks, YouTube Analytics, Google Maps Places, Google Maps Directions. Then create a new API key and OAuth client IDs (one for mobile devices and one for the web) and save them for later use.
Next, go to MongoDB, create a new project and copy the connection URI.
Website:
The website was created to expand upon our product's publicity, enable the distribution of our product and provide further insight into its creation and abilities through the AI chatbot which has been set up to answer questions related to GEMIN-EYE.
The website can be accessed online.
In total the website offers 5 pages. The first one is the homepage, the second one is the about us section where you are provided with some information about our team. Then there is the functioning page which describes how the glasses work although the gtihub repo does a better job at it. Then the order section is where you can order the glasses and finally a sign in part of the site which is required for you to order the glasses and access the chatbot feature.<br>
You can also run it locally on your computer by installing the required packages and setting up the right environment variables.
For the environment variables you need to have the following:
MONGODB_URI = ""
GEMINI_API = ""
CLIENT_ID = ""


The MONGODB_URI is just the connection uri for MongoDB which you can copy once you have created a new project here. Then, the GEMINI_API is just the Gemini API key which you can just create by going here. Finally, the CLIENT_ID is the client ID for the Google authentication which you can access by going to the Google developer console as shown in the backend section.
Then you will need to head to the server directory, install some packages and run the site like so:
# head to the right directory
$ cd server


# install the required packages
$ npm install


# run the site
$ node server.js
After that just head to localhost:8080 where your site will be running.
Note: It is important to mention that the ordering of the glasses, although already set up on the website with Google Pay, does not work due to the fact that there is currently no way for our team to mass produce and distribute these glasses to a wider audience, so it has just been created as a demo part of the site.
Flutter App:
(Missing info)
How To Use:
To clone and run this application, you'll need Git, Node.js (which comes with npm), and Flutter installed on your computer. From your command line:
# Clone this repository
$ git clone https://github.com/AlexSteiner30/GEMIN-EYE/

# Go into the repository
$ cd GEMIN-EYE

# Go into the wss directory
$ cd wss

# Install dependencies 
$ npm install
Create a new environment file under ./database/.env and save the following environment variables:
CLIENT_ID = "YOUR CLIENT ID"
CLIENT_SECRET = "YOUR CLIENT SECRET"
MONGODB_URI = "YOUR MONGO DB URI"
GEMINI_API = "YOUR GEMINI API KEY"
API_KEY = "YOUR API KEY"
Additionally, copy and paste the payload from this [Google Doc](https://docs.google.com/document/d/1vSDI1G
zzfh56hjHgQJbXwpLhVpo1Ue2w/edit?usp=sharing&ouid=110446241726368691642&rtpof=true&sd=true) into the ./commands.js file.
To start the websocket server, run the following:
# Run the local server
$ npm start
Navigate to the /GEMIN-EYE/app directory and set up your application as follows:
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
After setting up the circuit for the glasses, install Arduino from here. Configure the IDE for ESP32 boards:
1. Go to File > Preferences
2. Enter the following in the “Additional Board Manager URLs” field: https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
3. Click “OK”
4. Open Boards Manager: Tools > Board > Boards Manager…
5. Search for ESP32 and install “ESP32 by Espressif Systems” version 2.0.5
6. Download the ArduinoWebsockets library
7. Include the library in Arduino IDE: Sketch > Include Library > Add .zip Library
Upload Code to ESP32:
8. Navigate to the electronics/ directory and upload the electronics.ino file to your ESP32 Board
9. Go to Tools > Board and select AI-Thinker ESP32-CAM
10. Go to Tools > Port and select the COM port the ESP32-CAM is connected to
11. Click the Upload button
12. When you see dots on the debugging window, press the ESP32-CAM on-board RST button
13. After a few seconds, the code should upload successfully
14. When you see the “Done uploading” message, remove GPIO 0 from GND and press the RST button
You have successfully set up the project! Use the app to connect your glasses and test Gemin-Eye.

Packages and tools Used:
This software uses the following open-source packages and tools:
Flutter
Node.js
Arduino
ESP32 by Espressif Systems
ArduinoWebsockets
Google Cloud Platform
MongoDB
EJS

`});
let previousChats = [];
let userData = {};

const app = express();
const PORT = 8080;
const allowedPages = ['index', 'admin', 'product', 'about', 'order', 'notFound'];

app.set("views", path.join(__dirname, "/views/ejs"));
app.use(express.static(path.join(__dirname, '/views')));

app.set('view engine', 'ejs');
app.use(express.json());
app.use(cookieParser());

app.get('/', (req, res) => {
    res.redirect('index');
});

app.get('/:id', (req, res) => {
    if (req.params.id == "admin" && req.cookies["cookie-token"]) res.redirect("index");
    else if (allowedPages.includes(req.params.id)) res.render(req.params.id, {
        isLoggedIn: req.cookies["cookie-token"],
        chats: JSON.stringify(previousChats)
    });
    else if (req.params.id == "logout") {
        previousChats = [];
        userData = {};
        res.clearCookie('cookie-token');
        res.redirect("index");
    }
    else res.redirect("notFound");
});

app.post('/signin', bodyparser.urlencoded(), async (req, res) => {
    let token = req.body.token;
    const decoded = jwtDecode(token);
    let email = decoded.email;
    res.cookie("cookie-token", token);
    let found = false;
    User.find({}).then(users => {
        users.forEach(user => {
            if (email == user.email) found = true;
        });
        userData.name = decoded.name;
        userData.email = email;
        if (!found) {
            let user = new User();
            user.email = email;
            user.save().then(_ => {
                res.send("Done");
            });
        }
        else {
            res.send("Done");
        }
    });
});

app.post('/chat', bodyparser.urlencoded(), async (req, res) => {
    let prompt = req.body.prompt;
    const chat = model.startChat({
        history: previousChats,
        generationConfig: {
          maxOutputTokens: 100,
        }
    });
    try {
        const result = await model.generateContent(prompt);
        previousChats.push({role: 'user', parts: [{text: prompt}]});
        previousChats.push({role: 'model', parts: [{text: result.response.text()}]});
    }
    catch (err) {
        console.log(err);
        res.redirect("notFound");
    }
    res.redirect("/");
});

app.post('/order', bodyparser.urlencoded(), async (req, res) => {
    let order = new Order();
    order.email = userData.email;
    order.name = userData.name;
    order.address = req.body.address;
    order.first_time = true;
    order.access_key = crypto.randomBytes(128).toString('hex');
    order.model = 0.1;
    order.query = "";
    order.refresh_key = "";
    order.save().then(_ => {
        res.send("Done");
    });
});

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));