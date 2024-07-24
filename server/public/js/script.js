String.prototype.replaceAt = function(start, end, str) {
    return this.substring(0, start) + str + this.substring(end);
}

const changeScreen = page => location.href = location.href.replaceAt(location.href.lastIndexOf('/'), location.href.length, "/"+page);

const processOutput = (text, counter=0) => (text.replace(/(\*\*)/g, _ => ((++counter)&1 ? "<strong>" : "</strong>"))).replace(/(\*)/g, "<br>");

function createNavAndFooter() {
    let sign;
    if (document.getElementById("logged-in").value) {
        let chats = JSON.parse(document.getElementById("chats").value);
        let addition = "";
        if (chats.length > 0 && chats != []) { 
            chats.forEach(x => {
                if (x.role == "user") addition += "<div></div>";
                addition += "<label>"+processOutput(x.parts[0].text)+"</label>";
                if (x.role == "model") addition += "<div></div>";
            });
        }
        document.getElementsByTagName("body")[0].innerHTML += `
            <form id='chat-area' method='POST' action='/chat'>
                <input type="button" id="vis-btn" value="Chat">
                <div id='chat-prev'><div id='chat-grid'>`+addition+`</div></div>
                <input type='text' id='chat-input' placeholder='Enter prompt...' name='prompt'>
            </form>
        `;
        document.getElementById("chat-prev").style.display = "none";
        document.getElementById("chat-input").style.display = "none";

        sign = '<a href="logout">Sign Out</a>';
    }
    else sign = '<a href="admin">Sign In</a>';
    
    document.getElementsByTagName("body")[0].innerHTML = `
        <nav>    
        <a href="index" id='ignore'><img alt='Logo of Gemin-eye' src='../media/logo.png'></a>
        <a href="index">Home</a>
        <a href="about?name=about_us">About Us</a>
        <a href="product">Product</a>
        <a href="order">Order</a>
        <div></div>
        `+sign+`
        <div></div>
        </nav>
    ` + document.getElementsByTagName("body")[0].innerHTML + `
        <footer>
            <p>Copyright (c) 2024 Alex Steiner</p>
        </footer>
    `;
}

createNavAndFooter();

if (document.getElementById("logged-in").value) {
    document.getElementById("vis-btn").addEventListener("click", function(e) {
        if (e.target.value == "Close") {
            document.getElementById("chat-area").style.animationDuration = "300ms";
            document.getElementById("chat-area").style.animationFillMode = "forwards";
            document.getElementById("chat-area").style.animationName = "hide";

            setTimeout(_ => {
                document.getElementById("vis-btn").value = "Chat";
                document.getElementById("chat-prev").style.display = "none";
                document.getElementById("chat-input").style.display = "none";
                document.getElementById("chat-area").style.animationName = "show";
            }, 300);
        }
        else if (e.target.value == "Chat") {
            document.getElementById("chat-area").style.animationDuration = "300ms";
            document.getElementById("chat-area").style.animationFillMode = "forwards";
            document.getElementById("chat-area").style.animationName = "hide";
            setTimeout(_ => {
                document.getElementById("vis-btn").value = "Close";
                document.getElementById("chat-prev").style.display = "block";
                document.getElementById("chat-input").style.display = "inline";
                document.getElementById("chat-area").style.animationName = "show";
            }, 300);
        }
    });
}