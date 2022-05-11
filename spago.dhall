{ sources = [ "src/**/*.purs", "test/**/*.purs" ]
, name = "dom-simple"
, dependencies =
    [ "aff"
    , "aff-promise"
    , "arraybuffer-types"
    , "effect"
    , "either"
    , "foreign"
    , "foreign-object"
    , "newtype"
    , "prelude"
    , "spec"
    , "strings"
    , "typelevel-prelude"
    , "unsafe-coerce"
    ]
, packages = ./packages.dhall
}
