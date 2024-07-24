String.prototype.replaceAt = function(start, end, str) {
    return this.substring(0, start) + str + this.substring(end);
}

const changeScreen = page => location.href = location.href.replaceAt(location.href.lastIndexOf('/'), location.href.length, "/"+page);

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