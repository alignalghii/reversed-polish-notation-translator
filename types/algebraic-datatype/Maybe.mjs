export {Maybe};

function Maybe() {}

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
