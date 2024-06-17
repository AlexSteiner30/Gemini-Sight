async function postData(url = "", data = {}) {
  const response = await fetch(url, {
    method: "POST",
    mode: "cors",
    cache: "no-cache", 
    credentials: "same-origin", 
    headers: {
      "Content-Type": "application/json",
    },
    referrerPolicy: "no-referrer",
    body: JSON.stringify(data), 
  });
  return response.json(); 
}

const express = require('express');

const app = express();
app.use(express.json());

app.post('/pcm', (req, res) => {
  console.log(req.body.pcm);
  res.send('Data Received');
});

app.listen(9000, async function(){
  console.log('Server running on port 9000');
  await postData("http://localhost:8000/api/input/", { access_key: 'HghVcPRAzR6n1YUiy0rGTX3DoqxgydA', input: 'Come up with a product name for a new app that helps people learn how to play the violin.', ip: '172.28.16.2'}).then((data) => {
    console.log(data); 
  });
});