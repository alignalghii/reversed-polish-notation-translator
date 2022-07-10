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
	'moveItemsTowhile',
	{
		value:
		function (targetArray, condition)
		{
		    while (this.maybeGetLastItem().fromMaybe(false, condition))
		        targetArray.push(this.pop());
		}
	}
);
