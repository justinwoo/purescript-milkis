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
import Control.Promise (Promise, toAffE)
import Data.Foreign (Foreign)
import Data.HTTP.Method (Method(..))
import Data.Maybe (Maybe(Nothing))
import Data.Nullable (Nullable, toNullable)
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
fetch url opts = toAffE $ fetchImpl url (fetchOptionsToRawFetchOptions opts)

json :: forall eff
  .  Response
  -> Aff eff Foreign
json res = toAffE (jsonImpl res)

text :: forall eff. Response -> Aff eff String
text res = toAffE (textImpl res)

fetchOptionsToRawFetchOptions :: FetchOptions -> RawFetchOptions
fetchOptionsToRawFetchOptions opts =
  { method: convertMethod opts.method
  , body: toNullable opts.body
  }
  where
    convertMethod = show

type RawFetchOptions =
  { method :: String
  , body :: Nullable String
  }

foreign import data Response :: Type

foreign import fetchImpl :: forall eff.
  URL
  -> RawFetchOptions
  -> Eff (http:: HTTP | eff) (Promise Response)

foreign import jsonImpl :: forall eff.
  Response
  -> Eff eff (Promise Foreign)

foreign import textImpl :: forall eff.
  Response
  -> Eff eff (Promise String)
