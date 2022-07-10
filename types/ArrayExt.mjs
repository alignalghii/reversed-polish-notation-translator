import {Maybe} from './algebraic-datatype/MaybeExt.mjs';

Reflect.defineProperty(
	Array.prototype,
	'maybeGetLastItem',
	{
		value:
		function ()
		{
			return Maybe.fromBool(this.length > 0, () => this[this.length - 1]);
		}
	}
);

Reflect.defineProperty(
	Array.prototype,
	'moveItemsToWhile',
	{
		value:
		function (targetArray, condition)
		{
		    while (this.maybeGetLastItem().maybe_strict(false, condition))
		        targetArray.push(this.pop());
		}
	}
);

// For testing purposes:

Reflect.defineProperty(
	Array.prototype,
	'equals',
	{
		value:
		function (otherArray)
		{
		    let flag = this.length == otherArray.length;
		    for (let i = 0; flag && i < this.length; i++)
		        flag = flag && this[i] == otherArray[i];
		    return flag;
		}
	}
);

Reflect.defineProperty(
	Array.prototype,
	'globalConjunction',
	{
		value:
		function ()
		{
		    return this.every(flag => flag);
		}
	}
);
