function createNavAndFooter() {
    let sign;
    if (document.getElementById("logged-in").value) {
        let chats = JSON.parse(document.getElementById("chats").value);
        let addition = "";
        if (chats.length > 0 && chats != []) { 
            console.log(chats);
            chats.forEach(x => {
                addition += "<label>"+x.parts[0].text+"</label>";
            });
        }
        console.log(addition);
        document.getElementsByTagName("body")[0].innerHTML += `
            <form id='chat-area' method='POST' action='/chat'>
                <div id='chat-prev'>"`+addition+`"</div>
                <input type='text' id='chat-input' placeholder='Enter prompt...' name='prompt'>
            </form>
        `;

        sign = '<a href="logout">Sign Out</a>';

    }
    else {
        sign = '<a href="admin">Sign In</a>';
    }
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