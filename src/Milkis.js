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
    return response.json().catch(function(e) {
      throw new Error(e);
    });
  };
};

exports.textImpl = function(response) {
  return function() {
    return response.text();
  };
};

exports.headersImpl = function(response) {
    let d = {};
    for (h of response.headers) {
        d[h[0]] = h[1];
    };
    return d;
};

exports.arrayBufferImpl = function(response) {
  return function() {
    return response.arrayBuffer();
  };
};

exports.fromRecordImpl = function(r) {
  return r;
};
