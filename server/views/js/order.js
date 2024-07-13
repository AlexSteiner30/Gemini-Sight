const tokenizationSpecification = {
    type: "PAYMENT_GATEWAY",
    parameters: {
        gateway: "example",
        gatewayMerchantId: "gatewayMerchantId"
    }
};

const cardPaymentMethod = {
    type: 'CARD',
    tokenizationSpecification: tokenizationSpecification,
    parameters: {
        allowedCardNetworks: ['VISA', 'MASTERCARD'],
        allowedAuthMethods: ['PAN_ONLY', 'CRYPTOGRAM_3DS']
    }
};

const googlePayConfiguration = {
    apiVersion: 2,
    apiVersionMinor: 0,
    allowedPaymentMethods: [cardPaymentMethod]
};
let googlePayClient;

function onGooglePayLoaded() {
    if (document.getElementById("logged-in").value == '') {
        disablePayment("You need to be <a href='/admin'>logged in</a> to order the glasses");
    }
    else {
        googlePayClient = new google.payments.api.PaymentsClient({
            environment: "TEST"
        });

        googlePayClient.isReadyToPay(googlePayConfiguration).then(res => {
            if (res.result) {
                createAndAddButton();
            }
            else {
                disablePayment("Unable to enable payment");
            }
        }).catch(err => {
            console.error("isReadyToPay error: ", err);
            alert("There was an error");
        });
    }
}


function createAndAddButton() {
    const googlePayButton = googlePayClient.createButton({
        onClick: onGooglePayButtonClicked,
    });
    document.getElementById('container').appendChild(googlePayButton);
}

function onGooglePayButtonClicked() {
    if (document.getElementById("address").value == "") {
        alert("Make sure to type in your address before continuing to the payment")
        return;
    }
    const paymentDataRequest = {...googlePayConfiguration};
    paymentDataRequest.merchantInfo = {
        merchantId: "BCR2DN4TWWS7TNBP",
        merchantName: "Gemin-Eye"
    };
    paymentDataRequest.transactionInfo = {
        totalPriceStatus: "FINAL",
        totalPrice: "200.00",
        currencyCode: 'EUR',
        countryCode: 'IT'
    };
    googlePayClient.loadPaymentData(paymentDataRequest).then(paymentData => processPaymentData(paymentData)).catch(err => {
        if (err.statusCode != 'CANCELED') {
            console.error("loadPaymentData error: ", err);
            alert("There was an error");
        }
    });
}

function processPaymentData(paymentData) {
    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/order');
    xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onload = function() {
        console.log('Ordering');
    };
    xhr.onreadystatechange = function() {
        if (this.readyState === 4) {
            if (this.status === 200) {
                disablePayment("Successfully Ordered");
            }
        }
    }
    xhr.send(JSON.stringify({paymentData: paymentData, address: document.getElementById("address").value}));
}