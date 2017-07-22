var fetch = require("node-fetch");

exports.fetchImpl = function (url) {
  return function (options) {
    return fetch(url, options);
  };
}

exports.jsonImpl = function (response) {
  return response.json();
}

exports.textImpl = function (response) {
  return response.text();
}
