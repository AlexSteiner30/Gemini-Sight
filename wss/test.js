const CCrypto = require('crypto-js');

// Function to encrypt data with AES
function encryptSHA256(data, secretKey) {
    const secretKeyWordArray = CCrypto.enc.Utf8.parse(secretKey);
    const iv = CCrypto.lib.WordArray.random(16); // Generate a random IV
    const encrypted = CCrypto.AES.encrypt(data, secretKeyWordArray, {
        mode: CCrypto.mode.CBC,
        padding: CCrypto.pad.Pkcs7,
        iv: iv,
    });

    // Combine IV and encrypted data into a single string (for easier decryption later)
    const combined = iv.concat(encrypted.ciphertext);

    return combined.toString(CCrypto.enc.Base64);
}

// Function to decrypt AES-encrypted data
function decryptSHA256(encryptedData, secretKey) {
    const combined = CCrypto.enc.Base64.parse(encryptedData);
    const iv = CCrypto.lib.WordArray.create(combined.words.slice(0, 4)); // Extract IV from combined data

    const ciphertext = CCrypto.lib.WordArray.create(combined.words.slice(4)); // Extract ciphertext

    const secretKeyWordArray = CCrypto.enc.Utf8.parse(secretKey);
    const decrypted = CCrypto.AES.decrypt({ ciphertext: ciphertext }, secretKeyWordArray, {
        mode: CCrypto.mode.CBC,
        padding: CCrypto.pad.Pkcs7,
        iv: iv,
    });

    return decrypted.toString(CCrypto.enc.Utf8);
}

// Example usage:
const secretKey = 'your_secret_key_here';
const dataToEncrypt = 'Hello, world!';

// Encrypting the data
const encryptedString = encryptSHA256(dataToEncrypt, secretKey);
console.log('Encrypted:', encryptedString);


console.log(encryptedString)
// Decrypting the encrypted string
const decryptedString = decryptSHA256(encryptedString, secretKey);
console.log('Decrypted:', decryptedString);
