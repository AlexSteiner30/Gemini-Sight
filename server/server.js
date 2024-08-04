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
const crypto = require("crypto");
const aboutUsText = {
    about_us: `
        <p>Our team created <a target="_blank" href="https://github.com/AlexSteiner30/Gemini-Sight/">this GitHub repository</a> which is our submission for the Gemini API Developer Competition by <a target="_blank" href="https://github.com/AlexSteiner30">Alex Steiner</a>, <a target="_blank" href="https://github.com/Epic-legend128">Fotios Vaitsopoulos</a>, and <a target="_blank" href="https://www.instagram.com/lorenzo.dominijanni/">Lorenzo Dominijani</a>. We are a group of students attending H-Farm International School of Treviso, challenging ourselves to enhance our skills and create a project we can be proud of by participating in the Gemini Developer Competition. This global competition, hosted by Google, showcases the real-world applications of the new Gemini model, with a cash prize for the winner.</p>
        <p>Although we joined the competition one month late due to internal exams, we began our project in early to mid-June. Our idea was to create smart glasses entirely powered by Gemini and fully integrated with Google services such as Google Docs, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, and Google Events. These glasses are designed to automate tasks through a single voice command. Additionally, equipped with a camera, they allow the user to ask for information about their surroundings, with the model responding in real time.</p>
        <p>Alex Steiner developed the Flutter application, the glasses' circuit and code, and two WebSockets. Fotios Vaitsopoulos developed the entire website, while Lorenzo Dominijani created the video presentation and the 3D model for the glasses. The logo was designed by <a target="_blank" href="https://www.linkedin.com/in/lilian-piovesana-333b572b1/">Lilian Piovesana</a>.</p>
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
        <p>I am a young developer who got interested in programming and coding at an early age through a mentor which I used to have. Ever since then, I have been constantly studying different fields of programming, from web and game development, by creating simple games and feature-heavy websites, to algorithms, data structures and graphs, which I have used to participate in multiple competitions and to improve my problem-solving skills. Now with the rise of AI, I have also begun to show some interest in this field which is why the moment I learnt of this competition I was immediately eager to join.</p>
        <p>I envision that with this project I will be able to greatly increase my knowledge of the Gemini API as well as some aspects of app and web development. I am also hoping to make some sort of impact on society if this product manages to gain some traction.</p>
    `,
};
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API);
const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash", systemInstruction: "You are an ai chatbot built through the use of the Gemini API of Google. You have been integrated into a website of a product called Gemin-eye. Your task is to help users interacting with you understand more about how the product is used, what it is, information about the creation process or even about the team who created it. The information you are given is: "+`Competition:
This repository is the submission for the Gemini API Developer Competition by Alex Steiner, Fotios Vaitsopoulos, and Lorenzo Dominijani. We are a group of students attending H-Farm International School of Treviso, challenging ourselves to enhance our skills and create a project we can be proud of by participating in the Gemini Developer Competition. This global competition, hosted by Google, showcases the real-world applications of the new Gemini model, with a cash prize for the winner.
Although we joined the competition one month late due to internal exams, we began our project in early to mid-June. Our idea was to create smart glasses entirely powered by Gemini and fully integrated with Google services such as Google Docs, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, and Google Events. These glasses are designed to automate tasks through a single voice command. Additionally, equipped with a camera, they allow the user to ask for information about their surroundings, with the model responding in real time.
Alex Steiner developed the Flutter application, the glasses' circuit and code, and two WebSockets. Fotios Vaitsopoulos developed the entire website, while Lorenzo Dominijani created the video presentation and the 3D model for the glasses. The logo was designed by Lilian Piovesana.
Submission:
Gemini Sight is an innovative application that leverages the Gemini language model to create AI-powered smart glasses integrated with various Google services. The core features of our submission include:
Voice Commands Integration: Users can perform tasks such as sending emails, scheduling events, and retrieving documents using voice commands.
Real-Time Visual Recognition: The glasses' camera can recognize objects and provide information about them in real time.
Google Services Connectivity: Seamless integration with Google Docs, Drive, Gmail, YouTube Music, Maps, Calendar, and Events to enhance productivity.
Secure Data Handling: User data is securely managed and encrypted, ensuring privacy and protection.
Our submission demonstrates the practical applications of the Gemini model in everyday life, enhancing user convenience and accessibility through advanced AI technology.
Glasses:
Download the glasses printable STL file from the models/ folder, after printing the 3D model use this circuit diagram to create the wiring. It is not necessary to solder the pieces together however it is highly recommended for space optimation.

