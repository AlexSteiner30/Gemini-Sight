<h1 align="center">
  <br>
  <a href="https://gemini.google.com"><img src="https://upload.wikimedia.org/wikipedia/commons/4/45/Gemini_language_model_logo.png" alt="Gemini Sight" width="500"></a>
  <br>
  <br>
</h1>

<h4 align="center">AI-powered smart glasses connected to your Google interface, entry for <a href="https://ai.google.dev/competition" target="_blank">Gemini API Competition</a>.</h4>

<p align="center">
  <a href="https://badge.fury.io/js/electron-markdownify">
    <img src="https://badge.fury.io/js/electron-markdownify.svg"
         alt="Gitter">
  </a>
  <a href="https://gitter.im/amitmerchant1990/electron-markdownify"><img src="https://badges.gitter.im/amitmerchant1990/electron-markdownify.svg"></a>
  <a href="https://saythanks.io/to/bullredeyes@gmail.com">
      <img src="https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg">
  </a>
  <a href="https://www.paypal.me/AmitMerchant">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat">
  </a>
</p>

<p align="center">
  <a href="#competition">Competition</a> •
  <a href="#submission">Submission</a> •
  <a href="#glasses">Glasses</a> •
  <a href="#glasses">Backend</a> •
  <a href="#website">Website</a> •
  <a href="#flutter-app">Flutter App</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#credits">Credits</a> •
  <a href="#license">License</a>
</p>

<h1 align="center">
 <img src="https://cdn.cs.1worldsync.com/fe/0d/fe0dfcfa-b762-43ca-9519-3342449a33fb.jpg" style="height: 80%; width:80%; align:center">
</h1>

