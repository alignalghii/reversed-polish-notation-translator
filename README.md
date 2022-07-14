# Using patterns from functional programming for refactoring traditional codebases

The task is to write a simple program, which converts basic arithmetic formulas (familiar infix notation) into the reversed Polish notation (posfix notation).

For simplicity's sake, the numbers can be simple integers between 0 and 9 (i.e. 1-digit numbers).

Examples for this translation specification can be found in the [`main-test.mjs`](nodejs/main-test.mjs) file:

```javascript
rawTextToPostfixNotation(''       ) == ''     ,
rawTextToPostfixNotation('1'      ) == '1'    ,
rawTextToPostfixNotation('12'     ) == '12'   ,
rawTextToPostfixNotation('1+2'    ) == '12+'  ,
rawTextToPostfixNotation('2*3+1'  ) == '23*1+',
rawTextToPostfixNotation('1+2*3'  ) == '123*+',
rawTextToPostfixNotation('1*(2+3)') == '123+*',
```

We can see from the last example, that the reverse Polish notation can evade the usage of parentheses.
This suggests that the solution is based on some kind of stack/FIFO structures. Indeed, for implementation, we will use an auxiliary stack.

First, let us see a general scheme of he solution: it can be found in the [`domain-logic/postfix-notation-translator.mjs`](nodejs/domain-logic/postfix-notation-translator.mjs) file:

```javascript
const expressionToPostfixNotation = inputExpression =>
        inputExpression.reduce(
            (context, currentSymbol) => {context.processCurrentSymbol(currentSymbol); return context;},
            new PostfixContext([], [])
        ).bendBack();
```

This translates an array of single-letter symbols (1-digit numbers and arithmetic operator signs) from the  familiar infix notation into the reversed Polish notation. See its test cases in [`test.mjs`](test.mjs):

```javascript
expressionToPostfixNotation([             ]).equals([             ]),
expressionToPostfixNotation(['1'          ]).equals(['1'          ]),
expressionToPostfixNotation(['1', '2'     ]).equals(['1', '2'     ]),
expressionToPostfixNotation(['1', '+', '2']).equals(['1', '2', '+']),
```

If almost the same, as the earlier mentioned final solution, i.e. the `rawTextToPostfixNotation` function: we simply we wrap a lexer around `expressionToPostfixNotation`, and we get exactly the final `rawTextToPostfixNotation`. Wrapping a lexer around is easy with higher-order function and currying:

```javascript
const wrapLexerAround =  // Def with currying
    expressionProcessor =>
        rawInputText => expressionProcessor(rawInputText.split('')).
            join('');

const expressionToPostfixNotation = inputExpression =>
        inputExpression.reduce(
            (context, currentSymbol) => {context.processCurrentSymbol(currentSymbol); return context;},
            new PostfixContext([], [])
        ).bendBack();

const rawTextToPostfixNotation = wrapLexerAround(expressionToPostfixNotation); // Currying used
```

as we can see in the definitions defined in the [`domain-logic/postfix-notation-translator.mjs`](nodejs/domain-logic/postfix-notation-translator.mjs) file.

## A purely functional, declarative shell around imperative details

Our solution till now can be seen like refactoring into an almost purely Haskell-spirited decarative paradigm. we could have written almost the same functions in Haskell with lists and the `foldr` catamorphism of the lists, the exact incarnation of array reduce:

**Implementation**:

```javasscript
const expressionToPostfixNotation = inputExpression =>
        inputExpression.reduce(
            (context, currentSymbol) => {context.processCurrentSymbol(currentSymbol); return context;},
            new PostfixContext([], [])
        ).bendBack();
```

**Behavior**:

```javascript
expressionToPostfixNotation([             ]).equals([             ]),
expressionToPostfixNotation(['1'          ]).equals(['1'          ]),
expressionToPostfixNotation(['1', '2'     ]).equals(['1', '2'     ]),
expressionToPostfixNotation(['1', '+', '2']).equals(['1', '2', '+']),
```

The details behind this simple foldr/reduce-style solution can be found in [`domain-logic/PostfixContext.mjs`](nodejs/domain-logic/PostfixContext.mjs):

```javascript
function PostfixContext(argumentsExpression, postfixStack)
{
    this.argumentsExpression = argumentsExpression;
    this.postfixStack        = postfixStack;
}

PostfixContext.arithmeticPrecedences = {'+': 1, '-': 1, '*': 2, '/': 2};

// The main, central instance method:

PostfixContext.prototype.processCurrentSymbol = function (currentSymbol)
{
    const precs = PostfixContext.arithmeticPrecedences;
    switch (true) {
        case /[0-9]/.test(currentSymbol): this.simpleArgument                 (currentSymbol); break;
        case currentSymbol in precs     : this.flushHigherPrecendenceOperators(currentSymbol); break;
        case currentSymbol == '('       : this.stackAsPostfixOperator         (currentSymbol); break;
        case currentSymbol == ')'       : this.flushParenthesizedOperators    (currentSymbol); break;
    }
};
```

The further details, i.e. the delegate case methods of the main method of this file can be  can be found below all these in the same file.

Some auxiliary datatypes are also used. they can be found in:

- [`algebraic-datatypes/ArrayExt.mjs`](nodejs/algebraic-datatypes/ArrayExt.mjs)
- [`algebraic-datatypes/MaybeExt.mjs`](nodejs/algebraic-datatypes/MaybeExt.mjs), which contains a Scala-inspired style implementation of the famous `Option` type (in Haskell: `Maybe`), the functional programming solution for evading the null-value problems (making partial functions total). The Scala-inspired implementation details (“*case objects*”) are contained in a subfolder of its own:
    - [`algebraic-datatypes/MaybeExt/Maybe.mjs`](nodejs/algebraic-datatypes/MaybeExt/Maybe.mjs), an abstract class
    - [`algebraic-datatypes/MaybeExt/Maybe_Just.mjs`](nodejs/algebraic-datatypes/MaybeExt/Maybe_Just.mjs), a child class concretization for the existing value case
    - [`algebraic-datatypes/MaybeExt/Maybe_Nothing.mjs`](nodejs/algebraic-datatypes/MaybeExt/Maybe_Nothing.mjs), a child class concretization for the missing value case

This is the standard solution of implementing an [algebraic datatype](https://en.wikipedia.org/wiki/Algebraic_data_type) in an imperative language, using OOP inheritance to simulate that. The trick's main idea was first used in Self and Smalltalkt to implement Bool, and later generalized in Scala for arbitrary algebraic datatypes: an arbitrary structure composed of algebraic direct products and direct sums (sort of records and tagged unions).
