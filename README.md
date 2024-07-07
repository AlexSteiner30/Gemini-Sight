<h1 align="center">
  <br>
  <a href="https://gemini.google.com"><img src="https://upload.wikimedia.org/wikipedia/commons/4/45/Gemini_language_model_logo.png" alt="Gemin-Eye" width="500"></a>
  <br>
  <br>
</h1>

<h4 align="center">AI-powered smart glasses connected to your Google interface, entry for the <a href="https://ai.google.dev/competition" target="_blank">Gemini API Competition</a>.</h4>

<p align="center">
  <a href="https://badge.fury.io/js/electron-markdownify">
    <img src="https://badge.fury.io/js/electron-markdownify.svg" alt="Gitter">
  </a>
  <a href="https://gitter.im/amitmerchant1990/electron-markdownify">
    <img src="https://badges.gitter.im/amitmerchant1990/electron-markdownify.svg" alt="Gitter">
  </a>
  <a href="https://saythanks.io/to/bullredeyes@gmail.com">
    <img src="https://img.shields.io/badge/SayThanks.io-%E2%98%BC-1EAEDB.svg" alt="Say Thanks">
  </a>
  <a href="https://www.paypal.me/AmitMerchant">
    <img src="https://img.shields.io/badge/$-donate-ff69b4.svg?maxAge=2592000&amp;style=flat" alt="Donate">
  </a>
</p>

<p align="center">
  <a href="#competition">Competition</a> •
  <a href="#submission">Submission</a> •
  <a href="#glasses">Glasses</a> •
  <a href="#backend">Backend</a> •
  <a href="#website">Website</a> •
  <a href="#flutter-app">Flutter App</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#credits">Credits</a> 
</p>

<h1 align="center">
  <img src="https://cdn.cs.1worldsync.com/fe/0d/fe0dfcfa-b762-43ca-9519-3342449a33fb.jpg" style="height: 80%; width:80%; align:center">
</h1>

## Competition

