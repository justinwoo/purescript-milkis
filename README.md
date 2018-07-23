# Purescript-Milkis

[![Build Status](https://travis-ci.org/justinwoo/purescript-milkis.svg?branch=master)](https://travis-ci.org/justinwoo/purescript-milkis)

[![Documentation Status](https://readthedocs.org/projects/purescript-milkis/badge/?version=latest)](https://purescript-milkis.readthedocs.io/en/latest/?badge=latest)

A library for working with the [Fetch API](https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API) both in the Browser and on Node via [node-fetch](https://github.com/bitinn/node-fetch), for all your HTTP request needs.

Aptly named for the greatest soft drink of all time, [Milkis](https://en.wikipedia.org/wiki/Milkis).

![](https://i.imgur.com/StOQOAP.jpg)

Read the [guide](https://purescript-milkis.readthedocs.io) to learn how to use this library.

## Installation

`npm install --save node-fetch`

`bower install --save purescript-milkis`

## Usage

See the [tests](./test/Main.purs)

## Example Usage

I use Milkis in my [ytcasts](https://github.com/justinwoo/ytcasts/blob/89617f69ceb7f6ceb4193ad7922c20fe1664c294/src/Main.purs#L133) project in order to download HTML from a Youtube page:

```purs
downloadCasts ::
  forall e.
  DBConnection ->
  Url ->
  Aff
    (Program e)
    (Array CastStatus)
downloadCasts conn (Url url) = do
  res <- text =<< fetch url defaultFetchOptions
  case getCasts res of
    Right casts -> for casts $ downloadCast conn
    Left e -> do
      errorShow e
      pure []
```
