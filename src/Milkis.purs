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

import Type.Row.Homogeneous

import Control.Promise (Promise, toAffE)
import Data.Newtype (class Newtype)
import Effect (Effect)
import Effect.Aff (Aff)
import Foreign (Foreign)
import Foreign.Object as Object
import Milkis.Impl (FetchImpl)
import Prelude (class Show, ($))
import Type.Row (class Union)
import Unsafe.Coerce (unsafeCoerce)

-- | Create a map from a homogeneous record (all attributes have the same type).
fromRecord :: forall r t. Homogeneous r t => Record r -> Object.Object t
fromRecord = fromRecordImpl

foreign import fromRecordImpl :: forall r t. Record r -> Object.Object t

newtype URL = URL String
derive instance newtypeURL :: Newtype URL _
derive newtype instance showURL :: Show URL

type Fetch
   = forall options trash
   . Union options trash Options
  => URL
  -> Record (method :: Method | options)
  -> Aff Response

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

type Headers = Object.Object String

makeHeaders
  :: forall r . Homogeneous r String
  => Record r
  -> Headers
makeHeaders = fromRecord

defaultFetchOptions :: {method :: Method}
defaultFetchOptions =
  { method: getMethod
  }

fetch :: FetchImpl -> Fetch
fetch impl url opts = toAffE $ _fetch impl url opts

json :: Response -> Aff Foreign
json res = toAffE (jsonImpl res)

text :: Response -> Aff String
text res = toAffE (textImpl res)

statusCode :: Response -> Int
statusCode response = response'.status
  where
    response' :: { status :: Int }
    response' = unsafeCoerce response

foreign import data Response :: Type

foreign import _fetch
  :: forall options
   . FetchImpl
  -> URL
  -> Record options
  -> Effect (Promise Response)

foreign import jsonImpl :: Response -> Effect (Promise Foreign)

foreign import textImpl :: Response -> Effect (Promise String)
