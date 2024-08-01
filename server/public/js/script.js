const isChatOpen = "QWERTYUIOIHZR>UUTFGJVKJHKBKJBuoòfcvwouvbwòrifbwjkgrb hjkfvbwrfhjkby32rg239r23ur9023rh2v34igt84gf08gf4f83iub";

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
                <div id='chat-prev'><div id='chat-grid'>`+addition+`</div></div>
                <input type='text' id='chat-input' placeholder='Enter prompt...' name='prompt'>
            </form>
            
            <button id='chat-btn'>
                <img class='chat-img' src='../media/chat.png' alt='Open Chat'>
                <img class='chat-img' src='../media/arrow.png' alt='Close Chat'>
            </button>
        `;
        if (!window.localStorage.hasOwnProperty(isChatOpen)) localStorage[isChatOpen] = 'false';
        let index = !(window.localStorage[isChatOpen] == 'true');
        document.getElementsByClassName("chat-img")[index+0].style.display = "none";
        document.getElementById("chat-area").style.opacity = (!index+0).toString();
        document.getElementById("chat-area").style.zIndex = ((!index+0) ? "1" : "-1");

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
            <a href="https://www.google.com" class="google-logo">
                <img title="Google" alt="Google" src="https://www.gstatic.com/images/branding/googlelogo/svg/googlelogo_light_clr_148x48px.svg">
            </a>
            <a href="https://policies.google.com">
                <span>Privacy & Terms</span>
            </a>
            <a>
                <span>© Gemini Sight</span>
            </a>
        </footer>
        `;
}

createNavAndFooter();

if (document.getElementById("logged-in").value) {
    let open = document.getElementsByClassName("chat-img")[0];
    let close = document.getElementsByClassName("chat-img")[1];
    let area = document.getElementById("chat-area");
    document.getElementById("chat-btn").addEventListener("click", function(e) {
        console.log(window.localStorage[isChatOpen]);
        if (window.localStorage[isChatOpen] == "false") {
            window.localStorage[isChatOpen] = 'true';
            area.style.zIndex = "1";
            area.style.animationDuration = "300ms";
            area.style.animationFillMode = "forwards";
            area.style.animationName = "show";

            open.style.animationDuration = "300ms";
            open.style.animationFillMode = "forwards";
            open.style.animationName = "hide";
            setTimeout(_ => {
                open.style.display = "none";
                close.style.opacity = "0";
                close.style.display = "block";
                close.style.animationDuration = "300ms";
                close.style.animationFillMode = "forwards";
                close.style.animationName = "show";
            }, 300);
        }
        else {
            window.localStorage[isChatOpen] = 'false';
            area.style.zIndex = "-1";
            area.style.animationDuration = "300ms";
            area.style.animationFillMode = "forwards";
            area.style.animationName = "hide";
            
            close.style.animationDuration = "300ms";
            close.style.animationFillMode = "forwards";
            close.style.animationName = "hide";
            setTimeout(_ => {
                close.style.display = "none";
                open.style.opacity = "0";
                open.style.display = "block";
                open.style.animationDuration = "300ms";
                open.style.animationFillMode = "forwards";
                open.style.animationName = "show";
            }, 300);
        }
    });
}