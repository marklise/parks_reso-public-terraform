function handler(event) {
  var response = event.response;
  response.cookies = {
      "API_LOCATION": {
          "value": "https://p41gitzo3l.execute-api.ca-central-1.amazonaws.com",
          "attributes": "Expires=Wed, 05 Aug 2100 07:28:00 GMT"
      },
      "API_PATH": {
          "value": "/prod",
          "attributes": "Expires=Wed, 05 Aug 2021 07:28:00 GMT"
      },
      "API_PUBLIC_PATH": {
          "value": "/prod",
          "attributes": "Expires=Wed, 05 Aug 2100 07:28:00 GMT"
      }
  }
  
  return response;
}