## Competition
This repository is the submission for the Gemini API Developer Competition by [Alex Steiner](https://github.com/AlexSteiner30), [Fotios Vaitsopoulos](https://github.com/Epic-legend128) and [Lorenzo Dominijani](https://www.instagram.com/lorenzo.dominijanni/). We are a group of students attending H-Farm International School of Treviso, we wanted to challenge ourselves by joining the Gemini Developer Competition in order to improve our skill set and create something we could be proud of. The competition itself consists of a worldwide competition hosted by Google, to showcase how the new Gemini model can be implemented in real-world applications, with a cash prize for the winner.

Unfortunately, we joined the competition one month after it began because we were overwhelmed by internal exams, however, this didn't stop us from joining the competition in early/middle June. We came up with the idea to create smart completly powered by Gemini and fully connected to all Google services such as Google Docs, Google Drive, Gmail, Youtube Music, Google Maps, Google Calendar and Google Events, in order to automate from a single voice command. The glasses being equipped with a camera also give the opportunity to showcase in a real tiem the power of Gemini Pro Vision meaning that the user can simply ask information about what is infront of him and the model will respond in a real time.

## Submission
Write here about the product 

## Glasses

## Backend
Gemini Sight functions thanks to two different web sockets one written in javascript and the other one written in dart, the purpose of this is to have additional security and to separate the two main background tasks. This concept can be visualized by the following sketch.
<h1 align="center">
 <img src="https://github.com/AlexSteiner30/GeminiSight/blob/5623f733cf60c59ace5a7b79ee43568da24f177b/resources/backend.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

At the first login in the app from the user information from his emails and docs are gathered in order to enhance a personalized experience, secondly the application sends to the javasript website the loging authorization code which the server processes in order to ge the refresh token which is then saved is ecnrypted and then saved in the database. From the app, once the glasses are connected through Bleuthooth data such as access key,location and contacts are shared to the glasses, furthermore this is used as communication channel in order to perform tasks such as launching a phone call or sending a message.

Once the user connects the glasses to WiFi an initial request is performed to the dart websocket which will check for an active user with the unique access key, if an active connection is not found a new user is added to the session. The dart web socket takes care of parsing the content generated from the Gemini API by executing the commands provided, it is also a bridge between the client and the javascript websocket serving as an additional security level to avoid direct connection from the client.  

The users input from the microphone is transcribed using Google's Speech-To-Text Module which is then passed to the dart websocket which sorts it out and makes a request to the javascript websocket, which checks for an active session with the user throught the activation key, if not founded it creates a new one, this is done in order to get retrieve/create a chatting history between Gemini and the user, the model thanks to a payload. The response is then passed to the dart websocket which parses the response and executes the corresponding functions. When using the Google Services it checks whether the last authorization code has expired or no (duration 1 hour, Gemni Sight checks every 50 minutes), if it has through the initally saved refresh token a new authorization code is generated thanks to which model can perform cloud related tasks from the users inout.

```bash
# Example Conversation
Input: Hey Gemma, retrieve the project document
Response: speak(|I am retriving information about the project document|)¬ speak(get_document(|project|))
```

You can setup your own project by going to the [Google Cloud Console](https://console.cloud.google.com/welcome/new?project=sinuous-branch-426313-q6) and creating a new project

<h1 align="center">
 <img src="https://github.com/AlexSteiner30/GeminiSight/blob/5623f733cf60c59ace5a7b79ee43568da24f177b/resources/new_project.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

Navigate to API and Services and add `Gmail, Calendar, Docs, Sheet, Drive, Tasks, Youtube Analytics, Google Maps Places, Google Maps Directions`. Then create a new API key and OAuth client IDs (one for mobile devices and one web), save them for later on.

<h1 align="center">
 <div style="display: flex; justify-content: center; align-items: center; gap: 10px;">
     <img src="https://github.com/AlexSteiner30/GeminiSight/blob/7b66fd2065726c01c1fb07d718ef3f64d1e29d04/resources/api.png?raw=true" style="width: 49%;" />
     <img src="https://github.com/AlexSteiner30/GeminiSight/blob/7b66fd2065726c01c1fb07d718ef3f64d1e29d04/resources/keys.png?raw=true" style="width: 49%;" />
 </div>
</h1>

Next go to MongoDB and create a new [new project](https://cloud.mongodb.com) and copy the connection URI.

## Website
Leave this empy for now

## Flutter App

## How To Use

To clone and run this application, you'll need [Git](https://git-scm.com), [Node.js](https://nodejs.org/en/download/) (which comes with [npm](http://npmjs.com)) and [Flutter](https://flutter.dev) installed on your computer. From your command line:

```bash
# Clone this repository
$ git clone https://github.com/AlexSteiner30/GeminiSight/

# Go into the repository
$ cd GeminiSight

# Go into the wss directory
$ cd wss

# Install dependencies 
$ npm install
```

Create a new environment file under `./database/.env` and saving the following environment variables:
```js
CLIENT_ID = "YOUR CLIENT ID"
CLIENT_SECRET = "YOUR CLIENT SECRET"
MONGODB_URI = "YOUR MONGO DB URI"
GEMINI_API = "YOUR GEMINI API KEY"
API_KEY = "YOUR API KEY"
```

Additionally copy and paste the payload from this [Google Docs](https://docs.google.com/document/d/1vSDI1GnhkzvIxU8-Ivmz65zpxOH9fXzmfSPuA8jI8OY/edit) and a new enviroment variable:
```js
PAYLOAD= "PAYLOAD YOU COPIED"
```

Now you are ready to run the first websocket by running the following command:
```bash
$ node wss.js
```

Open a new terminal under the `GeminiSight` repository folder and execute the following commands:

```bash
# Go into the dart_wss directory
$ cd dart_wss
$ dart run wss.dart
```

Your second websocket is running now running, open again a new terminal under the `GeminiSight` repository folder and execute the following commands:
```bash
# Go into the dart_wss directory
$ cd app

# Copy your ip address
$ ifconfig en0

# Change the ip address of the websocket
$ open lib/helper/socket.dart

# On line 4 change the following line to
Uri.parse('ws://<your ip address>:443'),
```

Two other changes you have to make are replacing the Client ID and the Server Client ID with your own ones to do this execute the following commands:
```bash
$ open lib/main

# On line 5 change the following line to
const String CLIENT_ID =
    '<your client id>';

# On line 6 change the following line to
const String SERVER_CLIENT_ID =
    '<your server client id>';
```

After having installed and configured flutter make sure that you can deploy the application to a physical or virtual device, [see this guide](https://docs.flutter.dev/get-started/install), verify running the ```$ flutter doctor``` command. Once this is complited run under the last terminal window the following command:
```bash
flutter run --web-port 8080 --observatory-port 8080
```
> *Note*
> Currently the flutter app was developed and tested only on iOS systems however the app should still be able to run on the most recent android devices

Once you printed and setted up the circuit for the glasses install arduino by download it from [here](https://www.arduino.cc/en/software). Make sure to configure the IDE for the ESP32 boards.

In your Arduino IDE, go to **File> Preferences**
   - Enter the following into the “Additional Board Manager URLs” field:
     `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
     Then, click the “OK” button.
   - Open the Boards Manager. Go to **Tools > Board > Boards Manager…**
   - Search for ESP32 and press the install button for the “ESP32 by Espressif Systems“ _version 2.0.5_
   - It should be installed after a few seconds.
   - Download the [ArduinoWebsockets](https://www.arduino.cc/reference/en/libraries/arduinowebsockets/) libraries
   - iI your Arduino IDE, go to **Sketch > Include Library > Add .zip Library** and select the libraries you’ve just downloaded

Upload Code to ESP32 and Arduino*
   - Navigate to the `electronics/` directory, and upload the `electronics.ino` file to your ESP32 Board.
   - Go to **Tools > Board** and select **AI-Thinker ESP32-CAM**
   - Go to **Tools > Port** and select the COM port the ESP32-CAM is connected to.
   - Then, click the **Upload** button in your Arduino IDE.
   - When you start to see some dots on the debugging window, press the ESP32-CAM on-board RST button.
   - After a few seconds, the code should be successfully uploaded to your board.
   - When you see the **“Done uploading”** message, you need to remove `GPIO 0` from `GND` and press the RST button to the code code.


**You have successfully set up the project! Use the app to conenct your glasses and test Gemini Sight.** 

## Download

You can [download](https://github.com/amitmerchant1990/electron-markdownify/releases/tag/v1.2.0) the latest installable iOS version of the Gemini Sight App.

## Emailware

Markdownify is an [emailware](https://en.wiktionary.org/wiki/emailware). Meaning, if you liked using this app or it has helped you in any way, I'd like you send me an email at <bullredeyes@gmail.com> about anything you'd want to say about this software. I'd really appreciate it!

## Credits

This software uses the following open source packages:

- [Flutter](http://electron.atom.io/)
- [Node.js](https://nodejs.org/)
- write other packages and tools used 

## Support

<a href="https://buymeacoffee.com/alexsteiner" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

<p>Or</p> 

<a href="https://www.patreon.com/amitmerchant">
	<img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>

---

> [alexsteiner.dev](https://www.alexsteiner.dev) &nbsp;&middot;&nbsp;
> [epic-legend128](https://github.com/Epic-legend128) &nbsp;&middot;&nbsp;
> [lorenzo.dominijani](https://www.instagram.com/lorenzo.dominijanni/)
