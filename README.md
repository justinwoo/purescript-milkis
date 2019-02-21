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

## Guide

### `FetchImpl`

To use this library, you'll have to use a value of `FetchImpl`, which is a foreign data type. This library provides two bindings via the modules `Milkis.Impl.Window` and `Milkis.Impl.Node`. You may choose to bring your own, typing a foreign import as `FetchImpl`.

You can partially apply the function `Milkis.fetch` to get a value of `Fetch`. For example, with Node you could do this:

```hs
import Milkis as M
import Milkis.Impl.Node (nodeFetch)

fetch :: M.Fetch
fetch = M.fetch nodeFetch
```

### `Fetch`

`Fetch` is simply a type alias:

```hs
type Fetch
   = forall options trash
   . Union options trash Options
  => URL
  -> Record (method :: Method | options)
  -> Aff Response
```

What this signature says is given some type varaibles `options` and `trash` where there is a `Union` of `options` and `trash` together to form `Options`, we have a function that takes `URL` and a record with a `method :: Method` field and the fields specified in `options` to return an `Aff Response`. Let's look at the definition of `Options`:

```hs
type Options =
  ( method :: Method
  , body :: String
  , headers :: Headers
  , credentials :: Credentials
  )
```

So what the `Union` constraint does here is declare that `options` must have some subset of this row type, and that there exists some `trash` row type that is the complement. *For more reading about `Union`, you might want to read a post about it here: <https://github.com/justinwoo/my-blog-posts#unions-for-partial-properties-in-purescript>*

### How using `Fetch` works

Let's see an example of this at work:

```hs
main = do
  _response <- Aff.attempt $ fetch (M.URL "https://www.google.com") M.defaultFetchOptions
  case _response of
    Left e -> do
      fail $ "failed with " <> show e
    Right response -> do
      stuff <- M.text response
      let code = M.statusCode response
      code `shouldEqual` 200
      String.null stuff `shouldEqual` false
```

Let's also peek at the definition of `defaultFetchOptions`:

```hs
defaultFetchOptions :: { method :: Method }
defaultFetchOptions =
  { method: getMethod
  }
```

So in this case, we chose to only supply `method :: Method` and it worked. Let's see how this works with a POST request:

```hs
main = do
  let
    opts =
      { method: M.postMethod
      , body: "{}"
      , headers: M.makeHeaders { "Content-Type": "application/json" }
      }
  result <- attempt $ fetch (M.URL "https://www.google.com") opts
  isRight result `shouldEqual` true
```

This time, we provided a body for the post method along with some headers. If we look at the type of `makeHeaders`, we can get a better idea of what is happening:

```hs
makeHeaders
  :: forall r . Homogeneous r String
  => Record r
  -> Headers
```

Here, `makeHeaders` allows us to create headers from a homogeneous record of `String` types using the `Homogeneous` class from [Typelevel Prelude](https://pursuit.purescript.org/packages/purescript-typelevel-prelude).

By using these constraints, we are able to use `Fetch` in quite flexible ways that don't require having a large set of default options to be overridden. If you understand the content of this page, you'll be able to tackle any problems you run into with this library and understand how to use `Union`-based approaches in general.

For the browser usage, you should really only need to do `fetch = M.fetch windowFetch` and be on your way, so please look through the [tests](https://github.com/justinwoo/purescript-milkis/blob/master/test/Main.purs) for examples of how to use this library.
