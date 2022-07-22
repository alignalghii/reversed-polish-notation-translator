module CommonAbstractSyntaxTree where

import Test.QuickCheck


data Digit = Dgt Int deriving (Read, Show, Eq)

instance Arbitrary Digit where
    arbitrary = Dgt <$> elements [0..9]

digit :: Int -> Digit
digit n = if 0 <= n && n < 10
    then Dgt n
    else error "Digit must be 0..9"

showsDigit :: Digit -> ShowS
showsDigit (Dgt d) = shows d

data SimpleArithmetic = Simple Digit
                      | Add       SimpleArithmetic SimpleArithmetic
                      | Substract SimpleArithmetic SimpleArithmetic
                      | Multiply  SimpleArithmetic SimpleArithmetic
                      | Divide    SimpleArithmetic SimpleArithmetic deriving (Read, Show, Eq)

instance Arbitrary SimpleArithmetic where
    arbitrary = sized genSizedArithmetic

genSizedArithmetic :: Int -> Gen SimpleArithmetic
genSizedArithmetic 0 = Simple <$> arbitrary
genSizedArithmetic n = oneof [ genSizedArithmetic 0,
                               Add <$> genSubsizedArithmetic n <*> genSubsizedArithmetic n,
                               Substract <$> genSubsizedArithmetic n <*> genSubsizedArithmetic n,
                               Multiply <$> genSubsizedArithmetic n <*> genSubsizedArithmetic n,
                               Divide <$> genSubsizedArithmetic n <*> genSubsizedArithmetic n
                             ]
genSubsizedArithmetic = genSizedArithmetic . (`div` 2)


-- Representation:

showAsInfix, showAsPostfix :: SimpleArithmetic -> String
showAsInfix   = flip showsAsInfix   ""
showAsPostfix = flip showsAsPostfix ""


showsAsInfix :: SimpleArithmetic -> ShowS
showsAsInfix (Simple d                                       ) = showsDigit d

showsAsInfix (Add       e1                 e2@(Add       _ _)) =        showsAsInfix e1  . (:) '+' . paren (showsAsInfix e2)
showsAsInfix (Add       e1                 e2@(Substract _ _)) =        showsAsInfix e1  . (:) '+' . paren (showsAsInfix e2)
showsAsInfix (Add       e1                 e2                ) =        showsAsInfix e1  . (:) '+' .        showsAsInfix e2

showsAsInfix (Substract e1                 e2@(Add       _ _)) =        showsAsInfix e1  . (:) '-' . paren (showsAsInfix e2)
showsAsInfix (Substract e1                 e2@(Substract _ _)) =        showsAsInfix e1  . (:) '-' . paren (showsAsInfix e2)
showsAsInfix (Substract e1                 e2                ) =        showsAsInfix e1  . (:) '-' .        showsAsInfix e2

showsAsInfix (Multiply  e1@(Add       _ _) e2@(Add       _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Add       _ _) e2@(Substract _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Add       _ _) e2@(Multiply  _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Add       _ _) e2@(Divide    _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Add       _ _) e2@(Simple      _)) = paren (showsAsInfix e1) . (:) '*' .        showsAsInfix e2
showsAsInfix (Multiply  e1@(Substract _ _) e2@(Add       _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Substract _ _) e2@(Substract _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Substract _ _) e2@(Multiply  _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Substract _ _) e2@(Divide    _ _)) = paren (showsAsInfix e1) . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1@(Substract _ _) e2@(Simple      _)) = paren (showsAsInfix e1) . (:) '*' .        showsAsInfix e2
showsAsInfix (Multiply  e1                 e2@(Add       _ _)) =        showsAsInfix e1  . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1                 e2@(Substract _ _)) =        showsAsInfix e1  . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1                 e2@(Multiply  _ _)) =        showsAsInfix e1  . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1                 e2@(Divide    _ _)) =        showsAsInfix e1  . (:) '*' . paren (showsAsInfix e2)
showsAsInfix (Multiply  e1                 e2                ) =        showsAsInfix e1  . (:) '*' .        showsAsInfix e2

showsAsInfix (Divide    e1@(Add       _ _) e2@(Add       _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Add       _ _) e2@(Substract _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Add       _ _) e2@(Multiply  _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Add       _ _) e2@(Divide    _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Add       _ _) e2@(Simple      _)) = paren (showsAsInfix e1) . (:) '/' .        showsAsInfix e2
showsAsInfix (Divide    e1@(Substract _ _) e2@(Add       _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Substract _ _) e2@(Substract _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Substract _ _) e2@(Multiply  _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Substract _ _) e2@(Divide    _ _)) = paren (showsAsInfix e1) . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1@(Substract _ _) e2@(Simple      _)) = paren (showsAsInfix e1) . (:) '/' .        showsAsInfix e2
showsAsInfix (Divide    e1                 e2@(Add       _ _)) =        showsAsInfix e1  . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1                 e2@(Substract _ _)) =        showsAsInfix e1  . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1                 e2@(Multiply  _ _)) =        showsAsInfix e1  . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1                 e2@(Divide    _ _)) =        showsAsInfix e1  . (:) '/' . paren (showsAsInfix e2)
showsAsInfix (Divide    e1                 e2                ) =        showsAsInfix e1  . (:) '/' .        showsAsInfix e2


showsAsPostfix :: SimpleArithmetic -> ShowS
showsAsPostfix (Simple d     ) = showsDigit d
showsAsPostfix (Add       a b) = showsAsPostfix a . showsAsPostfix b . (:) '+'
showsAsPostfix (Substract a b) = showsAsPostfix a . showsAsPostfix b . (:) '-'
showsAsPostfix (Multiply  a b) = showsAsPostfix a . showsAsPostfix b . (:) '*'
showsAsPostfix (Divide    a b) = showsAsPostfix a . showsAsPostfix b . (:) '/'

paren :: ShowS -> ShowS
paren e = (:) '(' . e . (:) ')'
