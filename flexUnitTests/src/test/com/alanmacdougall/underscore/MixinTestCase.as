package test.com.alanmacdougall.underscore {
// imports
import com.alanmacdougall.underscore._;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;

import flash.events.TimerEvent;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getQualifiedClassName;


/**
 * Test selected underscore.as mixins.
 */
public class MixinTestCase {

	public function runAfterTimeout(testCase:Object, delay:Number, f:Function):void {
		var runWrapper:Function = function(...args):void {f();};
		var timer:Timer = new Timer(delay);
		Async.handleEvent(testCase, timer, TimerEvent.TIMER, runWrapper, delay);
		timer.start();
	}

	/** Creates _.chokeDebounce if not present. */
	private function mixinChokeDebounce():void {
		_.chokeDebounce || _.mixin({
			chokeDebounce: function(f:Function, wait:int):Function {
				var debounced:Function = _(f).debounce(wait);
				var timer:Timer = new Timer(wait, 1); // choke timer

				return function(...runtimeArgs):* {
					if (!timer.running) {
						f.apply(this, runtimeArgs);
						timer.start();
					} else {
						debounced.apply(this, runtimeArgs);
					}
				};
			}
		});
	}

	/** Creates _.equals if not present. */
	private function mixinEquals():void {
		_.isEqual || _.mixin({
			/**
			 * Compares objects and arrays, recursively, on a value-for-value
			 * basis; or performs a straight-up threequals on scalars.
			 * Primitive compared to _.isEqual from underscore.js 1.3.1! Should
			 * be reliable in comparing simple data structures, though, such as
			 * you would find in a JSON file.
			 */
			equals: function(a:*, b:*):Boolean {
				if (getQualifiedClassName(a) != getQualifiedClassName(b)) {
					return false; // not the same type of object in the first place
				}

				// given preceding test, a and b are the same type
				if (getQualifiedClassName(a) == "Object") {
					var key:String;
					var keysObserved:Object = {};
					for (key in a) {
						if (!b.hasOwnProperty(key) || !_(a[key]).equals(b[key])) {
							return false;
						}
						keysObserved[key] = true;
					}

					for (key in b) {
						if (!keysObserved[key]) {
							return false; // key exists in b that is not in a
						}
					}

					return true;
				} else if (a is Array) {
					if (a.length != b.length) {
						return false;
					} else {
						for (var i:int = 0; i < a.length; i++) {
							if (!_(a[i]).equals(b[i])) {
								return false;
							}
						}
					}

					return true;
				} else {
					// if not an object or array, test using strict equality
					return a === b;
				}
			}
		});
	}

	[Test(async)]
	public function testChokeDebounce():void {
		mixinChokeDebounce();
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};

		// allow once immediately, then only once again after 300ms
		var chokeDebounced:Function = _(inc).chokeDebounce(300);

		chokeDebounced(); // test initial call
		Assert.assertEquals("Initial call to chokeDebounced function had no effect.", 1, invocationCount);

		_.delay(chokeDebounced, 100);
		_.delay(chokeDebounced, 150);
		_.delay(chokeDebounced, 200);

		runAfterTimeout(this, 800, function():void {
			Assert.assertEquals("Failed to debounce incrementor.", 2, invocationCount);
		});
	}

	[Test(async)]
	public function testChokeDebounce_Args():void {
		mixinChokeDebounce();
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};

		// allow once immediately, then only once again after 300ms
		var chokeDebounced:Function = _(inc).chokeDebounce(300);

		chokeDebounced(10); // test initial call
		Assert.assertEquals("Initial call to chokeDebounced function had no effect or " +
			"did not pass arguments.", 10, invocationCount);

		_.delay(chokeDebounced, 100, 10);
		_.delay(chokeDebounced, 150, 10);
		_.delay(chokeDebounced, 200, 10);

		runAfterTimeout(this, 800, function():void {
			Assert.assertEquals("Failed to debounce incrementor or did not pass arguments.",
				20, invocationCount);
		});
	}

	[Test]
	public function testEquals():void {
		mixinEquals();
		var a:*, b:*;

		a = [1, 2, 3];
		b = [1, 2, 3];
		Assert.assertTrue("Failed to detect equal arrays.", _(a).equals(b));

		a = [1, 2, 3];
		b = [1, 2, 4];
		Assert.assertFalse("Failed to detect unequal arrays.", _(a).equals(b));

		a = {a: 1, b: 2, c: 3};
		b = {a: 1, b: 2, c: 3};
		Assert.assertTrue("Failed to detect equal objects.", _(a).equals(b));

		a = {a: 1, b: 2, c: 3};
		b = {a: 0, b: 2, c: 3};
		Assert.assertFalse("Failed to detect unequal objects.", _(a).equals(b));

		a = 1;
		b = 1;
		Assert.assertTrue("Failed to detect equal numbers.", _(a).equals(b));

		a = 1;
		b = 2;
		Assert.assertFalse("Failed to detect unequal numbers.", _(a).equals(b));

		a = "Hello";
		b = "Hello";
		Assert.assertTrue("Failed to detect equal strings.", _(a).equals(b));

		a = "Hello";
		b = "Goodbye";
		Assert.assertFalse("Failed to detect unequal strings.", _(a).equals(b));

		a = {a: 1};
		b = new Dictionary();
		b["a"] = 1;
		Assert.assertFalse("Failed to detect different types.", _(a).equals(b));
	}

	[Test]
	public function testNestedEquals():void {
		mixinEquals();
		var a:*, b:*;

		a = [[1, 2], [3, 4]];
		b = [[1, 2], [3, 4]];
		Assert.assertTrue("Failed to detect equal nested arrays.", _(a).equals(b));

		a = [[1, 2], [3, 4]];
		b = [[1, 2], [6, 4]];
		Assert.assertFalse("Failed to detect unequal nested arrays.", _(a).equals(b));

		a = {meta: {a: 1, b: 2}, hyper: {a: 3, b: 4}};
		b = {meta: {a: 1, b: 2}, hyper: {a: 3, b: 4}};
		Assert.assertTrue("Failed to detect equal nested objects.", _(a).equals(b));

		a = {meta: {a: 1, b: 2}, hyper: {a: 3, b: 4}};
		b = {meta: {a: 1, b: 3}, hyper: {a: 3, b: 4}};
		Assert.assertFalse("Failed to detect unequal nested objects.", _(a).equals(b));
	}
}
}
