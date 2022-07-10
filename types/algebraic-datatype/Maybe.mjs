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

Maybe.prototype.maybe_strict = function (nothingCase, justCase)
{
    return this.maybe_eval(() => nothingCase, justCase);
};

Maybe.prototype.mBind = function (mf)
{
    return this.maybe_eval(
        () => Maybe.nothing(),
        mf
   );
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
