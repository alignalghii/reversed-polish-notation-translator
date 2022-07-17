module Translator where

import PostfixContext hiding (spec)
-- For testing:
import CommonAbstractSyntaxTree
import Test.Hspec
import Test.QuickCheck

translate :: String -> String
translate = bendBack . foldl (flip processCurrentSymbol) initialPostfixContext

translateSpec :: Spec
translateSpec = describe "The main function of the task: translate" $ do
    it "keeps a digit symbol like simpleArgument" $ do
        translate ""        `shouldBe` ""
        translate "1"       `shouldBe` "1"
        translate "12"      `shouldBe` "12"
        translate "123"     `shouldBe` "123"
    it "processes a simple infix construct like postfix" $ do
        translate "1+2"     `shouldBe` "12+"
        translate "2*3"     `shouldBe` "23*"
    it "handles precedences and parantheses well" $ do
        translate "2*3+1"   `shouldBe` "23*1+"
        translate "1+2*3"   `shouldBe` "123*+"
        translate "1*(2+3)" `shouldBe` "123+*"

prop_translate :: SimpleArithmetic -> Bool
prop_translate abstractSyntaxTree = translate (showAsInfix abstractSyntaxTree) == showAsPostfix abstractSyntaxTree