The total price for the components is around 79.09€. Below are the components needed, with how many in the brackets and the money needed after the comma:

1. XIAO ESP32S3 Sense(x1), €28.02
2. INMP441 Microphone(x1), €7.74
3. HM-10 Bluetooth Module(x1), €4.00
4. 2 8Ω Speakers(x1), €15.13
5. MAX98357A Breakout Module(x1), €7.96
6. 3.7v Lithium Battery(x1), €9.33
7. Jumper Wire Cables(x1), €9.15

The glasses can connect in two different ways, through Bluetooth and WiFi. Bluetooth is used to share data between the app and the glasses (location, access key, contacts or sending commands), on the other hand, the glasses connect to the WiFi by scanning a QR Code which is created in the app in order to connect to the websockets.
Backend:
Gemini Sight functions thanks to two different web sockets, one written in JavaScript and the other in Dart. This setup provides additional security and separates the two main background tasks.

At the first login, information from the user's emails and docs is gathered to enhance a personalized experience. The application then sends the login authorization code to the JavaScript website, which the server processes to get the refresh token, which is encrypted and saved in the database. Once the glasses are connected through Bluetooth, data such as access keys, location, and contacts are shared with the glasses. This is also used as a communication channel for tasks like making phone calls or sending messages.
When the user connects the glasses to WiFi, an initial request is made to the Dart websocket to check for an active user with the unique access key. If an active connection is not found, a new user is added to the session. The Dart websocket parses the content generated from the Gemini API by executing the provided commands, serving as a bridge between the client and the JavaScript websocket, adding an additional security layer.
The user's input from the microphone is transcribed using Google's Speech-to-Text Module, then passed to the Dart websocket for processing and request to the JavaScript websocket, which checks for an active session or creates a new one to maintain a chatting history between Gemini and the user. The response is then parsed by the Dart websocket and executed accordingly. For Google Services, it checks the authorization code's expiration and generates a new one if needed using the saved refresh token.
# Example Conversation
Input: Hey Gemma, retrieve the project document
Response: speak(|I am retrieving information about the project document|)¬ speak(get_document(|project|))
Set up your own project by visiting the Google Cloud Console and creating a new project.

Navigate to API and Services and add Gmail, Calendar, Docs, Sheet, Drive, Tasks, YouTube Analytics, Google Maps Places and Google Maps Directions. Then create a new API key and OAuth client IDs (one for mobile devices and one for the web) and save them for later use. 
Next, go to MongoDB, create a new project and copy the connection URI.
Website:
The website was created to expand upon our product's publicity, enable its distribution and provide further insight into its creation and abilities through the AI chatbot which has been set up to answer questions related to Gemini Sight. The website can be accessed online.
In total the website offers 5 pages. The first one is the "Home" and the second one is the "About Us" section where you are provided with some information about our team. Then there is the "Product" page which describes how the glasses work although the Gtihub repository does a better job at it. Then the "Order" section is where you can order the glasses and finally a "Sign In" part of the site which is required for you to order the glasses and access the chatbot feature.
You can also run the website locally on your computer by installing the required packages and setting up the right environment variables.
For the environment variables you need to have the following:
MONGODB_URI = ""
GEMINI_API = ""
CLIENT_ID = ""
The MONGODB_URI is just the connection URI for MongoDB which you can copy once you have created a new project. Then, the GEMINI_API is just the Gemini API key which you can just create by going to the Gemini website. Finally, the CLIENT_ID is the client ID for the Google authentication which you can access by going to the Google developer console.
Then you will need to head to the server directory, install some packages and run the site like so:
# head to the right directory
$ cd server

# install the required packages
$ npm install

# run the site
$ node server.js
After that just head to http://localhost:8080/ where your site will be running.

