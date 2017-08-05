module Milkis
  ( URL
  , FetchOptions
  , defaultFetchOptions
  , fetch
  , json
  , text
  , Response
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Promise (Promise, toAff)
import Data.Foreign (Foreign)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(..), fromMaybe)
import Node.HTTP (HTTP)

type URL = String

type FetchOptions =
  { method :: Method
  , body :: Maybe String
  }

defaultFetchOptions :: FetchOptions
defaultFetchOptions =
  { method: GET
  , body: Nothing
  }

fetch :: forall eff
  .  String
  -> FetchOptions
  -> Aff (http :: HTTP | eff) Response
fetch url opts =
  (liftEff $ fetchImpl url (fetchOptionsToRawFetchOptions opts)) >>= toAff

json :: forall eff
  .  Response
  -> Aff (http :: HTTP | eff) Foreign
json res = liftEff (jsonImpl res) >>= toAff

text :: forall eff. Response -> Aff (http :: HTTP | eff) String
text res = liftEff (textImpl res) >>= toAff

fetchOptionsToRawFetchOptions :: FetchOptions -> RawFetchOptions
fetchOptionsToRawFetchOptions opts =
  { method: convertMethod opts.method
  , body: fromMaybe "" opts.body
  }
  where
    convertMethod = show

type RawFetchOptions =
  { method :: String
  , body :: String
  }

foreign import data Response :: Type

foreign import fetchImpl :: forall eff.
  URL
  -> RawFetchOptions
  -> Eff (http:: HTTP | eff) (Promise Response)

foreign import jsonImpl :: forall eff.
  Response
  -> Eff (http:: HTTP | eff) (Promise Foreign)

foreign import textImpl :: forall eff.
  Response
  -> Eff (http:: HTTP | eff) (Promise String)
