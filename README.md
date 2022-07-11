# Using patterns from functional programming for refactoring traditional codebases

The task is to write a simple program, which converts basic arithmetic formulas (familiar infix notation) into the reversed Polish notation (posfix notation).

For simplicity's sake, the numbers can be simple integers between 0 and 9 (i.e. 1-digit numbers).

Examples for this translation specification can be found in the [`test.mjs`](test.mjs) file:

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

First, let us see a general scheme of he solution: it can be found in the [`domain-logic/postfix-notation-translator.mjs`](domain-logic/postfix-notation-translator.mjs) file:

```javascript
const expressionToPostfixNotation = inputExpression =>
        inputExpression.reduce(
            (context, currentSymbol) => {context.processCurrentSymbol(currentSymbol); return context;},
            new PostfixContext([], [])
        ).bendBack();
```