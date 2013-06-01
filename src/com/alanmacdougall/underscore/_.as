/**
 * underscore.as, by Alan MacDougall [http://www.github.com/amacdougall/]
 *
 * Ported from underscore.js, (c) 2011 Jeremy Ashkenas, DocumentCloud Inc.
 * See http://http://documentcloud.github.com/underscore/
 *
 * Like underscore.js, it is freely distributable under the MIT license.
 */
package com.alanmacdougall.underscore {
// imports
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.events.TimerEvent;


/**
 * An AS3 adaptation of underscore.js. Note that most collection methods accept
 * Array, Object, or XMLList collections, but will return only Arrays. Use
 * Underscore to further manipulate a data set from XML after getting an
 * XMLList via E4X. Consider using _.toArray on an XMLList if you need access
 * to a function that doesn't support XMLLists.
 * 
 * Default iterator format: function(value:*, index:*?, list:*? {}
*/
public var _:* = (function():Function {
	var breaker:Object = {};
	
	var _:* = function(obj:*):* {
		return new Wrapper(obj);
	};
	
	/* This hack is necessary to work around AS3's argument count
	 * enforcement and lack of Function.arity. We want the user to
	 * be able to use function(item), function(item, index), or
	 * function(item, index, context) as the whim strikes them,
	 * without having to declare function(...args) and figure out
	 * the indexes themselves, or provide default values for an
	 * argument they won't use often, like context.
	 * 
	 * So instead, we just try the most common case first and then
	 * try each subsequent case when we get ArgumentErrors. Trying
	 * one arg first means the fewest exceptions.
	*/
	var safeCall:Function = function(iterator:Function, context:Object, ...args):* {
		
		var answer:*;
		var additionalArgs:Array = [];
		while (args.length > 1) {
			additionalArgs.push(args.pop());
		}
		while (true) {
			try {
				answer = iterator.apply(context, args);
			} catch (e:ArgumentError) {
				if (additionalArgs.length == 0) {
					// if we've run out of additional args, give up
					throw e;
				}
				args.push(additionalArgs.pop());
				continue;
			}
			break;
		}
		return answer;
	}
	
	/* COLLECTIONS */
	/**
	 * Executes the iterator on each element of the input collection. Works on
	 * Array, Object, or XMLList collections.
	 * 
	 * @throws ArgumentError if obj is not a collection.
	 */
	var each:Function = _.each = function(obj:*, iterator:Function, context:Object = null):* {
		var i:int;
		
		if (obj is Array) {
			// TO DO: benchmark native Array.forEach
			for (i = 0; i < obj.length; i++) {
				if (safeCall(iterator, context, obj[i], i, obj) === breaker) return;
			}
		} else if (obj is Object) {
			for (var key:String in obj) {
				if (obj.hasOwnProperty(key)) {
					if (safeCall(iterator, context, obj[key], key, obj) === breaker) return;
				}
			}
		} else if (obj is XMLList) {
			for (i = 0; i < obj.length(); i++) {
				if (safeCall(iterator, context, obj[i], i, obj) == breaker) return;
			}
		} else {
			throw new Error("Attempted to iterate over incompatible object " +
				obj + "; must iterate over an Array, an Object, or an XMLList.");
		}
	};
	
	/** Returns the input items, transformed by the iterator, as an Array. */
	var map:Function = _.map = function(obj:*, iterator:Function, context:Object = null):Array {
		var results:Array = [];
		if (obj == null) return results;
		
		// TO DO: benchmark native Array.map
		each(obj, function(value:*, index:*, list:* = null):* {
			results.push(safeCall(iterator, context, value, index, list));
		});
		return results;
	};
	
	/**
	 * Returns the input items, filtered by the iterator, as an Array. Aliased
	 * as _.select.
	 */
	_.filter = _.select = function(obj:*, iterator:Function, context:Object = null):Array {
		var results:Array = [];
		if (obj == null) return results;
		each(obj, function(value:*, index:* = null, list:* = null):* {
			safeCall(iterator, context, value, index, list) && results.push(value);
		});
		return results;
	};
	
	/**
	 * Returns the input items, rejecting any which pass the truth test.
	 */
	_.reject = function(obj:*, iterator:Function, context:Object = null):Array {
		var results:Array = [];
		if (obj == null) return results;
		each(obj, function(value:*, index:* = null, list:* = null):* {
			safeCall(iterator, context, value, index, list) || results.push(value);
		});
		return results;
	};
	
	/**
	 * Executes the iterator on each collection element. The iterator has
	 * access to a memo variable which can be modified by each iteration in
	 * turn, to build a string or sum a mathematical series (for example). At
	 * the end of the iteration, the memo is returned. If no memo is supplied,
	 * the first value in the list is used as the memo. As in the original
	 * underscore.js implementation, if no memo is supplied, the iterator is
	 * not run on the first value of the list.
	 * 
	 * Simply returns the memo if run on an empty collection.
	 * 
	 * Iterator format: function(memo:*, value:*, index:*?, list:*?):* {}
	 */
	_.reduce = _.foldl = _.inject = function(obj:*, iterator:Function, memo:* = null, context:Object = null):* {
		if (_.isEmpty(obj)) return memo;
		
		var memoInitialized:Boolean = (memo != null);
		each(obj, function(value:*, index:*, list:*):* {
			if (!memoInitialized) {
				memo = value;
				memoInitialized = true;
			} else {
				memo = safeCall(iterator, context, memo, value, index, list);
			}
		});
		return memo;
	}
	
	// TO DO: implement _.reduceRight
	
	/**
	 * Returns the first collection element for which the iterator returns
	 * true. If no element qualifies, returns null. Assigning null to a typed
	 * variable whose type is not nullable, such as an int, will coarse the
	 * value to 0 instead of null, so watch out.
	 */
	_.detect = _.find = function(obj:*, iterator:*, context:Object = null):* {
		var result:* = null;
		any(obj, function(value:*, index:* = null, list:* = null):Boolean {
			if (safeCall(iterator, context, value, index, list)) {
				result = value;
				return true;
			}
			return false;
		});
		return result;
	};
	
	/**
	 * True if the iterator returns true for any collection element. If the
	 * iterator is omitted, tests the elements themselves for truthiness.
	 */
	var any:Function = _.any = _.some = function(obj:*, iterator:Function = null, context:Object = null):Boolean {
		if (obj == null || _(obj).isEmpty()) return false;
		// TO DO: benchmark native Array.some
		iterator = iterator || identity;
		var result:Boolean = false;
		each(obj, function(value:*, index:* = null, list:* = null):* {
			result = safeCall(iterator, context, value, index, list);
			if (result) return breaker;	// stop on first true value
		});
		return result;
	};
	
	/**
	 * True if the iterator returns true for all collection elements. If the
	 * iterator is omitted, tests the elements themselves for truthiness.
	 */
	_.all = function(obj:*, iterator:Function = null, context:Object = null):Boolean {
		if (obj == null) return false;
		// TO DO: benchmark native Array.every
		iterator = iterator || identity;
		var result:Boolean = true;
		each(obj, function(value:*, index:* = null, list:* = null):* {
			result = safeCall(iterator, context, value, index, list);
			if (!result) return breaker;	// stop on first false value
		});
		return result;
	}
	
	/**
	 * True if the target is present in the collection. Uses strict
	 * (threequals) equality. Named "include" in underscore.js, but since
	 * that's a special directive in AS3, it causes an error.
	 */
	_.includes = _.contains = function(obj:*, target:*):Boolean {
		if (obj is XMLList) throw new ArgumentError("_.includes cannot operate on an XMLList.");
		if (obj == null || _(obj).isEmpty()) return false;
		return any(obj, function(element:*):Boolean {
			return element === target;
		});
	}
	
	/**
	 * Invoke the named method on each collection element. If the method name
	 * is omitted, and the element is a function, invokes the element. Any
	 * additional arguments will be passed as parameters to each function call.
	 * To call a list of functions with params, _.invoke(list, null, arg1,
	 * ...).
	 * 
	 * @return An Array of the results of each invocation, or null if all
	 * functions were void or returned null.
	 */
	_.invoke = function(obj:*, functionName:String = null, ...args):Array {
		// TO DO: compact the result
		return map(obj, function(element:*):* {
			return (functionName ? element[functionName] : element).apply(element, args);
		});
	}
	
	/**
	 * Operates on a collection of Objects, returning an array of the values of
	 * the named property. Example:
	 * 
	 * var hashes:Array = [{name: "foo"}, {name: "bar"}];
	 * _(hashes).pluck("name"); // ["foo", "bar"]
	 * 
	 * @throws ArgumentError if called on an XMLList, since XML nodes have no
	 * single key. Could be @id, tag name, or who knows what. Use _.map!
	 */
	_.pluck = function(obj:*, key:String):Array {
		if (obj is XMLList) throw new ArgumentError("_.pluck cannot operate on an XMLList.");
		
		return map(obj, function(element:Object):* {
			return element[key];
		});
	}
	
	/**
	 * Returns the maximum value in the collection. If an iterator is passed,
	 * it must return a numeric value for each element. Otherwise the element
	 * itself will be compared using gt/lt operators, with undefined results if
	 * the values cannot be compared. Special cases: Arrays will be compared by
	 * length; Dates will be compared by their millisecond position in the Unix
	 * epoch, i.e. Date.getTime().
	 */
	_.max = function(obj:*, iterator:Function = null, context:Object = null):* {
		// unlike in underscore.js, "value" means numeric value, "element" is the real item
		var maxElement:* = null;
		var maxValue:Number = -Infinity;
		each (obj, function(element:*, index:*, list:*):void {
			var value:Number = iterator != null ?
				safeCall(iterator, context, element, index, list) :
				(element is Date ? element.getTime() : element);
			if (value >= maxValue) {
				maxValue = value;
				maxElement = element;
			}
		});
		return maxElement;
	};
	
	/**
	 * Returns the minimum value in the collection. If an iterator is passed,
	 * it must return a numeric value for each element. Otherwise the element
	 * itself will be compared using gt/lt operators, with undefined results if
	 * the values are non-numeric.
	 */
	_.min = function(obj:*, iterator:Function = null, context:Object = null):* {
		// unlike in underscore.js, "value" means numeric value, "element" is the real item
		var minElement:* = null;
		var minValue:Number = Infinity;
		each (obj, function(element:*, index:*, list:*):void {
			var value:Number = iterator != null ?
				safeCall(iterator, context, element, index, list) :
				(element is Date ? element.getTime() : element);
			if (value <= minValue) {
				minValue = value;
				minElement = element;
			}
		});
		return minElement;
	};
	
	/**
	 * Sort the objects values by running the iterator on each one. Iterator
	 * must return a numeric value.
	 */
	_.sortBy = function(obj:*, iterator:Function = null, context:Object = null):Array {
		// unlike in underscore.js, "value" means numeric value, "element" is the real item
		var results:Array = map(obj, function(element:*, index:*, list:*):Object {
			return {
				element: element,
				value: safeCall(iterator, context, element, index, list)
			};
		});
		
		// AS3's Array.sort mutates the array instead of returning a new sorted one.
		results.sort(function(left:Object, right:Object):int {
			if (left.value < right.value) {
				return -1;
			} else if (left.value == right.value) {
				return 0;
			} else {
				return 1;
			}
		});
		
		return _(results).pluck("element");
	};
	
	/**
	 * Operating on a sorted array, returns the index at which the supplied
	 * value should be inserted to main sort order. Optionally accepts an
	 * iterator which produces a numeric value for each element; otherwise,
	 * compares elements directly.
	 * 
	 * Iterator format: function(element:*):Number {}
	 */
	_.sortedIndex = function(list:Array, element:*, iterator:Function = null):int {
		iterator = iterator || identity;
		var low:int = 0;
		var high:int = list.length;
		while (low < high) {
			var mid:int = (low + high) >> 1; // i.e. Math.floor((low + high) / 2)
			iterator(list[mid]) < iterator(element) ?  low = mid + 1 : high = mid;
		}
		return low;
	};
	
	/**
	 * Transforms the collection into an Array, discarding keys if it was an
	 * Object. If collection is already an Array, returns a shallow copy. If
	 * collection was an XMLList, returns an array of nodes.
	 */
	_.toArray = function(collection:*):Array {
		if (collection == null) return [];
		if (collection is Array) return (collection as Array).slice();
		
		var result:Array = [];
		for each (var element:* in collection) {
			result.push(element);
		}
		return result;
	};
	
	/** Returns the number of elements in the collection. */
	_.size = function(obj:*):int {
		return _(obj).toArray().length;
	}
	
	/**
	 * True if the collection has no elements; false otherwise.
	 * 
	 * @throws ArgumentError if obj is not an Object or Array.
	 */
	_.isEmpty = function(obj:*):Boolean {
		if (obj is Array) {
			return obj.length == 0;
		} else if (obj is Object) {
			var n:int = 0;
			for (var key:String in obj) {n++;};
			return n == 0;
		} else {
			throw new ArgumentError("_.isEmpty was called with incompatible object " + obj +
				"; must be an Object or Array.");
		}
	};
	
	/* ARRAYS */
	/**
	 * Returns the first element of the list; or if the optional n argument
	 * is supplied, returns the first n elements of the list an an Array.
	 */
	_.first = _.head = function(list:Array, n:int = -1):Object {
		return n == -1 ? list[0] : list.slice(0, n);
	};
	
	_.rest = _.tail = function(list:Array, n:int = 1):* {
		return list.slice(n);
	};
	
	/**
	 * Returns the last element of the array. If the optional n argument
	 * is supplied, returns an array of the last n elements of the array.
	 */
	_.last = function(list:Array, n:int = -1):Object {
		if (n == -1) {
		  return list[list.length - 1];
		} else {
		  return list.slice(-n);
		}
	};

	/**
	 * Returns an array with all false, null, undefined, NaN, or empty-string
	 * values removed.
	 */
	_.compact = function(list:Array):Array {
		return _(list).select(function(element:*):Boolean {
			return !!element;	// seems to work in AS3 as well as Javascript
		});
	};
	
	/** Returns a flattened version of a nested array. */
	_.flatten = function(list:Array):Array {
		return _(list).reduce(function(accumulator:Array, element:*):Array {
			if (element is Array) {
				return accumulator.concat(_(element).flatten());
			}
			accumulator.push(element);
			return accumulator;
		}, []);
	};
	
	_.without = function(list:Array, ...targets):Array {
		return _(list).reject(function(element:*):Boolean {
			return _(targets).any(function(target:*):Boolean {
				return element === target;
			});
		});
	};
	
	_.unique = function(list:Array):Array {
		// use immediately executing function to isolate known array
		return (function(list:Array):Array {
			var known:Array = [];
			return _(list).select(function(element:*):Boolean {
				if (_(known).includes(element)) {
					return false;
				} else {
					known.push(element);
					return true;
				}
			});
		})(list);
	};

	/**
	 * Returns an array of all values which are present in all supplied arrays.
	 */
	_.intersection = function(list:Array, ...targets):Array {
		return _(list).select(function(element:*):Boolean {
			return _(targets).all(function(target:Array):Boolean {
				return _(target).includes(element);
			});
		});
	};

	/**
	 * Returns an array of all values which are present in all supplied arrays.
	 * An alias for _.intersection.
	 */
	_.intersect = _.intersection;


	/** Take the difference between one array and a number of other arrays. Only the elements present in just the first array will remain. */
	_.difference = function(list:Array, ...others):Array {
		return _(list).select(function(element:*):Boolean {
			return _(others).all(function(other:Array):Boolean {
				return !_(other).includes(element);
			});
		});
	};
	
	/** Zips multiple arrays together. Essentially rotates a nested array 90 degrees. */
	_.zip = function(...args):Array {
		var maxRowLength:int = _(args).chain().pluck("length").max().value();
		var results:Array = [];
		for (var rowIndex:int = 0; rowIndex < maxRowLength; rowIndex++) {
			var column:Array = [];
			for (var columnIndex:int = 0; columnIndex < args.length; columnIndex++) {
				column.push(args[columnIndex][rowIndex]);
			}
			results.push(column);
		}
		return results;
	}

	_.object = function(list:Array, values:Array = null):Object {
		if (list == null) return {};
		var result:Object = {};
		for (var i:int = 0, l:uint = list.length; i < l; i++) {
		  if (values) {
			result[list[i]] = values[i];
		  } else {
			result[list[i][0]] = list[i][1];
		  }
		}
		return result;
    },
	
	_.range = function(start:Number, stop:Number = NaN, step:Number = NaN):Array {
		if (isNaN(stop)) { // _.range(10) counts 0 to 9
			stop = start;
			start = 0;
		}
		
		step = step || 1;
		var length:int = Math.max(Math.ceil((stop - start) / step), 0);
		var index:int = 0;
		var range:Array = [];
		while (index < length) {
			range.push(start);
			start += step;
			index++;
		}
		return range;
	}
	
	/* FUNCTIONS */
	/**
	 * Binds the function to the supplied object, returning a "bound" function
	 * whose "this" is the supplied object. Optionally curries the function
	 * with the supplied arguments. If these terms are unfamiliar, look up the
	 * fundamentals of scope, binding, and closures in AS3 (or Javascript,
	 * since they work almost identically and JS resources may be more common).
	 * And prepare to be enlightened.
	 */
	_.bind = function(f:Function, obj:Object = null, ...curriedArgs):Function {
		// The ...rest construct will yield an empty array if no extra args are passed.
		return function(...invocationArgs):* {
			return f.apply(obj, curriedArgs.concat(invocationArgs));
		};
	};
	
	/**
	 * Binds functions to the supplied object. If no function names are given,
	 * binds all functions found on the object. Useful when the functions will
	 * be called in a foreign context, such as an event listener. Use this to
	 * simulate method binding when constructing objects at runtime.
	 */
	_.bindAll = function(obj:Object, ...functionNames):Object {
		_(functionNames).isEmpty() && (functionNames = _(obj).functions());
		_(functionNames).each(function(name:String):void {
			obj[name] = _(obj[name]).bind(obj);
		});
		return obj;
	};
	
	/**
	 * Memoizes a function by caching its results in a lookup table stored in
	 * the closure. For example, once f(x:int) is called as f(100), the result
	 * is cached before it is returned, and future calls as f(100) will simply
	 * return the cached result.
	 * 
	 * Uses a Dictionary internally instead of an Object, meaning that
	 * non-scalar arguments will be keyed by identity. If f(s:Sprite) is
	 * called as f(foo), future calls as f(foo) will return the cached result;
	 * but even if sprite "bar" is precisely identical to foo, f(bar) will
	 * force a new function call and cache a new value.
	 * 
	 * Optionally accepts a "hasher" function which produces a hash code for a
	 * given input value. For instance, if all input values 0-10, 11-20, etc
	 * are expected to produce the same output, hasher could be designed to
	 * produce a single key for each level of input:
	 * function(n:int):String {return (Math.floor(n / 10) * 10).toString();}.
	 *
	 * Defining a custom hasher function is the only way to memoize a function
	 * which takes more than one argument, or to memoize a function which
	 * might return the same result for non-identical arguments.
	 */
	_.memoize = function(f:Function, hasher:Function = null):Function {
		var memo:Dictionary = new Dictionary(); // lookup table mapping input to output values
		hasher = hasher || identity;
		return function(...args):* {
			var key:String = hasher.apply(this, args);
			return key in memo ? memo[key] : (memo[key] = f.apply(this, args));
		};
	};
	
	/**
	 * Executes the function after a delay. Optional args will be passed to the
	 * function at runtime.
	 *
	 * @return A Timer which can be stopped to prevent the delayed execution.
	 */
	/* Although AS3 has setTimeout and setInterval, the Adobe-approved timing
	 * method is Timer, so _.delay returns a Timer which can be stopped to
	 * prevent the delayed function.
	 */
	_.delay = function(f:Function, wait:int, ...args):Timer {
		var timer:Timer = new Timer(wait, 1);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(event:TimerEvent):void {
			f.apply(f, args);
		});
		timer.start();
		return timer;
	}
	
	/**
	 * Executes the function after the current call stack has completed. Good
	 * for functions which should not block execution, or to call a single
	 * event handler after many synchronous calls. Alternative strategy: create
	 * an event handler using _.debounce(f, 0).
	 * 
	 * @return A Timer which can be stopped to prevent the deferred execution.
	 */
	_.defer = function(f:Function, ...args):Timer {
		return _(f).delay(0);
	}

	/**
	 * Internal function, but debounce and throttle can be considered
	 * convenience methods for this.
	 */
	// choke implementation suggested by Nick Schaubeck
	var limit:Function = function(f:Function, wait:int,
		debounce:Boolean = false, callThrottledImmediately:Boolean = false):Function {

		var timer:Timer = new Timer(wait, 1);
		
		/*
			These variables are defined outside the returned function, but set
			within it. This lets us create the throttler and set up the timer
			events outside the returned function, which will be called many times.
		*/
		var context:Object;
		var args:Array;
		var throttler:Function = function():void {
			timer.stop();
			callThrottledImmediately || f.apply(context, args);
		};
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, throttler);
		
		return function(...runtimeArgs):* {
			args = runtimeArgs;
			context = this;
			callThrottledImmediately && !timer.running && f.apply(context, args);
			debounce && timer.stop();
			(debounce || !timer.running) && timer.start();
		};
	};
	
	/**
	 * Returns a wrapped function which can only execute once every so many
	 * milliseconds. As in underscore.js, even the first call is delayed by
	 * the wait duration; but if the optional callImmediately argument is
	 * true, the first call occurs immediately and subsequent calls are
	 * locked out for the wait duration.
	 */
	_.throttle = function(f:Function, wait:int, callImmediately:Boolean = false):Function {
		return limit(f, wait, false, callImmediately);
	};
	
	/**
	 * Returns a wrapped function which executes once, and then fails silently
	 * for the given cooldown period. Equivalent to calling _.throttle with the
	 * callImmediately argument = true.
	*/
	_.choke = function(f:Function, wait:int):Function {
		return limit(f, wait, false, true);
	}
	
	/**
	 * Returns a wrapped function which only executes the most recent call,
	 * after the given delay. Each call resets the delay. Good for performing
	 * an update after a sequence of rapid inputs, such as typing or dragging.
	 */
	_.debounce = function(f:Function, wait:int):Function {
		return limit(f, wait, true);
	};

	/**
	 * Returns a function which takes the initial function as an argument.
	 * Useful for automatically transforming or interpreting the result of the
	 * intial function, or logging when it is called, or something. Wrapper is
	 * welcome to pass its arguments along to the original function, or take
	 * completely different ones.
	 */
	_.wrap = function(f:Function, wrapper:Function):Function {
		return function(...args):* {
			args.unshift(f);
			return wrapper.apply(this, args);
		}
	};
	
	/**
	 * Creates a function whose return value is the result of passing the
	 * output of each function as the sole argument of the next. The classic
	 * example is h(x) = g(f(x)) -- the input to g() is the output of f(x).
	 * More practically, createRedSprite = _.compose(buildSprite,
	 * turnSpriteRed);
	 * 
	 * While underscore.js passed values from right to left, I'm passing them
	 * left to right. It seems more natural to me. If this is actually a
	 * violation of some functional programming convention, let me know and
	 * I'll change it!
	 * 
	 * Also, in underscore.js, the first function to be called could have more
	 * than one argument, while the others could not. This seems inconsistent
	 * both internally and with the concept of function composition. I've made
	 * it so each function takes exactly one input value.
	 */
	_.compose = function(f:Function, ...functions):Function {
		functions.unshift(f);
		return function(input:*):* {
			var result:* = null;
			_(functions).each(function(f:Function):void {
				result = f.call(this, result || input);
			});
			return result;
		}
	};
	
	/**
	 * Returns a function that will only be executed after being called N times.
	 */ 
	_.after = function(times:int, func:Function):Function {
		if (times <= 0) return func();
		return function():* {
			if (--times < 1) { return func.apply(this, arguments); }
		};
	};	
	
	/* OBJECTS */
	/**
	 * Returns a list of the collection's keys. Returns ints if given an array.
	 */
	_.keys = function(obj:*):Array {
		var keys:Array = [];
		if (obj is Array) {
			return _.range(0, obj.length);
		} else {
			for (var key:String in obj) {
				obj.hasOwnProperty(key) && keys.push(key);
			}
		}
		return keys;
	};
	
	/** Returns a list of the collection's values. */
	_.values = function(obj:*):Array {
		return _.map(obj, identity);
	};
	
	/** Returns a list of the names of all functions in the collection. */
	_.functions = _.methods = function(obj:*):Array {
		return _.filter(_.keys(obj), function(key:String):Boolean {
			return obj[key] is Function;
		}).sort();
	};
	
	/**
	 * Extends the object with all the properties in the supplied object(s).
	 * Alters and returns the original object, NOT a copy. To extend a copy,
	 * var copy:Object = _(obj).chain().clone().extend(otherObj).value().
	 * 
	 * An object can be extended with arrays, though this would not be a
	 * terribly sensible thing to do. The opposite doesn't work at all. Fails
	 * on XMLLists without even throwing ArgumentError, because why would you
	 * even try to do that, seriously?
	 */
	_.extend = function(obj:Object, ...args):Object {
		each(args, function(source:Object):void {
			for (var key:String in source) {
				obj[key] = source[key];
			}
		});
		return obj;
	};
	
	/**
	 * Creates a shallow copy of an Array or Object.
	 * 
	 * @throws ArgumentError if supplied an XMLList.
	 */
	_.clone = function(obj:*):* {
		if (obj is XMLList) throw new ArgumentError("_.clone cannot operate on an XMLList.");
		return (obj is Array) ? obj.slice() : _({}).extend(obj);
	};
	
	/**
	 * Insert this in a method chain to invoke the interceptor on the object
	 * being chained at that point.
	 */
	_.tap = function(obj:*, interceptor:Function):* {
		interceptor(obj);
		return obj;
	};
	
	/*
	 * All the _.isFoo functions from underscore.js are omitted, since AS3's
	 * equality and "is" operators do a good enough job.
	 */
	
	/* UTILITY */
	/**
	 * Run a function n times. Optional third context argument. The function
	 * itself may accept the loop counter as its argument.
	 */
	_.times = function(n:int, f:Function, context:Object = null):void {
		for (var i:int = 0; i < n; i++) {
			safeCall(f, context, i);
		}
	};
	
	_.mixin = function(obj:*):void {
		each(_.functions(obj), function(name:String):void {
			// remember, the value of an assignment statement is the value that was assigned.
			addToWrapper(name, _[name] = obj[name]);
		});
	};

	var eq:Function = function(a:*, b:*, stack:*):Boolean {
		// Identical objects are equal. `0 === -0`, but they aren't identical.
		// See the Harmony `egal` proposal: http://wiki.ecmascript.org/doku.php?id=harmony:egal.
		if (a === b) return a !== 0 || 1 / a == 1 / b;
		// A strict comparison is necessary because `null == undefined`.
		if (a == null || b == null) return a === b;
		// Unwrap any wrapped objects.
		if (a is Wrapper) a = (a as Wrapper)._wrapped;
		if (b is Wrapper) b = (b as Wrapper)._wrapped;
		// Invoke a custom `isEqual` method if one is provided.
		try {
			if (a.isEqual && _.isFunction(a.isEqual)) return a.isEqual(b);
			if (b.isEqual && _.isFunction(b.isEqual)) return b.isEqual(a);
		} catch (e:Error) {}
		// Compare `[[Class]]` names.
		var className:String = a.toString();
		if (className != b.toString()) return false;
		switch (className) {
			// Strings, numbers, dates, and booleans are compared by value.
			case '[object String]':
				// Primitives and their corresponding object wrappers are equivalent; thus, `"5"` is
				// equivalent to `new String("5")`.
				return a == String(b);
			case '[object Number]':
				// `NaN`s are equivalent, but non-reflexive. An `egal` comparison is performed for
				// other numeric values.
				return a != +a ? b != +b : (a == 0 ? 1 / a == 1 / b : a == +b);
			case '[object Date]':
			case '[object Boolean]':
				// Coerce dates and booleans to numeric primitive values. Dates are compared by their
				// millisecond representations. Note that invalid dates with millisecond representations
				// of `NaN` are not equivalent.
				return +a == +b;
			// RegExps are compared by their source patterns and flags.
			case '[object RegExp]':
				return a.source == b.source &&
						a.global == b.global &&
						a.multiline == b.multiline &&
						a.ignoreCase == b.ignoreCase;
		}
		if (typeof a != 'object' || typeof b != 'object') return false;
		// Assume equality for cyclic structures. The algorithm for detecting cyclic
		// structures is adapted from ES 5.1 section 15.12.3, abstract operation `JO`.
		var length:uint = stack.length;
		while (length--) {
			// Linear search. Performance is inversely proportional to the number of
			// unique nested structures.
			if (stack[length] == a) return true;
		}
		// Add the first object to the stack of traversed objects.
		stack.push(a);
		var size:uint = 0, result:Boolean = true;
		// Recursively compare objects and arrays.
		if (className == '[object Array]') {
			// Compare array lengths to determine if a deep comparison is necessary.
			size = a.length;
			result = size == b.length;
			if (result) {
				// Deep compare the contents, ignoring non-numeric properties.
				while (size--) {
					// Ensure commutative equality for sparse arrays.
					if (!(result = size in a == size in b && eq(a[size], b[size], stack))) break;
				}
			}
		} else {
			// Objects are compared via their serialized state.
			var serializedA:ByteArray = new ByteArray();
			serializedA.writeObject(a);
			var serializedB:ByteArray = new ByteArray();
			serializedB.writeObject(b);
			return serializedA.toString() === serializedB.toString();
		}
		// Remove the first object from the stack of traversed objects.
		stack.pop();
		return result;
	};

	// Perform a deep comparison to check if two objects are equal.
	_.isEqual = function(a:*, b:*):Boolean {
		return eq(a, b, []);
	};

	_.isFunction = function(a:*):Boolean {
		return (a is Function);
	};

	// Has own property?
	_.has = function(obj:*, key:*):Boolean {
		return obj.hasOwnProperty(key);
	};
	
	/** A default iterator used for functions which can optionally detect truthy values. */
	var identity:Function = function(value:*, index:* = null, list:* = null):* {
		return value;
	};
	
	/* OOP WRAPPER */
	_.prototype = Wrapper.prototype;
	
	var result:Function = function(obj:*, chain:Boolean):* {
		// if chaining, continue the chaining wrapper; otherwise return naked object
		return chain ? _(obj).chain() : obj;
	}
	
	var addToWrapper:Function = function(name:String, fn:Function):void {
		Wrapper.prototype[name] = function(...args):* {
			return result(fn.apply(_, [this._wrapped].concat(args)), this._chain);
		};
	};
	
	_.mixin(_);
	
	return _;
})();

}
