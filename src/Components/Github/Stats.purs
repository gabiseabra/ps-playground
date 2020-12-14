module Hey.Components.Github.Stats  where

import Prelude

import Data.Array (elem, fold, fromFoldable)
import Data.Bifunctor (rmap)
import Data.Foldable (class Foldable, foldl, foldr)
import Data.Map (Map)
import Data.Map as Map
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Nullable (notNull, null)
import Data.Tuple (snd)
import Data.Tuple.Nested (type (/\), (/\))
import Hey.Api.Github (User, Repo)
import Hey.Components.Chart (ChartData, ChartType(..), mkChart)
import Hey.Hooks.UseIntersectionObserver (useIntersectionObserverEntry)
import React.Basic.DOM as DOM
import React.Basic.Hooks (Component, component, useRef)
import React.Basic.Hooks as React

foreign import styles :: Styles

type Styles
  = { container :: String
    , stats :: String
    , languages :: String
    }

extension :: String -> String
extension lang
  | lang == "javascript" = ".js"
  | lang == "typescript" = ".ts"
  | lang == "purescript" = ".ps"
  | lang == "haskell" = ".hs"
  | lang == "ruby" = ".rb"
  | lang == "elixir" = ".ex"
  | otherwise = "." <> lang

collectData :: Array Repo -> Map String Int
collectData = foldr (_.primaryLanguage >>> _.name >>> Map.alter (maybe 1 ((+) 1) >>> Just)) mempty

uniq :: forall f a . Eq a => Foldable f => Monoid (f a) => Applicative f => f a -> f a
uniq = foldl (\as a ->
    if a `elem` as
    then as
    else pure a <> as 
  ) mempty

languagesChart :: Array (String /\ Array Repo) -> ChartData
languagesChart = map (rmap collectData) >>> \x ->
    let labels = (map (snd >>> Map.keys) >>> fold >>> fromFoldable >>> uniq) x
        datasets = x # map \(label /\ data') ->
          { label: notNull label
          , "data": labels # map ((flip Map.lookup) data' >>> fromMaybe 0)
          }
    in { labels: map extension labels, datasets: datasets }

mkStats :: Component User
mkStats = do
  chart <- mkChart
  component "Repo"
    $ \user -> React.do
        let data' = [ "my repositories" /\ user.repositories.nodes
                    , "open source contributions" /\ user.contributions.nodes
                    ]
        ref <- useRef null
        entry <- useIntersectionObserverEntry ref
        pure
          $ DOM.div
              { ref
              , className: styles.container
              , children:
                  [ DOM.div
                      { className: styles.languages
                      , children:
                          [ chart { options: { "type": Radar, "data": languagesChart data'} }
                          ]
                      }
                  ]
              }
