export {Maybe_Nothing};
import {Maybe} from './Maybe.mjs';

function Maybe_Nothing() {Maybe.call(this);}

Maybe_Nothing.prototype = Object.create(Maybe.prototype);
Maybe_Nothing.prototype.constructor = Maybe_Nothing;

Maybe_Nothing.prototype.maybe_eval = function(nothingCase, justCase)
{
    return nothingCase();
};
