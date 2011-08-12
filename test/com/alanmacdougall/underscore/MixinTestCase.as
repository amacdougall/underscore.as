package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;
import flash.events.*;
import flash.utils.Timer;

public class MixinTestCase extends TestCase {

	public function MixinTestCase(testMethod:String) {
		super(testMethod);
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

	public function testChokeDebounce():void {
		mixinChokeDebounce();
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};

		// allow once immediately, then only once again after 300ms
		var chokeDebounced:Function = _(inc).chokeDebounce(300);

		chokeDebounced(); // test initial call
		assertEquals("Initial call to chokeDebounced function had no effect.", 1, invocationCount);

		_.delay(chokeDebounced, 100);
		_.delay(chokeDebounced, 150);
		_.delay(chokeDebounced, 200);

		_.delay(addAsync(function():void {
			assertEquals("Failed to debounce incrementor.", 2, invocationCount);
		}), 800);
	}

	public function testChokeDebounce_Args():void {
		mixinChokeDebounce();
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};

		// allow once immediately, then only once again after 300ms
		var chokeDebounced:Function = _(inc).chokeDebounce(300);

		chokeDebounced(10); // test initial call
		assertEquals("Initial call to chokeDebounced function had no effect or " +
			"did not pass arguments.", 10, invocationCount);

		_.delay(chokeDebounced, 100, 10);
		_.delay(chokeDebounced, 150, 10);
		_.delay(chokeDebounced, 200, 10);

		_.delay(addAsync(function():void {
			assertEquals("Failed to debounce incrementor or did not pass arguments.",
				20, invocationCount);
		}), 800);
	}
}
}
