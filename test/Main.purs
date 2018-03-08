module Test.Main where

import Prelude

import Control.Monad.Aff (attempt)
import Control.Monad.Eff (Eff)
import Data.Either (Either(..), isRight)
import Data.String (null)
import Milkis (URL(..), defaultFetchOptions, fetch, makeHeaders, postMethod, text)
import Test.Spec (describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (RunnerEffects, run)

main :: Eff (RunnerEffects ()) Unit
main = run [consoleReporter] do
  describe "purescript-milkis" do
    it "get works and gets a body" do
      _response <- attempt $ fetch (URL "https://www.google.com") defaultFetchOptions
      case _response of
        Left e -> do
          fail $ "failed with " <> show e
        Right response -> do
          stuff <- text response
          null stuff `shouldEqual` false
    it "post works" do
      let
        opts =
          { method: postMethod
          , body: "{}"
          , headers: makeHeaders {"Content-Type": "application/json"}
          }
      result <- attempt $ fetch (URL "https://www.google.com") opts
      isRight result `shouldEqual` true
