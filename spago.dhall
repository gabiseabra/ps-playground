{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "affjax"
  , "argonaut"
  , "console"
  , "datetime"
  , "debug"
  , "effect"
  , "formatters"
  , "psci-support"
  , "react-basic"
  , "react-basic-dom"
  , "react-basic-hooks"
  , "record-extra"
  , "routing"
  , "unordered-collections"
  , "web-dom"
  , "web-html"
  , "web-intersection-observer"
  , "wire"
  , "wire-react"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
