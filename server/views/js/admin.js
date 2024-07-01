function onSignIn(googleUser) {
    var id_token = googleUser.getAuthResponse().id_token;
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/signin');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = function() {
        console.log('Signed in as: ' + xhr.responseText);
    };
    var profile = googleUser.getBasicProfile();
    xhr.send(JSON.stringify({token: id_token, email: profile.getEmail()}));
}