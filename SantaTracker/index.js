'use strict';

var fs = require('fs');
var request = require('sync-request');
var Realm = require('realm');

var REALM_ACCESS_TOKEN = "ac7e030b744909f5a63f0ed2843150c3";

// Dark Sky API key
var API_KEY = "2fc583a61b620f1b915adc60b42e0a9a";

var SERVER_URL = 'realm://127.0.0.1:9080';

var NOTIFIER_PATH = "santa-weather";

// Statuses from the mobile app
var kUploadingStatus = 0;
var kProcessingStatus = 1;
var kCompleteStatus = 2;

/*
 Utility Functions
 Various functions to check the integrity of data.
 */
function isString(x) {
  return x !== null && x !== undefined && x.constructor === String
}

function isNumber(x) {
  return x !== null && x !== undefined && x.constructor === Number
}

function isBoolean(x) {
  return x !== null && x !== undefined && x.constructor === Boolean
}

function isObject(x) {
  return x !== null && x !== undefined && x.constructor === Object
}

function isArray(x) {
  return x !== null && x !== undefined && x.constructor === Array
}

function isRealmObject(x) {
  return x !== null && x !== undefined && x.constructor === Realm.Object
}

function isRealmList(x) {
  return x !== null && x !== undefined && x.constructor === Realm.List
}

// Convert Dark Sky icon to correct integer
function weather_code(icon) {
  switch (icon) {
    case "clear-day":
    return 1;
    case "clear-night":
    return 2;
    case "rain":
    return 3;
    case "snow":
    return 4;
    case "sleet":
    return 5;
    case "wind":
    return 6;
    case "fog":
    return 7;
    case "cloudy":
    return 8;
    case "partly-cloudy-day":
    return 9;
    case "partly-cloudy-night":
    return 10;
    default:
    return 0;
  }
}

function process_weather_request(request) {
  realm.write(function() {
    // Let the client know we are working on the request
    // This will be synced back immediately
    request._loadingStatus = kProcessingStatus;
  });
  
  // Double check on the location, better safe than sorry
  var location = unprocessedWeatherRequest.location
  if (!isRealmObject(location)) {
    return;
  }
  
  // Create our request URL
  var requestURL = "https://api.darksky.net/forecast/" + API_KEY + "/" + location.latitude + "," + location.longitude + "?exclude=minutely,hourly,daily,flags,alerts&units=si"
  // I'm excluding all the bonus info because I'm not using it
  // Declaring the units means they won't vary based on location
  
  // Nice easy HTTP request
  var res = request('GET', requestURL);
  var body = JSON.parse(res.getBody('utf8'));
  var responseData = body.responses[0];
  var error = body.error;
  if (isObject(error)) {
    // If there was a problem, just fail
    return;
  }
  else {
    // Get the response data we care about
    var currentTemperature = responseData.currently.temperature;
    var currentCondition = weather_code(responseData.currently.icon);
    realm.write(function() {
      // Save the data!
      unprocessedWeatherRequest._loadingStatus = kCompleteStatus;
      unprocessedWeatherRequest._currentTemperature = currentTemperature;
      unprocessedWeatherRequest._currentCondition = currentCondition;
    });
  }
}

var change_notification_callback = function(change_event) {
  let realm = change_event.realm;
  
  // Get a list of all the new weather requests' indexes
  let changes = change_event.changes.Weather;
  let requestIndexes = changes.insertions;
  
  var requests = realm.objects("Weather");
  
  // Loop through every new weather request
  for (var i = 0; i < requestIndexes.length; i++) {
    let requestIndex = requestIndexes[i];
    let request = requests[requestIndex];
    // Double check that it's a Realm object and that it hasn't been handled yet
    if (!isRealmObject(request) || request._loadingStatus !== kUploadingStatus) {
      continue;
    }
    
    // Log the new request and send it off for processing
    console.log("New weather request received:" + change_event.path);
    process_weather_request(request);
  }
}

// Create the admin user
var admin_user = Realm.Sync.User.adminUser(REALM_ACCESS_TOKEN);

// Callback on Realm changes
Realm.Sync.addListener(SERVER_URL, admin_user, NOTIFIER_PATH, 'change', change_notification_callback);

console.log('Listening for Realm changes across: ' + NOTIFIER_PATH);
