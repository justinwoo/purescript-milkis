export function _fetch(fetchImpl) {
  return function (url) {
    return function (options) {
      return function () {
        return fetchImpl(url, options).catch(function (e) {
          // we have to wrap node-fetch's non-Error error :(
          throw new Error(e);
        });
      };
    };
  };
}

export function jsonImpl(response) {
  return function () {
    return response.json().catch(function (e) {
      throw new Error(e);
    });
  };
}

export function textImpl(response) {
  return function () {
    return response.text();
  };
}

export function headersImpl(response) {
  let d = {};
  for (let h of response.headers) {
    d[h[0]] = h[1];
  }
  return d;
}

export function arrayBufferImpl(response) {
  return function () {
    return response.arrayBuffer();
  };
}

export function fromRecordImpl(r) {
  return r;
}
