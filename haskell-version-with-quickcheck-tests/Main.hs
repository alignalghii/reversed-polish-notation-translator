module Main where

import Translator (translateSpec, prop_translate)
-- For testing:
import Test.Hspec (hspec)
import Test.QuickCheck (quickCheck)

main :: IO ()
main = do
    putStrLn "========== Specification tests with `Hspec`: =========="
    hspec translateSpec
    putStrLn "========== Random generated property tests with `Quickcheck`: =========="
    quickCheck prop_translate
