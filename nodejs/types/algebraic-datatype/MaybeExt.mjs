export {Maybe};

import {Maybe}         from './Maybe.mjs';
import {Maybe_Nothing} from './Maybe_Nothing.mjs';
import {Maybe_Just}    from './Maybe_Just.mjs';


// Factory methods (or constructor aliases):

Maybe.just    = value => new Maybe_Just(value);
Maybe.nothing = ()    => new Maybe_Nothing();

Maybe.fromBool = function (flag, evalValue) // lazy in `evalValue` argument
{
    return flag ? Maybe.just(evalValue()) : Maybe.nothing();
};


// Monad operators:

Maybe.prototype.map = function (f)
{
    return this.maybe_eval(
        () => Maybe.nothing(),
        value => Maybe.just(
            f(value)
        )
    );
};

Maybe.prototype.mBind = function (mf)
{
    return this.maybe_eval(
        () => Maybe.nothing(),
        mf
   );
};

Maybe.mReturn = Maybe.just;


// Derivable Maybe-functions, i.e. those defineable on top of the basic functions:

Maybe.prototype.maybe_strict = function (nothingCase, justCase)
{
    return this.maybe_eval(() => nothingCase, justCase);
};


Maybe.prototype.fromMaybe = function (dflt)
{
    return this.maybe_strict(dflt, value => value);
};


// For testing purposes:

Maybe.prototype.equals = function (otherMaybeValue)
{
    return this.maybe_eval(
        ()        => otherMaybeValue.maybe_eval(
                         ()         => true ,
                         otherValue => false
                     ),
        thisValue => otherMaybeValue.maybe_eval(
                         ()         => false,
                         otherValue => thisValue == otherValue
                     )
    );
};
