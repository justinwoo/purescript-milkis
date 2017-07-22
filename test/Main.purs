module Test.Main where

import Prelude

import Control.Monad.Aff (attempt)
import Control.Monad.Eff (Eff)
import Data.Either (isRight)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..))
import Data.String (null)
import Milkis (defaultFetchOptions, fetch, text)
import Node.HTTP (HTTP)
import Test.Spec (describe, it)
import Test.Spec.Assertions (shouldEqual)
import Test.Spec.Reporter.Console (consoleReporter)
import Test.Spec.Runner (RunnerEffects, run)

main :: Eff (RunnerEffects (http :: HTTP)) Unit
main = run [consoleReporter] do
  describe "purescript-milkis" do
    it "get works and gets a body" do
      response <- fetch "https://www.bing.com" defaultFetchOptions
      stuff <- text response
      null stuff `shouldEqual` false
    it "post works" do
      let opts = defaultFetchOptions
            { method = POST
            , body = Just "{}"
            }
      result <- attempt $ fetch "https://www.bing.com" opts
      isRight result `shouldEqual` true
