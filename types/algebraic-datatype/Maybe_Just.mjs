export {Maybe_Just};
import {Maybe} from './Maybe.mjs';

function Maybe_Just(value)
{
    Maybe.call(this);
    this.value = value;
};

Maybe_Just.prototype = Object.create(Maybe.prototype);
Maybe_Just.prototype.constructor = Maybe_Just;

Maybe_Just.prototype.maybe_eval = function (nothingCase, justCase)
{
    return justCase(this.value);
};
