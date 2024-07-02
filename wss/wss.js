const { WebSocketServer } = require('ws');
const cluster = require('cluster');
const numCPUs = require('os').cpus().length;

if (cluster.isMaster) {
    for (let i = 0; i < numCPUs; i++) {
        cluster.fork();
    }
}else{
    const fs = require('fs');
    const axios = require('axios');
    const { Database } = require('./func/db.js');
    const { Audio } = require('./func/audio.js');
    const helper = require('./func/helper.js');
    const { Model } = require('./func/model.js');
    const { Authentication } = require('./func/auth.js');
    const { Stream } = require('./func/stream_song.js');
    const { GoogleMaps } = require('./func/google_maps.js');

    const db = new Database();
    const maps = new GoogleMaps();
    const audio = new Audio('./audio/');
    const ai = new Model();
    const stream = new Stream();
    const auth = new Authentication();

    db.parseData();

    const wss = new WebSocketServer({ port: 443 });
    console.log('Websocket running on port 443');

    wss.on('connection', function connection(ws) {  
        ws.on('message', async function message(data) {
            try {
                const messageParts = data.toString('utf8').split('¬');
                const command = messageParts[0];
                const access_key = messageParts[1];

                if(await db.find('access_key', access_key)){
                    switch (command) {
                        case 'first_time':
                            {
                                const email = messageParts[2];
                                const user = await db.find('email', email);

                                ws.send(user ? "true": "false");
                            }
                            break;

                        case 'add_query':
                            {
                                const data = messageParts[2];
 
                                var response = await ai.process_data(`${data + (await db.find('access_key', access_key)).query} Represent the full data in a json provide all necessary information and reply only with that. You can use this as a reference
{
  "name": "Nikolas Coffey",
  "position": "Software Engineer",
  "company": "Google",
  "projects": [
    {
      "name": "Real-Time Collaboration Platform",
      "description": "A platform to improve communication, productivity, and security for teams.",
      "features": [
        "Instant messaging",
        "Video conferencing",
        "Collaborative editing",
        "Task management",
        "File sharing",
        "Integration with Google Workspace"
      ],
      "technology": {
        "architecture": "Microservices",
        "frontEnd": "React.js",
        "backEnd": ["Node.js", "Express.js"],
        "realTimeCommunication": ["WebRTC", "WebSockets"],
        "database": "MongoDB",
        "authentication": "OAuth 2.0",
        "deployment": "Kubernetes on Google Cloud Platform"
      },
      "responsibilities": [
        "Project planning",
        "Architecture design",
        "Development and implementation",
        "Code review",
        "Quality assurance",
        "Collaboration and communication",
        "Mentoring"
      ],
      "team": [
        {
          "name": "John Doe",
          "role": "Senior Engineering Manager",
          "email": "john.doe@google.com"
        },
        {
          "name": "Jane Smith",
          "role": "Director of Product Management",
          "email": "jane.smith@google.com"
        },
        {
          "name": "Emily Johnson",
          "role": "Software Engineer",
          "email": "emily.johnson@google.com"
        },
        {
          "name": "Michael Brown",
          "role": "UX Designer",
          "email": "michael.brown@google.com"
        }
      ],
      "tasks": [
        {
          "category": "Project Planning and Management",
          "tasks": [
            "Define Project Scope",
            "Set Timelines and Milestones",
            "Resource Allocation"
          ]
        },
        {
          "category": "Architecture Design",
          "tasks": [
            "Design System Architecture",
            "Define Microservices",
            "Scalability Planning"
          ]
        },
        {
          "category": "Front-End Development",
          "tasks": [
            "UI/UX Design",
            "Implement React.js Components",
            "Integrate with Backend APIs"
          ]
        },
        {
          "category": "Back-End Development",
          "tasks": [
            "Set Up Node.js and Express.js",
            "Develop API Endpoints",
            "Implement Business Logic"
          ]
        },
        {
          "category": "Real-Time Communication",
          "tasks": [
            "Integrate WebRTC",
            "Implement WebSockets"
          ]
        },
        {
          "category": "Database Management",
          "tasks": [
            "Design Database Schema",
            "Implement Data Storage"
          ]
        },
        {
          "category": "Authentication and Security",
          "tasks": [
            "Set Up OAuth 2.0",
            "Data Encryption",
            "Access Control"
          ]
        },
        {
          "category": "Video Conferencing Enhancements",
          "tasks": [
            "Screen Sharing",
            "Recording Features"
          ]
        },
        {
          "category": "Collaborative Editing",
          "tasks": [
            "Real-Time Document Editing",
            "Version Control"
          ]
        },
        {
          "category": "Task Management Tools",
          "tasks": [
            "Develop Task Features",
            "Integrate with Existing Tools"
          ]
        },
        {
          "category": "File Sharing",
          "tasks": [
            "Implement File Uploads",
            "Set Access Controls"
          ]
        },
        {
          "category": "Quality Assurance",
          "tasks": [
            "Testing Framework Setup",
            "Conduct Unit and Integration Tests",
            "User Acceptance Testing"
          ]
        },
        {
          "category": "Deployment",
          "tasks": [
            "Containerize Services",
            "Deploy on GCP",
            "Monitor and Optimize"
          ]
        },
        {
          "category": "Feedback and Iteration",
          "tasks": [
            "Collect User Feedback",
            "Implement Improvements"
          ]
        }
      ]
    },
    {
      "name": "Project Phoenix",
      "description": "An initiative to revamp our cloud infrastructure to improve scalability and performance.",
      "tasks": [
        "Designing microservices architecture",
        "Implementing API endpoints",
        "Conducting performance testing"
      ]
    },
    {
      "name": "AI-Driven Recommendation System",
      "description": "A system to enhance user experience through personalized recommendations.",
      "tasks": [
        "Data preprocessing and feature engineering",
        "Implementing machine learning models",
        "Evaluating model performance"
      ]
    }
  ],
  "education": {
    "degree": "Computer Science Engineering",
    "institution": "Harvard"
  },
  "skills": [
    "Python",
    "Java",
    "C++",
    "JavaScript",
    "React",
    "Angular",
    "Node.js",
    "Django",
    "AWS",
    "Google Cloud Platform",
    "Azure",
    "TensorFlow",
    "Keras",
    "scikit-learn",
    "MySQL",
    "PostgreSQL",
    "MongoDB"
  ],
  "traits": [
    "Problem-Solving",
    "Collaboration",
    "Continuous Learning",
    "Attention to Detail"
  ],
  "interests": [
    "Open Source Contributions",
    "Tech Blogging",
    "Reading",
    "Outdoor Activities"
  ]
}
`);
                                const filter = { access_key: access_key };

                                await db.Product.updateOne(filter, { query: response});
                            }
                            break;

                        case 'not_first_time':
                            {
                                const filter = { access_key: access_key };
            
                                await db.Product.updateOne(filter, { first_time: false });
                            }
                            break;

                        case 'speak':
                            {
                                const text = messageParts[2];
                                const uuid = helper.uuidv4();
            
                                const textChunks = text.split('. ');
                                var count = 0;
                                for (let chunk of textChunks) {
                                    await audio.pcm(chunk, access_key, count, uuid, ws);
                                    count++;
                                }
                            }
                            break;

                        case 'process':
                            {
                                const text = messageParts[2];
                                const response = await ai.process_data(text);
                                ws.send('r' + response);
                            }
                            break;

                        case 'media':
                            {
                                const base64Data = messageParts[2];
                                const uuid = helper.uuidv4();
                                const dirPath = `./media/${access_key}`;
                                if (!fs.existsSync(dirPath)) {
                                    fs.mkdirSync(dirPath);
                                }
                                fs.writeFileSync(`${dirPath}/${uuid}.png`, Buffer.from(base64Data, 'base64'));
                            }
                            break;

                        case 'vision':
                            {

                                const task = messageParts[2];
                                const base64Data = messageParts[3];
                                const response = await ai.model.generateContent([
                                    task,{ inlineData: { data: Buffer.from(base64Data, 'base64').toString("base64"), mimeType: 'image/png' } }
                                ]);
                                
                                ws.send('v' + response.response.text());
                            }
                            break;

                        case 'directions':
                            {
                                const origin = messageParts[2];
                                const destination = messageParts[3];

                                await maps.getDirections(origin, destination, ws);
                            }
                            break;

                        case 'get_place':
                            {
                                const query = messageParts[2];
                                var location = messageParts[3];

                                const encodedAddress = encodeURIComponent(location);
                                
                                if(location !== ''){
                                    const response = await axios.get(`https://maps.googleapis.com/maps/api/geocode/json?address=${encodedAddress}&key=${process.env.GOOGLE_MAPS_API}`);
                                    if (response.data.status === 'OK') {

                                        location = `${response.data.results[0].geometry.location.lat},${response.data.results[0].geometry.location.lng}`;
                                    }
                                }

                                await maps.searchPlaces(query, location, ws);
                            }
                            break;

                        case 'stream_song':
                            {
                                const query = messageParts[2];
                                await stream.stream_song(query, ws);
                            }
                            break;
    
                        case 'send_data':
                            {   
                                const input = messageParts[2];
                                const additional_query = (await db.find('access_key', access_key)).query;

                                const dateObj = new Date();
                                const year = dateObj.getFullYear();
                                const month = String(dateObj.getMonth() + 1).padStart(2, '0');
                                const day = String(dateObj.getDate()).padStart(2, '0');
                                const hours = String(dateObj.getHours()).padStart(2, '0');
                                const minutes = String(dateObj.getMinutes()).padStart(2, '0');
                                const formattedDate = `${year}-${month}-${day}T${hours}:${minutes}`;

                                const response = await ai.process_input(input + '{' + additional_query + '}' + `[date: ${formattedDate}]`); 
                                ws.send(response);

                                console.log(response);
                            }
                            break;
                    }
                }else{
                    if(command == "authentication"){
                        const idToken = messageParts[1];
                        const email = await auth.verifyIdToken(idToken);
                        const user = await db.find('email', email);
                        ws.send(user ? user.access_key : '');
                    }else{
                        ws.send('Request is not authenticated');
                        ws.close();
                    }
                }
            } catch (err) {
                console.log(err);
                ws.send('Internal server error');
            }
        });
    });
}

cluster.on('exit', (worker, code, signal) => {
    console.log(`Worker ${worker.process.pid} died`);
    cluster.fork();
});