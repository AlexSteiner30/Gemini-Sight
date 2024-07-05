String.prototype.replaceAt = function(start, end, str) {
    return this.substring(0, start) + str + this.substring(end);
}

function changeScreen(page) {
    location.href = location.href.replaceAt(location.href.lastIndexOf('/'), location.href.length, "/"+page);
}

function signOut() {
    var auth2 = gapi.auth2.getAuthInstance();
    auth2.signOut().then(function () {
        console.log('User signed out.');
        changeScreen("logout");
    });
}

function createNavAndFooter() {
    let sign = (document.getElementById("logged-in").value ? '<a onClick="signOut()">Sign Out</a>' : '<a href="admin">Sign In</a>');
    document.getElementsByTagName("body")[0].innerHTML = `
        <nav>    
            <div></div>
            <a href="index">Home</a>
            <a href="about">About Us</a>
            <a href="function">Functioning</a>
            <a href="order">Order</a>
    `       +sign+`
        </nav>
    ` + document.getElementsByTagName("body")[0].innerHTML + `
        <footer>
            <p>Copyright (c) 2024 Alex Steiner</p>
        </footer>
    `;
}

createNavAndFooter();