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
    googlePayClient = new google.payments.api.PaymentsClient({
        environment: "TEST"
    });

    googlePayClient.isReadyToPay(googlePayConfiguration).then(res => {
    }).catch(err => {
        console.error("isReadyToPay error: ", err);
        alert("There was an error");
    });
}

function createAndAddButton() {
    const googlePayButton = googlePayClient.createButton({
        onClick: onGooglePayButtonClicked,
    });
    document.getElementById('container').appendChild(googlePayButton);
}

function onGooglePayButtonClicked() {
    if (document.getElementById("address").value == "") {
        return;
    }
    const paymentDataRequest = {...googlePayConfiguration};
    paymentDataRequest.merchantInfo = {
        merchantId: "BCR2DN4TWWS7TNBP",
        merchantName: "Gemini Sight"
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
    try {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '/order');
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onload = _ => console.log('Ordering');
        xhr.onreadystatechange = function() {
            if (this.readyState === 4) {
                if (this.status === 200) alert(this.responseText);
                else changeScreen("notFound");
            }
        }
        xhr.send(JSON.stringify({paymentData: paymentData, address: document.getElementById("address").value}));
    } catch(err) {
        console.error("POST request error: ", err);
        alert("There was an error");
    }
}

function initAutocomplete() {
    const autocomplete = new google.maps.places.Autocomplete(
      document.getElementById('address'),
      { types: ['geocode'] }
    );

    autocomplete.addListener('place_changed', function () {
      const place = autocomplete.getPlace();
    });
  }