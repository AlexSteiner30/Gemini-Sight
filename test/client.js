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

postData("http://localhost:8000/api/input/", { access_key: 'HghVcPRAzR6n1YUiy0rGTX3DoqxgydA', input: 'what is 3+3' }).then((data) => {
  console.log(data); 
});