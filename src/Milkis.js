exports._fetch = function(fetchImpl) {
  return function(url) {
    return function(options) {
      return function() {
        return fetchImpl(url, options).catch(function(e) {
          // we have to wrap node-fetch's non-Error error :(
          throw new Error(e);
        });
      };
    };
  };
};

exports.jsonImpl = function(response) {
  return function() {
    return response.json();
  };
};

exports.textImpl = function(response) {
  return function() {
    return response.text();
  };
};
