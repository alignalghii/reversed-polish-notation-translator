export {Maybe};

import {Maybe}         from './Maybe.mjs';
import {Maybe_Nothing} from './Maybe_Nothing.mjs';
import {Maybe_Just}    from './Maybe_Just.mjs';

Maybe.just    = value => new Maybe_Just(value);
Maybe.nothing = ()    => new Maybe_Nothing();

Maybe.fromBool = function (flag, evalValue) // lazy in `evalValue` argument
{
    return flag ? Maybe.just(evalValue()) : Maybe.nothing();
};
