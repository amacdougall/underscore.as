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
}
}
