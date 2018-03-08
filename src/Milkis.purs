module Milkis
  ( URL(..)
  , Response
  , Options
  , Method
  , Headers
  , HeaderProperties
  , defaultFetchOptions
  , getMethod
  , postMethod
  , headMethod
  , fetch
  , json
  , text
  , makeHeaders
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Promise (Promise, toAffE)
import Data.Foreign (Foreign)
import Data.Newtype (class Newtype)
import Unsafe.Coerce (unsafeCoerce)

newtype URL = URL String
derive instance newtypeURL :: Newtype URL _
derive newtype instance showURL :: Show URL

type Options =
  ( method :: Method
  , body :: String
  , headers :: Headers
  )

foreign import data Method :: Type

getMethod :: Method
getMethod = unsafeCoerce "GET"

postMethod :: Method
postMethod = unsafeCoerce "POST"

headMethod :: Method
headMethod = unsafeCoerce "HEAD"

foreign import data Headers :: Type

type HeaderProperties =
  ( "Content-Type" :: String
  )

makeHeaders
  :: forall props trash
   . Union props trash HeaderProperties
  => Record props
  -> Headers
makeHeaders = unsafeCoerce

defaultFetchOptions :: {method :: Method}
defaultFetchOptions =
  { method: getMethod
  }

fetch
  :: forall options trash eff
   . Union options trash Options
  => URL
  -> Record (method :: Method | options)
  -> Aff eff Response
fetch url opts = toAffE $ fetchImpl url opts

json :: forall eff
  .  Response
  -> Aff eff Foreign
json res = toAffE (jsonImpl res)

text :: forall eff. Response -> Aff eff String
text res = toAffE (textImpl res)

foreign import data Response :: Type

foreign import fetchImpl :: forall eff options.
  URL
  -> Record options
  -> Eff eff (Promise Response)

foreign import jsonImpl :: forall eff.
  Response
  -> Eff eff (Promise Foreign)

foreign import textImpl :: forall eff.
  Response
  -> Eff eff (Promise String)
