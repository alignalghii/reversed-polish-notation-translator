import './types/ArrayExt.mjs';
import {Maybe} from './types/algebraic-datatype/MaybeExt.mjs';

console.log([
    'Maybe fromBool tests:',
     Maybe.fromBool(true , () => 1).equals(Maybe.just(1)),
    !Maybe.fromBool(true , () => 1).equals(Maybe.just(2)),
    !Maybe.fromBool(true , () => 1).equals(Maybe.nothing()),
     Maybe.fromBool(false, () => 1).equals(Maybe.nothing()),
    !Maybe.fromBool(false, () => 1).equals(Maybe.just(1)),
    !Maybe.fromBool(false, () => 1).equals(Maybe.just(2)),
    'Maybe equality tests:',
     Maybe.nothing().equals(Maybe.nothing()),
    !Maybe.nothing().equals(Maybe.just(1)),
    !Maybe.just(1).equals(Maybe.nothing()),
     Maybe.just(1).equals(Maybe.just(1)),
    !Maybe.just(1).equals(Maybe.just(2)),
    'Array maybeGetLastItem tests:',
    [1, 2, 3].maybeGetLastItem().equals(Maybe.just(3)),
    [].maybeGetLastItem().equals(Maybe.nothing())
]);
