module PostfixContext where

import Control.Arrow (first, second)
import Data.Char (isDigit)
import Test.Hspec

type PostfixContext = (String, String) -- argumentsExpression, postfixStack

precedences :: [(Char, Int)]
precedences = [('+', 1), ('-', 1), ('*', 2), ('/', 2)]

processCurrentSymbol :: Char -> PostfixContext -> PostfixContext
processCurrentSymbol currentSymbol context
    | isDigit currentSymbol               = simpleArgument              currentSymbol context
    | currentSymbol == '('                = stackAsPostfixOperator      currentSymbol context
    | currentSymbol == ')'                = flushParenthesizedOperators               context
    | otherwise                           = case currentSymbol `lookup` precedences of
                                                Just precVal -> flushHigherPrecedenceOperators currentSymbol precVal context
                                                Nothing      -> error $ "Invalid character " ++ [currentSymbol]

initialPostfixContext :: PostfixContext
initialPostfixContext = ("", "")

simpleArgument, stackAsPostfixOperator :: Char -> PostfixContext -> PostfixContext
simpleArgument                  = first  . (:)
stackAsPostfixOperator          = second . (:)

flushParenthesizedOperators :: PostfixContext -> PostfixContext
flushParenthesizedOperators =  second tail . moveItemsWhile (/= '(')

flushHigherPrecedenceOperators :: Char -> Int -> PostfixContext -> PostfixContext
flushHigherPrecedenceOperators currentSymbol currSmbPrec = stackAsPostfixOperator currentSymbol . moveItemsWhile (isOfHigherPrecedenceThan currSmbPrec)

moveItemsWhile :: (Char -> Bool) -> PostfixContext -> PostfixContext
moveItemsWhile _    ct@(argumentsExpression, []                ) = ct
moveItemsWhile prop ct@(argumentsExpression, op : postfixStack')
    | prop op   = moveItemsWhile prop (op : argumentsExpression, postfixStack')
    | otherwise = ct

isOfHigherPrecedenceThan :: Int -> Char -> Bool
isOfHigherPrecedenceThan currentSymbolPrecedence = maybe False (>= currentSymbolPrecedence) . flip lookup precedences

bendBack :: PostfixContext -> String
bendBack (argumentsExpression, postfixStack) = reverse argumentsExpression ++ postfixStack

spec :: Spec
spec = describe "PostfixContext" $ do
    describe "PostfixContext main function: processCurrentSymbol" $ do
        it "processes the current symbol like simpleArgument" $ do
            processCurrentSymbol '1' initialPostfixContext `shouldBe` ("1", "")
            processCurrentSymbol '2' ("10", "+-") `shouldBe` ("210", "+-")
        it "processes the current symbol like stackAsPostfixOperator" $ do
            processCurrentSymbol '+' initialPostfixContext `shouldBe` ("", "+")
            processCurrentSymbol '*' ("10", "+-") `shouldBe` ("10", "*+-")
        it "processes the current symbol like flushHigherPrecedenceOperators" $ do
            processCurrentSymbol '+' ("", "/*") `shouldBe` ("*/", "+")
        it "processes the current symbol like flushParenthesizedOperators" $ do
            processCurrentSymbol ')' ("", "/*(") `shouldBe` ("*/", "")
    describe "PostfixContext main function processCurrentSymbol has the following constituent case functions:" $ do
        describe "PostfixContext simpleArgument" $ do
            it "puts current symbol into the arg stack" $ do
                simpleArgument '1' initialPostfixContext `shouldBe` ("1", "")
                simpleArgument '2' ("10", "+-") `shouldBe` ("210", "+-")
        describe "PostfixContext stackAsPostfixOperator" $ do
            it "puts current symbol into the postfix op stack" $ do
                stackAsPostfixOperator '+' initialPostfixContext `shouldBe` ("", "+")
                stackAsPostfixOperator '*' ("10", "+-") `shouldBe` ("10", "*+-")
        describe "PostfixContext flushHigherPrecedenceOperators" $ do
            it "flushes the higher-precedence operators" $ do
                flushHigherPrecedenceOperators '+' 1 ("", "/*") `shouldBe` ("*/", "+")
        describe "PostfixContext flushParenthesizedOperators" $ do
            it "flushes parenthesized operators" $ do
                flushParenthesizedOperators ("", "/*(") `shouldBe` ("*/", "")