This repository is the submission for the Gemini API Developer Competition by [Alex Steiner](https://github.com/AlexSteiner30), [Fotios Vaitsopoulos](https://github.com/Epic-legend128), and [Lorenzo Dominijani](https://www.instagram.com/lorenzo.dominijanni/). We are a group of students attending H-Farm International School of Treviso, who wanted to challenge ourselves by joining the Gemini Developer Competition to improve our skill set and create something we could be proud of. The competition consists of a worldwide competition hosted by Google, showcasing how the new Gemini model can be implemented in real-world applications, with a cash prize for the winner.

Unfortunately, we joined the competition one month after it began because we were overwhelmed by internal exams. However, this didn't stop us from joining the competition in early/mid-June. We came up with the idea to create smart glasses completely powered by Gemini and fully connected to all Google services such as Google Docs, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, and Google Events, to automate tasks from a single voice command. The glasses, equipped with a camera, also allow the user to ask for information about what is in front of them, with the model responding in real time.

## Submission

Gemin-Eye is an innovative application that leverages the Gemini language model to create AI-powered smart glasses integrated with various Google services. The core features of our submission include:

- **Voice Commands Integration**: Users can perform tasks such as sending emails, scheduling events, and retrieving documents using voice commands.
- **Real-Time Visual Recognition**: The glasses' camera can recognize objects and provide information about them in real-time.
- **Google Services Connectivity**: Seamless integration with Google Docs, Drive, Gmail, YouTube Music, Maps, Calendar, and Events to enhance productivity.
- **Secure Data Handling**: User data is securely managed and encrypted, ensuring privacy and protection.

Our submission demonstrates the practical applications of the Gemini model in everyday life, enhancing user convenience and accessibility through advanced AI technology.

## Glasses
Download the glasses printable STL file from [here](), after printing the 3D model use this circuit diagram to create the wiring.
<h1 align="center">
 <img src="resources/backend.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

Down below you can find the table with the components used to build the glasses

   | **Name of Sensor**                            | **Amount** | **Price** | **Purchase Link**               |
   |-----------------------------------------------|------------|-----------|---------------------------------|
   | XIAO ESP32S3 Sense                            | 1          | €28.02    | [Buy Here](https://t.ly/RBrHw)  |
   | INMP441 Microphone                            | 1          | €7.74     | [Buy Here](https://t.ly/oiMWj)  |
   | HM-10 Bluetooth Module                        | 1          | €4.00     | [Buy Here](https://t.ly/S-Ilr)  |
   | 2 8Ω Speakers                                 | 1          | €15.13    | [Buy Here](https://t.ly/W3Qws)  |
   | 3.7v Lithium Battery                          | 1          | €9.33     | [Buy Here](https://t.ly/6TUde)  |
   | Jumper Wire Cables                            | 1          | €9.15     | [Buy Here](http://amoz.onl/2Pp) |

The glasses can connect in two different ways, through Bluetooth and WiFi. Bluethooth is used to share data between the app and the glasses (location, access key, contacts or sending commands), on the other hand the glasses connect to the WiFi scanning a QR Code whihch is created in the app in order to connect to the websockets.

## Backend

Gemin-Eye functions thanks to two different web sockets, one written in JavaScript and the other in Dart. This setup provides additional security and separates the two main background tasks. This concept is visualized in the following sketch:

<h1 align="center">
 <img src="resources/backend.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

At the first login, information from the user's emails and docs is gathered to enhance a personalized experience. The application then sends the login authorization code to the JavaScript website, which the server processes to get the refresh token, which is encrypted and saved in the database. Once the glasses are connected through Bluetooth, data such as access keys, location, and contacts are shared with the glasses. This is also used as a communication channel for tasks like making phone calls or sending messages.

When the user connects the glasses to WiFi, an initial request is made to the Dart websocket to check for an active user with the unique access key. If an active connection is not found, a new user is added to the session. The Dart websocket parses the content generated from the Gemini API by executing the provided commands, serving as a bridge between the client and the JavaScript websocket, adding an additional security layer.

The user's input from the microphone is transcribed using Google's Speech-to-Text Module, then passed to the Dart websocket for processing and request to the JavaScript websocket, which checks for an active session or creates a new one to maintain a chatting history between Gemini and the user. The response is then parsed by the Dart websocket and executed accordingly. For Google Services, it checks the authorization code's expiration and generates a new one if needed using the saved refresh token.

```bash
# Example Conversation
Input: Hey Gemma, retrieve the project document
Response: speak(|I am retrieving information about the project document|)¬ speak(get_document(|project|))
```

Set up your own project by visiting the [Google Cloud Console](https://console.cloud.google.com/welcome/new?project=sinuous-branch-426313-q6) and creating a new project.

<h1 align="center">
 <img src="resources/new_project.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

Navigate to API and Services and add `Gmail, Calendar, Docs, Sheet, Drive, Tasks, YouTube Analytics, Google Maps Places, Google Maps Directions`. Then create a new API key and OAuth client IDs (one for mobile devices and one for the web) and save them for later use.

<h1 align="center">
 <div style="display: flex; justify-content: center; align-items: center; gap: 10px;">
     <img src="resources/api.png?raw=true" style="width: 49%;" />
     <img src="resources/keys.png?raw=true" style="width: 49%;" />
 </div>
</h1>


Next, go to MongoDB and create a new project [here](https://cloud.mongodb.com) and copy the connection URI.

## Website

(Leave this empty for now.)

## Flutter App

(Details about the Flutter app here.)

## How To Use

To clone and run this application, you'll need [Git](https://git-scm.com), [Node.js](https://nodejs.org/en/download/) (which comes with [npm](http://npmjs.com)), and [Flutter](https://flutter.dev) installed on your computer. From your command line:

```bash
# Clone this repository
$ git clone https://github.com/AlexSteiner30/GEMIN-EYE/

# Go into the repository
$ cd GEMIN-EYE

# Go into the wss directory
$ cd wss

# Install dependencies 
$ npm install
```

Create a new environment file under `./database/.env` and save the following environment variables:

```js
CLIENT_ID = "YOUR CLIENT ID"
CLIENT_SECRET = "YOUR CLIENT SECRET"
MONGODB_URI = "YOUR MONGO DB URI"
GEMINI_API = "YOUR GEMINI API KEY"
API_KEY = "YOUR API KEY"
```

Additionally, copy and paste the payload from this [Google Doc](https://docs.google.com/document/d/1vSDI1G

zzfh56hjHgQJbXwpLhVpo1Ue2w/edit?usp=sharing&ouid=110446241726368691642&rtpof=true&sd=true) into the `./commands.js` file.

To start the websocket server, run the following:

```bash
# Run the local server
$ npm start
```

Navigate to the `/GEMIN-EYE/app` directory and set up your application as follows:

```bash
# Get device IP address
$ ifconfig en0

# Update the IP address in the websocket configuration
$ open lib/helper/socket.dart

# On line 4, change to
Uri.parse('ws://<your IP address>:443'),
```

Replace the Client ID and Server Client ID with your own by executing:

```bash
$ open lib/main

# On line 5, change to
const String CLIENT_ID = '<your client id>';

# On line 6, change to
const String SERVER_CLIENT_ID = '<your server client id>';
```

Ensure that you can deploy the application to a physical or virtual device by following [this guide](https://docs.flutter.dev/get-started/install) and verifying with the `flutter doctor` command. Once completed, run:

```bash
flutter run --web-port 8080 --observatory-port 8080
```

*Note:* Currently, the Flutter app was developed and tested only on iOS systems, but it should still be able to run on the most recent Android devices.

After setting up the circuit for the glasses, install Arduino from [here](https://www.arduino.cc/en/software). Configure the IDE for ESP32 boards:

1. Go to **File > Preferences**
2. Enter the following in the “Additional Board Manager URLs” field: `https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json`
3. Click “OK”
4. Open Boards Manager: **Tools > Board > Boards Manager…**
5. Search for ESP32 and install “ESP32 by Espressif Systems” version 2.0.5
6. Download the [ArduinoWebsockets](https://www.arduino.cc/reference/en/libraries/arduinowebsockets/) library
7. Include the library in Arduino IDE: **Sketch > Include Library > Add .zip Library**

Upload Code to ESP32:

1. Navigate to the `electronics/` directory and upload the `electronics.ino` file to your ESP32 Board
2. Go to **Tools > Board** and select **AI-Thinker ESP32-CAM**
3. Go to **Tools > Port** and select the COM port the ESP32-CAM is connected to
4. Click the **Upload** button
5. When you see dots on the debugging window, press the ESP32-CAM on-board RST button
6. After a few seconds, the code should upload successfully
7. When you see the “Done uploading” message, remove `GPIO 0` from `GND` and press the RST button

**You have successfully set up the project! Use the app to connect your glasses and test Gemin-Eye.**

## Download

You can [download](https://github.com/amitmerchant1990/electron-markdownify/releases/tag/v1.2.0) the latest installable iOS version of the Gemin-Eye App.

## Credits

This software uses the following open-source packages and tools:

- [Flutter](https://flutter.dev/)
- [Node.js](https://nodejs.org/)
- [Arduino](https://www.arduino.cc/)
- [ESP32 by Espressif Systems](https://www.espressif.com/)
- [ArduinoWebsockets](https://www.arduino.cc/reference/en/libraries/arduinowebsockets/)
- [Google Cloud Platform](https://cloud.google.com/)
- [MongoDB](https://www.mongodb.com/)
- [EJS](https://ejs.co)

## Support

<a href="https://buymeacoffee.com/alexsteiner" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/purple_img.png" alt="Buy Me A Coffee" style="height: 41px; width: 174px; box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5); -webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5);"></a>

<p>Or</p> 

<a href="https://www.patreon.com/amitmerchant">
  <img src="https://c5.patreon.com/external/logo/become_a_patron_button@2x.png" width="160">
</a>

> [alexsteiner.dev](https://www.alexsteiner.dev) &nbsp;&middot;&nbsp;
> [epic-legend128](https://github.com/Epic-legend128) &nbsp;&middot;&nbsp;
> [lorenzo.dominijani](https://www.instagram.com/lorenzo.dominijanni/)
