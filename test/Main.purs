module Test.Main where

import Prelude

import Control.Monad.Aff (attempt)
import Control.Monad.Eff (Eff)
import Data.Either (Either(..), isRight)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.String (null)
import Milkis (defaultFetchOptions, fetch, text)
import Node.HTTP (HTTP)
import Test.Spec (describe, it)
import Test.Spec.Assertions (fail, shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (RunnerEffects, run)

main :: Eff (RunnerEffects (http :: HTTP)) Unit
main = run [consoleReporter] do
  describe "purescript-milkis" do
    it "get works and gets a body" do
      _response <- attempt $ fetch "https://www.google.com" defaultFetchOptions
      case _response of
        Left e -> do
          fail $ "failed with " <> show e
        Right response -> do
          stuff <- text response
          null stuff `shouldEqual` false
    it "post works" do
      let opts = defaultFetchOptions
            { method = POST
            , body = Just "{}"
            }
      result <- attempt $ fetch "https://www.google.com" opts
      isRight result `shouldEqual` true
