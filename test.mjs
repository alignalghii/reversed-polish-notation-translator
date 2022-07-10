import './types/ArrayExt.mjs';
import {Maybe} from './types/algebraic-datatype/MaybeExt.mjs';
import {PostfixContext} from './domain-logic/PostfixContext.mjs';
import {rawTextToPostfixNotation, expressionToPostfixNotation} from './domain-logic/postfix-notation-translator.mjs';

const testCases = [
    // 'Final integration tests:',
    // ==========================
    expressionToPostfixNotation([             ]).equals([             ]),
    expressionToPostfixNotation(['1'          ]).equals(['1'          ]),
    expressionToPostfixNotation(['1', '2'     ]).equals(['1', '2'     ]),
    expressionToPostfixNotation(['1', '+', '2']).equals(['1', '2', '+']),

    // Final integration test, but without the lexer (directly on the parsed symbol array)

    rawTextToPostfixNotation(''       ) == ''     ,
    rawTextToPostfixNotation('1'      ) == '1'    ,
    rawTextToPostfixNotation('12'     ) == '12'   ,
    rawTextToPostfixNotation('1+2'    ) == '12+'  ,
    rawTextToPostfixNotation('2*3+1'  ) == '23*1+',
    rawTextToPostfixNotation('1+2*3'  ) == '123*+',
    rawTextToPostfixNotation('1*(2+3)') == '123+*',

    // Semi-integration test: testing the PostfixContext class, the workhorse of the whole domain logic:
    // -------------------------------------------------------------------------------------------------

    // 'PostfixContext main method test:',
    contextChangeTest([  ], [             ], 'processCurrentSymbol', '4', ['4'     ], [   ]),
    contextChangeTest([  ], ['*', '/'     ], 'processCurrentSymbol', '+', ['/', '*'], ['+']),
    contextChangeTest([  ], [             ], 'processCurrentSymbol', '(', [        ], ['(']),
    contextChangeTest([  ], ['(', '*', '/'], 'processCurrentSymbol', ')', ['/', '*'], [   ]),
    // 'Constituent (case) methods of the PostfixContext main method (testing cases separately):',
    contextChangeTest([  ], [             ], 'simpleArgument'                 , '4', ['4'     ], [   ]),
    contextChangeTest([  ], ['*', '/'     ], 'flushHigherPrecendenceOperators', '+', ['/', '*'], ['+']),
    contextChangeTest([  ], [             ], 'stackAsPostfixOperator'         , '(', [        ], ['(']),
    contextChangeTest([  ], ['(', '*', '/'], 'flushParenthesizedOperators'    , ')', ['/', '*'], [   ]),

    // Unit testing for the auxiliary modules (algebraic datatypes, other type extensions):
    // ===================================================================================

    // 'Maybe fromBool tests:',
     Maybe.fromBool(true , () => 1).equals(Maybe.just(1)),
    !Maybe.fromBool(true , () => 1).equals(Maybe.just(2)),
    !Maybe.fromBool(true , () => 1).equals(Maybe.nothing()),
     Maybe.fromBool(false, () => 1).equals(Maybe.nothing()),
    !Maybe.fromBool(false, () => 1).equals(Maybe.just(1)),
    !Maybe.fromBool(false, () => 1).equals(Maybe.just(2)),
    // 'Maybe equality tests:',
     Maybe.nothing().equals(Maybe.nothing()),
    !Maybe.nothing().equals(Maybe.just(1)),
    !Maybe.just(1).equals(Maybe.nothing()),
     Maybe.just(1).equals(Maybe.just(1)),
    !Maybe.just(1).equals(Maybe.just(2)),
     Maybe.nothing().fromMaybe(12) == 12,
     Maybe.just (15).fromMaybe(12) == 15,

    // 'Array maybeGetLastItem tests:',
    [1, 2, 3].maybeGetLastItem().equals(Maybe.just(3)),
    [].maybeGetLastItem().equals(Maybe.nothing()),
    // 'Array moveItemsToWhile',
    arrayItemsMoveTest([10, 20, 30], [], item => item > 30, [10, 20, 30], []          ),
    arrayItemsMoveTest([10, 20, 30], [], item => item > 20, [10, 20]    , [30]        ),
    arrayItemsMoveTest([10, 20, 30], [], item => item > 10, [10]        , [30, 20]    ),
    arrayItemsMoveTest([10, 20, 30], [], item => item >  0, []          , [30, 20, 10])
];

console.log('Running test cases:');
console.log(testCases);
console.log(`Result in summary: ${testCases.globalConjunction()}`);
// See `.globalConjunction` in `types/ArrayExt.mjs`: defined as `.every(flag => flag)`

function contextChangeTest(argumentsExpression_input, postfixStack_input,
                           methodName, symbol,
                           argumentsExpression_expectation, postfixStack_expectation)
{
    const context_input       = new PostfixContext(argumentsExpression_input      , postfixStack_input      );
    const context_expectation = new PostfixContext(argumentsExpression_expectation, postfixStack_expectation);
    context_input[methodName](symbol);
    return context_input.equals(context_expectation);
}

function arrayItemsMoveTest(srcArray_input, tgtArray_input, moveCondition, srcArray_expectation, tgtArray_expectation)
{
    srcArray_input.moveItemsToWhile(tgtArray_input, moveCondition);
    return srcArray_input.equals(srcArray_expectation) &&
           tgtArray_input.equals(tgtArray_expectation) ;
}
