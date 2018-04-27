module Milkis
  ( URL(..)
  , Fetch
  , Response
  , Options
  , Method
  , Headers
  , HeaderProperties
  , defaultFetchOptions
  , getMethod
  , postMethod
  , putMethod
  , deleteMethod
  , headMethod
  , fetch
  , json
  , text
  , makeHeaders
  , statusCode
  ) where

import Prelude

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Promise (Promise, toAffE)
import Data.Foreign (Foreign)
import Data.Newtype (class Newtype)
import Milkis.Impl (FetchImpl)
import Unsafe.Coerce (unsafeCoerce)

newtype URL = URL String
derive instance newtypeURL :: Newtype URL _
derive newtype instance showURL :: Show URL

type Fetch
   = forall options trash eff
   . Union options trash Options
  => URL
  -> Record (method :: Method | options)
  -> Aff eff Response

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

putMethod :: Method
putMethod = unsafeCoerce "PUT"

deleteMethod :: Method
deleteMethod = unsafeCoerce "DELETE"

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
  :: FetchImpl
  -> Fetch
fetch impl url opts = toAffE $ _fetch impl url opts

json :: forall eff
  .  Response
  -> Aff eff Foreign
json res = toAffE (jsonImpl res)

text :: forall eff. Response -> Aff eff String
text res = toAffE (textImpl res)

statusCode :: Response -> Int
statusCode response = response'.statusCode
  where
    response' :: { statusCode :: Int }
    response' = unsafeCoerce response

foreign import data Response :: Type

foreign import _fetch
  :: forall eff options
   . FetchImpl
  -> URL
  -> Record options
  -> Eff eff (Promise Response)

foreign import jsonImpl :: forall eff.
  Response
  -> Eff eff (Promise Foreign)

foreign import textImpl :: forall eff.
  Response
  -> Eff eff (Promise String)
