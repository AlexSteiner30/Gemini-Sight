const crypto = require("crypto");

/**
 * Generate random uuidv4 
 *
 * @returns return uuidv4
 */
function uuidv4() {
    return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
      (+c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> +c / 4).toString(16)
    );
}

/**
 * Make a post request given the url and data to post
 * 
 * @param {String} url 
 * @param {String} data 
 * @returns 
 */
async function postData(url = "", data = {}) {
  try {
    const response = await fetch(url, {
      method: "POST",
      mode: "cors",
      cache: "no-cache",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
      },
      referrerPolicy: "no-referrer",
      body: JSON.stringify(data),
    });

    // Check if the response status is okay
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }

    // Parse JSON response
    const responseData = await response.json();
    return responseData;
  } catch (error) {
    console.error("Error fetching/posting data:", error.message);
    throw error; // Re-throw the error to propagate it further if needed
  }
}

module.exports = {
    uuidv4,
    postData
}