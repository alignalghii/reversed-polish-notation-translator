export {PostfixContext};
import '../types/ArrayExt.mjs';

// Class-wide functions/constants:

function PostfixContext(argumentsExpression, postFixStack)
{
    this.argumentsExpression = argumentsExpression;
    this.postFixStack        = postFixStack;
}

PostfixContext.arithmeticPrecedences = {'+': 1, '-': 1, '*': 2, '/': 2};

// The main, central instance method:

PostfixContext.prototype.processCurrentSymbol = function (currentSymbol)
{
    const precs = PostfixContext.arithmeticPrecedences;
    switch (true) {
        case parseFloat(currentSymbol): this.simpleArgument                 (currentSymbol); break;
        case currentSymbol in precs   : this.flushHigherPrecendenceOperators(currentSymbol); break;
        case currentSymbol == '('     : this.stackAsPostfixOperator         (currentSymbol); break;
        case currentSymbol == ')'     : this.flushParenthesizedOperators    (currentSymbol); break;
    }
};

// .. and its constituent delegate methods:

PostfixContext.prototype.simpleArgument = function (currentSymbol)
{
    this.argumentsExpression.push(currentSymbol);
};


PostfixContext.prototype.stackAsPostfixOperator = function (currentSymbol)
{
    this.postfixStack.push(currentSymbol);
};


PostfixContext.prototype.flushHigherPrecendenceOperators = function (currentSymbol)
{
    const precs = PostfixContext.arithmeticPrecedences;
    this.moveItemsWhile(
        stackItem => stackItem in precs && precs[stackItem] >= precs[currentSymbol]
    );
    this.stackAsPostfixOperator(currentSymbol);
};

PostfixContext.prototype.flushParenthesizedOperators = function (currentSymbol)
{
            this.moveItemsWhile(
                stackItem => stackItem != '('
            );
            this.postfixStack.pop();
};

// Auxiliary methods:

PostfixContext.prototype.bendBack = function ()
{
    return this.argumentsExpression.concat(this.postFixStack.reverse());
};

PostfixContext.prototype.moveItemsWhile = function (condition)
{
    this.postFixStack.moveItemsToWhile(
        this.argumentsExpression,
        condition
    );
};
