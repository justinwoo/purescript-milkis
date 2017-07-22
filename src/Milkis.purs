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
fetch url opts = toAff $ fetchImpl url (fetchOptionsToRawFetchOptions opts)

json :: forall eff
  .  Response
  -> Aff (exception :: EXCEPTION | eff) Foreign
json res = toAff $ jsonImpl res

text :: forall eff. Response -> Aff eff String
text res = toAff $ textImpl res

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

foreign import fetchImpl ::
  URL
  -> RawFetchOptions
  -> Promise Response

foreign import jsonImpl ::
  Response
  -> Promise Foreign

foreign import textImpl ::
  Response
  -> Promise String
