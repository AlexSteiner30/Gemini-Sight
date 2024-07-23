const disablePayment = text => document.getElementById("container").innerHTML += `<h2>${text}</h2>`;

if (document.getElementById("logged-in").value == '') disablePayment("You need to be <a href='/admin'>logged in</a> to order the glasses");