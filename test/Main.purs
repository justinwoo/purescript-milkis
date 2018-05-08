module Test.Main where

import Prelude

import Control.Monad.Aff (attempt)
import Control.Monad.Eff (Eff)
import Data.Either (Either(..), isRight)
import Data.String (null)
import Milkis (URL(..), Fetch)
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Test.Spec (describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (RunnerEffects, run)
import Unsafe.Coerce (unsafeCoerce)

fetch :: Fetch
fetch = M.fetch nodeFetch

main :: Eff (RunnerEffects ()) Unit
main = run [consoleReporter] do
  describe "purescript-milkis" do
    it "get works and gets a body" do
      _response <- attempt $ fetch (URL "https://www.google.com") M.defaultFetchOptions
      case _response of
        Left e -> do
          fail $ "failed with " <> show e
        Right response -> do
          stuff <- M.text response
          let code = M.statusCode response
          code `shouldEqual` 200
          null stuff `shouldEqual` false
    it "post works" do
      let
        opts =
          { method: M.postMethod
          , body: "{}"
          , headers: M.makeHeaders { "Content-Type": "application/json" }
          }
      result <- attempt $ fetch (URL "https://www.google.com") opts
      isRight result `shouldEqual` true
    it "has correct headers" do
      let
        opts =
          { method: M.postMethod
          , body: "{}"
          , headers: M.makeHeaders {
              "Content-Type": "application/json"
            , "Something-Weird": "someValue"
            }
          }
      response_ <- attempt $ fetch (URL "https://httpbin.org/post") opts
      case response_ of
        Left e -> do
          fail $ "failed with " <> show e
        Right response -> do
          stuff <- M.json response
          (unsafeCoerce stuff).headers."Something-Weird" `shouldEqual` "someValue"
    it "put works" do
      let opts = { method: M.putMethod }
      result <- attempt $ fetch (URL "https://www.google.com") opts
      isRight result `shouldEqual` true
    it "delete works" do
      let opts = { method: M.deleteMethod }
      result <- attempt $ fetch (URL "https://www.google.com") opts
      isRight result `shouldEqual` true
