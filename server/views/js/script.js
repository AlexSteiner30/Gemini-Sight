function createNavAndFooter() {
    let sign = (document.getElementById("logged-in").value ? '<a href="logout">Sign Out</a>' : '<a href="admin">Sign In</a>');
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