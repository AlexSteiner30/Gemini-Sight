<h1 align="center">
  <a href="https://gemini.google.com"><img src="resources/logo.png?raw=true#gh-light-mode-only" alt="Gemini Sight" width="400"></a>
</h1>

<h4 align="center">AI-powered smart glasses connected to your Google interface, entry for the <a href="https://ai.google.dev/competition" target="_blank">Gemini API Competition</a>.</h4>

<p align="center">
  <a href="#competition">Competition</a> •
  <a href="#submission">Submission</a> •
  <a href="#glasses">Glasses</a> •
  <a href="#backend">Backend</a> •
  <a href="#website">Website</a> •
  <a href="#flutter-app">Flutter App</a> •
  <a href="#how-to-use">How To Use</a> •
  <a href="#future">Future</a> •
  <a href="#credits">Credits</a> 
</p>

<h1 align="center">
  <img src="resources/main.png?raw=true" style="height: 50%; width:50%; align:center">
</h1>

## Competition

This repository is the submission for the Gemini API Developer Competition by [Alex Steiner](https://github.com/AlexSteiner30), [Fotios Vaitsopoulos](https://github.com/Epic-legend128). We are two students attending H-Farm International School of Treviso, challenging ourselves to enhance our skills and create a project we can be proud of by participating in the Gemini Developer Competition. This global competition, hosted by Google, showcases the real-world applications of the new Gemini model, with a cash prize for the winner.

Although we joined the competition one month late due to internal exams, we began our project in early to mid-June. Our idea was to create smart glasses entirely powered by Gemini and fully integrated with Google services such as Google Docs, Google Sheets, Google Drive, Gmail, YouTube Music, Google Maps, Google Calendar, Google Meet, Google Messages and Calls. These glasses are designed to automate tasks through a single voice command. Additionally, equipped with a camera, they allow the user to ask for information about their surroundings, with the model responding in real time.

Alex Steiner developed the Flutter application, the glasses' circuit and code, the two WebSockets and designed the 3D glasses. Fotios Vaitsopoulos designed and developed the whole website.

## Submission

Gemini Sight is an innovative application that leverages the Gemini language model to create AI-powered smart glasses integrated with various Google services. The core features of our submission include:

- **Voice Commands Integration**: Users can perform tasks such as sending emails, scheduling events, and retrieving documents using voice commands.
- **Real-Time Visual Recognition**: The glasses' camera can recognize objects and provide information about them in real time.
- **Google Services Connectivity**: Seamless integration with Google Docs, Drive, Gmail, YouTube Music, Maps, Calendar, and Events to enhance productivity.
- **Secure Data Handling**: User data is securely managed and encrypted, ensuring privacy and protection.

Our submission demonstrates the practical applications of the Gemini model in everyday life, enhancing user convenience and accessibility through advanced AI technology.

## Glasses
Download the glasses printable STL file from the `models/` folder, after printing the 3D model use this circuit diagram to create the wiring. It is not necessary to solder the pieces together however it is highly recommended for space optimation.

<h1 align="center">
 <img src="resources/backend.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

Down below you can find the table with the components used to build the glasses. The total price for the components is around `67.36€`.

   | **Name of Sensor**                            | **Amount** | **Price** | **Purchase Link**               |
   |-----------------------------------------------|------------|-----------|---------------------------------|
   | XIAO ESP32S3 Sense                            | 1          | €28.02    | [Buy Here](https://t.ly/RBrHw)  |
   | 2 8Ω Speakers                                 | 1          | €15.13    | [Buy Here](https://t.ly/W3Qws)  |
   | MAX98357A Breakout Module                     | 1          | €7.96     | [Buy Here](http://amoz.onl/2Q3) |
   | 3.7v Lithium Battery                          | 1          | €9.33     | [Buy Here](https://t.ly/6TUde)  |
   | Wire Cables                                   | 1          | €6.91     | [Buy Here](http://amoz.onl/2Q4) |

The glasses can connect in two different ways, through Bluetooth and WiFi. Bluetooth is used to share data between the app and the glasses (location, access key, contacts or sending commands), on the other hand, the glasses connect to the WiFi by scanning a QR Code which is created in the app in order to connect to the websockets.

## Backend

Gemini Sight functions thanks to two different web sockets, one written in JavaScript and the other in Dart. This setup provides additional security and separates the two main background tasks. This concept is visualized in the following sketch:

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

Navigate to API and Services and add `Gmail, Calendar, Docs, Sheet, Drive, Tasks, YouTube Analytics, Google Maps Places and Google Maps Directions`. Then create a new API key and OAuth client IDs (one for mobile devices and one for the web) and save them for later use.

<h1 align="center">
 <div style="display: flex; justify-content: center; align-items: center; gap: 10px;">
     <img src="resources/api.png?raw=true" style="width: 49%;" />
     <img src="resources/keys.png?raw=true" style="width: 49%;" />
 </div>
</h1>

Next, go to Firebase, create a new project [here](https://console.firebase.google.com/) and copy the connection variablesI.

## Website
The website was created to expand upon our product's publicity, enable its distribution and provide further insight into its creation and abilities through the AI chatbot which has been set up to answer questions related to Gemini Sight. The website can be accessed online [here](https://geminisight-58e89465e495.herokuapp.com) which was uploaded through the use of [Heroku](https://www.heroku.com).<br>

In total the website offers 5 pages. The first one is the "Home" and the second one is the "About Us" section where you are provided with some information about our team. Then there is the "Product" page which describes how the glasses work although the Gtihub repository does a better job at it. Then the "Order" section is where you can order the glasses for a price of $200 and finally a "Sign In" part of the site which is required for you to order the glasses and access the chatbot feature.<br>


You can also run the website locally on your computer by installing the required packages and setting up the right environment variables.<br>
For the environment variables you need to have the following:
```js
GEMINI_API = "YOUR GEMINI API"
CLIENT_ID = "YOUR CLIENT ID"
API_KEY="YOUR API KEY"
AUTH_DOMAIN="YOUR AUTH DOMAIN"
PROJECT_ID="YOUR PROJECT ID"
STORAGE_BUCKET="YOUR STORAGE BUCKET"
MESSAGING_SENDER_ID="YOUR MESSAGING SENDER ID"
APP_ID="YOUR APP ID"
MEASUREMENT_ID="YOUR MEASUREMENT ID"
```
The `GEMINI_API` is just the Gemini API key which you can just create by going [here](https://aistudio.google.com/app/apikey). Then, the `CLIENT_ID` is the client ID for the Google authentication which you can access by going to the Google developer console as shown in the [backend section](#backend). The rest are just all of the values needed for the Firebase configuration.<br>
Then you will need to head to the server directory, install some packages and run the site like so:
```bash
# head to the right directory
$ cd server

# install the required packages
$ npm install

# run the site
$ node server.js
```
After that just head to [localhost:3000](http://localhost:3000) where your site will be running.<br>

<h1 align="center">
 <img alt="Homepage" src="resources/homepage.png?raw=true" style="height: 80%; width:80%; align:center">
</h1>

_Note_: It is important to mention that the ordering of the glasses, although already set up on the website with Google Pay, does not work due to the fact that there is currently no way for our team to mass produce and distribute these glasses to a wider audience, so it has just been created as a demo part of the site and is in test mode so no payments will be accepted.

## Flutter App
The Flutter app serves multiple functions to enhance the capabilities of your smart glasses. Initially, thanks to it you can connect your glasses to a WiFi network via Bluetooth module. The app also functions as a control system, allowing Gemini to learn about you and your writing style for emails or documents using your Google data, activate blind mode to enhance and simplify daily tasks for the blind through the Gemini vision model, and access recordings and pictures taken by the glasses stored on your Google Drive. Additionally, when the glasses are connected to Bluetooth, the app serves as a bridge in order for Gemini to automatize services on your phone, such as sending texts and making calls.

<h1 align="center">
 <div style="display: flex; justify-content: center; align-items: center; gap: 0px;">
     <img src="resources/mockup_1.png?raw=true" style="width: 24%;" />
     <img src="resources/mockup_2.png?raw=true" style="width: 24%;" />
     <img src="resources/mockup_3.png?raw=true" style="width: 24%;" />
     <img src="resources/mockup_4.png?raw=true" style="width: 24%;" />
 </div>
</h1>

## How To Use

To clone and run this application, you'll need [Git](https://git-scm.com), [Node.js](https://nodejs.org/en/download/) (which comes with [npm](http://npmjs.com)), and [Flutter](https://flutter.dev) installed on your computer. From your command line:

```bash
# Clone this repository
$ git clone https://github.com/AlexSteiner30/Gemini-Sight/

# Go into the repository
$ cd Gemini-Sight

# Go into the wss directory
$ cd wss

# Install dependencies 
$ npm install
```

Create a new environment file under `./database/.env` and save the following environment variables:

```js
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
```

Copy and paste the payload from this [Google Doc](https://docs.google.com/document/d/1vSDI1GnhkzvIxU8-Ivmz65zpxOH9fXzmfSPuA8jI8OY/edit?usp=sharing).

To start the websocket server, run the following:

```bash
# Run the local server
$ npm start
```

Continue by Navigating to `/Gemini-Sight/dart_wss/wss` and set up your application as follows:
```bash
# Export API Key
$ export API_KEY="YOUR API KEY"

# Get device IP address
$ ifconfig en0

# Update the IP address in the websocket configuration
$ open helper.dart

# On line 4, change to
Uri.parse('ws://<your IP address>:443'),

# Update the IP address in the websocket configuration
$ open user/socket.dart

# On line 50, change to
Uri.parse('ws://<your IP address>:443'),

# Run web socket
$ dart run wss.dart
```

Navigate to the `/Gemini-Sight/app` directory and set up your application as follows:

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

After setting up the circuit for the glasses, install and set up PlatformIO from [here](https://docs.platformio.org/en/latest/integration/ide/vscode.html#installation). Build your project and then upload it to the ESP32 XIAO Board.

**You have successfully set up the project! Use the app to connect your glasses and test Gemini Sight.**

## Download

You can [download](https://github.com/amitmerchant1990/electron-markdownify/releases/tag/v1.2.0) the latest installable iOS version of the Gemini Sight App.

## Future
Unfortunately, the GPS module didn't arrive in time meaning that the functionalities such as Google Maps directions or recording the speed are not functioning however from a coding point of view they are already developed and functioning only the actual data from the GPS that needs to be passed is missing. We plan to implement it and many other features if the project keeps getting maintained. One major problem furthermore is the Google Sheets API as the Gemini model performs poorly with creating 2D arrays from a given input, this however can be improved by feeding the model with more training data.

## Credits

This software uses the following open-source packages and tools:

- [Flutter](https://flutter.dev/)
- [Node.js](https://nodejs.org/)
- [PlatformIO](https://platformio.org/)
- [ESP32](https://www.espressif.com/)
- [ArduinoWebsockets](https://www.arduino.cc/reference/en/libraries/arduinowebsockets/)
- [Google Cloud Platform](https://cloud.google.com/)
- [EJS](https://ejs.co/)
- [Google Pay](https://pay.google.com/about/)
- [Firebase](https://firebase.google.com)
- [I2S WAV File](https://github.com/atomic14/esp32_audio/tree/master/i2s_output)
- [Heroku](https://www.heroku.com)

A special thanks also to my dad, Marco Baroni, (https://www.facebook.com/marcodirimini/) who helped me through the entire process by supporting me financially, morally, helping me with the planning and designing the glasses.

> [alexsteiner.dev](https://www.alexsteiner.dev) &nbsp;&middot;&nbsp;
> [epic-legend128](https://github.com/Epic-legend128) &nbsp;&middot;&nbsp;
