module Translator where

import PostfixContext

translate :: String -> String
translate = bendBack . foldr processCurrentSymbol initialPostfixContext
