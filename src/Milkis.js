var fetch = require("node-fetch");

exports.fetchImpl = function (url) {
  return function (options) {
    return function () {
      return fetch(url, options)
        .catch(function (e) {
          // we have to wrap node-fetch's non-Error error :(
          throw new Error(e);
        });
    };
  };
}

exports.jsonImpl = function (response) {
  return function() {
    return response.json();
  };
}

exports.textImpl = function (response) {
  return function() {
    return response.text();
  };
}
