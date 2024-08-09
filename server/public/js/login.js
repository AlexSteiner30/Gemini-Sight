function onSignIn(googleUser) {
    var id_token = googleUser.credential;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/signin');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = _ => console.log('Signed in');
    xhr.onreadystatechange = function() {
        if (this.readyState === 4) changeScreen((this.status === 200 ? "index" : "notFound"));
    }
    xhr.send(JSON.stringify({token: id_token}));
}