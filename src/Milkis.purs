module Milkis
  ( URL(..)
  , Fetch
  , Response
  , Options
  , Method
  , Headers
  , Credentials
  , defaultFetchOptions
  , getMethod
  , postMethod
  , putMethod
  , deleteMethod
  , headMethod
  , omitCredentials
  , sameOriginCredentials
  , includeCredentials
  , fetch
  , json
  , text
  , makeHeaders
  , statusCode
  ) where

import Prelude (class Show, ($))

import Control.Monad.Aff (Aff)
import Control.Monad.Eff (Eff)
import Control.Promise (Promise, toAffE)
import Data.Foreign (Foreign)
import Data.StrMap as StrMap
import Data.Newtype (class Newtype)
import Milkis.Impl (FetchImpl)
import Type.Row.Homogeneous
import Unsafe.Coerce (unsafeCoerce)

-- | Create a map from a homogeneous record (all attributes have the same type).
fromRecord :: forall r t. Homogeneous r t => Record r -> StrMap.StrMap t
fromRecord = fromRecordImpl

foreign import fromRecordImpl :: forall r t. Record r -> StrMap.StrMap t

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
  , credentials :: Credentials
  )

-- | See <https://developer.mozilla.org/en-US/docs/Web/API/Request/credentials>.
foreign import data Credentials :: Type

omitCredentials :: Credentials
omitCredentials = unsafeCoerce "omit"

sameOriginCredentials :: Credentials
sameOriginCredentials = unsafeCoerce "same-origin"

includeCredentials :: Credentials
includeCredentials = unsafeCoerce "include"

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

type Headers = StrMap.StrMap String

makeHeaders
  :: forall r . Homogeneous r String
  => Record r
  -> Headers
makeHeaders = fromRecord

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
