# Purescript-Milkis

[![Build Status](https://travis-ci.org/justinwoo/purescript-milkis.svg?branch=master)](https://travis-ci.org/justinwoo/purescript-milkis)

A wrapper around [node-fetch](https://github.com/bitinn/node-fetch) for all your request needs.

Aptly named for the greatest soft drink of all time, [Milkis](https://en.wikipedia.org/wiki/Milkis).

![](https://upload.wikimedia.org/wikipedia/commons/f/f3/1006_milkis_lotte.jpg)

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