Note: It is important to mention that the ordering of the glasses, although already set up on the website with Google Pay, does not work due to the fact that there is currently no way for our team to mass produce and distribute these glasses to a wider audience, so it has just been created as a demo part of the site and is in test mode so no payments will be accepted.
Flutter App:
The Flutter app serves multiple functions to enhance the capabilities of your smart glasses. Initially, thanks to it you can connect your glasses to a WiFi network via Bluetooth module. The app also functions as a control system, allowing Gemini to learn about you and your writing style for emails or documents using your Google data, activate blind mode to enhance and simplify daily tasks for the blind through the Gemini vision model, and access recordings and pictures taken by the glasses stored on your Google Drive. Additionally, when the glasses are connected to Bluetooth, the app serves as a bridge in order for Gemini to automatize services on your phone, such as sending texts and making calls.
How To Use:
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
MONGODB_URI = "YOUR MONGO DB URI"
GEMINI_API = "YOUR GEMINI API KEY"
API_KEY = "YOUR API KEY"
Additionally, copy and paste the payload from this [Google Doc](https://docs.google.com/document/d/1vSDI1G
zzfh56hjHgQJbXwpLhVpo1Ue2w/edit?usp=sharing&ouid=110446241726368691642&rtpof=true&sd=true) into the ./commands.js file.
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
Ensure that you can deploy the application to a physical or virtual device by following this guide(https://docs.flutter.dev/get-started/install) and verifying with the flutter doctor command. Once completed, run:
flutter run --web-port 8080 --observatory-port 8080
Note: Currently, the Flutter app was developed and tested only on iOS systems, but it should still be able to run on the most recent Android devices.
After setting up the circuit for the glasses, install and set up PlatformIO from their website(https://docs.platformio.org/en/latest/integration/ide/vscode.html#installation). Build your project and then upload it to the ESP32 XIAO Board.
You have successfully set up the project! Use the app to connect your glasses and test Gemini Sight.
Download:
You can download the latest installable iOS version of the Gemini Sight App.
Future:
Unfortunately, the GPS module didn't arrive in time meaning that the functionalities such as Google Maps directions or recording the speed are not functioning however from a coding point of view they are already developed and functioning only the actual data from the GPS that needs to be passed is missing. We plan to implement it and many other features if the project keeps getting maintained. One major problem furthermore is the Google Sheets API as the Gemini model performs poorly with creating 2D arrays from a given input, this however can be improved by feeding the model with more training data.
Credits:
This software uses the following open-source packages and tools:
1. Flutter
2. Node.js
3. PlatformIO
4. ESP32
5. ArduinoWebsockets
6. Google Cloud Platform
7. MongoDB
8. EJS
9. Google Pay
`});
let previousChats = [];
let userData = {};

const app = express();
const PORT = 8080;
const allowedPages = ['index', 'admin', 'product', 'about', 'order', 'notFound'];

app.use(express.static(path.join(__dirname, 'public/')));

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
        chats: JSON.stringify(previousChats),
        title: (req.params.id == "about" ? (aboutUsText.hasOwnProperty(req.query.name) ? req.query.name.replace(/_/g, ' ').replace(/(^| )\w/g, match => match.toUpperCase()) : "About Us") : ""),
        text: (req.params.id == "about" ? aboutUsText[req.query.name]||aboutUsText["about_us"]: "")
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
    try {
        let prompt = req.body.prompt;
        const chat = model.startChat({
            history: previousChats,
            generationConfig: {
            maxOutputTokens: 100,
            }
        });

        const result = await model.generateContent(prompt);
        previousChats.push({role: 'user', parts: [{text: prompt}]});
        previousChats.push({role: 'model', parts: [{text: result.response.text()}]});
    }
    catch (err) {
        console.error("API problem: ", err);
        res.redirect("notFound");
    }
    res.redirect("/");
});

app.post('/order', bodyparser.urlencoded(), async (req, res) => {
    try {
        let order = new Order();
        order.email = userData.email;
        order.name = userData.name;
        order.address = req.body.address;
        order.first_time = true;
        order.access_key = crypto.randomBytes(128).toString('hex');
        order.model = 0.1;
        order.query = "";
        order.refresh_key = "";
        order.ble_id = Array(4).fill(0).map(() => Math.floor(Math.random()*16).toString(16).toUpperCase()).join('') + '-' +
        Array(4).fill(0).map(() => Math.floor(Math.random()*16).toString(16).toUpperCase()).join('') + '-' + Array(4).fill(0).map(() =>
         Math.floor(Math.random()*16).toString(16).toUpperCase()).join('') + '-' + Array(4).fill(0).map(() => Math.floor(Math.random()*16).toString(16).toUpperCase()).join('') + '-' + Array(12).fill(0).map(() => Math.floor(Math.random()*16).toString(16).toUpperCase()).join('');
    
        await order.save();
        res.send(`Your Glasses will be shipped to ${order.address} as soon as possible`);
    }
    catch(err) {
        res.send("Ordering error: ", err);
    }
});

app.listen(PORT, _ => console.log(`Server running on port ${PORT}`));