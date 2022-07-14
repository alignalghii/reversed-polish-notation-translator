module PostfixContext where

import Control.Arrow (first, second)
import Data.Char (isDigit)

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
initialPostfixContext = ([], [])

simpleArgument, stackAsPostfixOperator :: Char -> PostfixContext -> PostfixContext
simpleArgument                  = first  . (:)
stackAsPostfixOperator          = second . (:)

flushParenthesizedOperators :: PostfixContext -> PostfixContext
flushParenthesizedOperators =  second tail . moveItemsWhile (/= '(')

flushHigherPrecedenceOperators :: Char -> Int -> PostfixContext -> PostfixContext
flushHigherPrecedenceOperators currentSymbol currSmbPrec = second (currentSymbol :) . moveItemsWhile (isOfHigherPrecedenceThan currSmbPrec)

moveItemsWhile :: (Char -> Bool) -> PostfixContext -> PostfixContext
moveItemsWhile _    ct@(argumentsExpression, []                ) = ct
moveItemsWhile prop ct@(argumentsExpression, op : postfixStack')
    | prop op   = moveItemsWhile prop (op : argumentsExpression, postfixStack')
    | otherwise = ct

isOfHigherPrecedenceThan :: Int -> Char -> Bool
isOfHigherPrecedenceThan currentSymbolPrecedence = maybe False (>= currentSymbolPrecedence) . flip lookup precedences

bendBack :: PostfixContext -> String
bendBack (argumentsExpression, postfixStack) = reverse argumentsExpression ++  reverse postfixStack
