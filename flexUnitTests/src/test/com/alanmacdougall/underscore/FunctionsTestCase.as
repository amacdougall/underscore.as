package test.com.alanmacdougall.underscore {
// imports
import com.alanmacdougall.underscore._;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.flexunit.async.Async;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;

import flash.events.TimerEvent;
import flash.utils.Timer;


/**
 * Test underscore.as methods operating on functions.
 */
public class FunctionsTestCase {

	public function runAfterTimeout(testCase:Object, delay:Number, f:Function):void {
		var runWrapper:Function = function(...args):void {f();};
		var timer:Timer = new Timer(delay);
		Async.handleEvent(testCase, timer, TimerEvent.TIMER, runWrapper, delay);
		timer.start();
	}

	[Test]
	public function testBind():void {
		var hash:Object = {
			adjective: "curried"
		};
		
		var getAdjective:Function = function():String {
			return this.adjective;
		};
		
		var bound:Function = _.bind(getAdjective, hash);
		Assert.assertEquals("Could not bind function to object.",
			"curried", bound());
		
		bound = _(getAdjective).bind(hash);
		Assert.assertEquals("Could not bind function to object with OO style.",
			"curried", bound());
		
		var getDish:Function = function(meat:String):String {
			return this.adjective + " " + meat;
		};
		
		var curried:Function = _(getDish).bind(hash, "lambda");
		Assert.assertEquals("Failed to create fully applied function with OO style.",
			"curried lambda", curried());
		
		var getMeal:Function = function(meat:String, side:String):String {
			return this.adjective + " " + meat + " with " + side;
		};
		
		curried = _(getMeal).bind(hash, "lambda");
		Assert.assertEquals("Failed to create partially applied function.",
			"curried lambda with rice", curried("rice"));
	}

	[Test]
	public function testBindAll():void {
		var hash:Object = {
			message: "hello",
			getMessage: function():String {return this.message;},
			mood: "happy",
			getMood: function():String {return this.mood;},
			dog: "collie",
			getDog: function():String {return this.dog;}
		};
		
		_(hash).bindAll();
		
		var foreignContext:Object = {
			message: "goodbye",
			getMessage: hash.getMessage, // should still get "hello"
			dog: "boxer",
			getDog: hash.getDog	// should still get "collie"
		};
		
		Assert.assertEquals("Failed to bind all methods to hash.",
			"hello", foreignContext.getMessage());
		Assert.assertEquals("Failed to bind all methods to hash.",
			"collie", foreignContext.getDog());
	}

	[Test]
	public function testBindAll_Selected():void {
		var hash:Object = {
			message: "hello",
			getMessage: function():String {return this.message;},
			mood: "happy",
			getMood: function():String {return this.mood;},
			dog: "collie",
			getDog: function():String {return this.dog;}
		};
		
		var f:Function = hash.getMessage;
		
		_(hash).bindAll("getMood", "getDog");
		
		Assert.assertEquals("Bound a method not specified in arguments.",
			f, hash.getMessage);
		
		var foreignContext:Object = {
			message: "goodbye",
			getMessage: hash.getMessage,
			mood: "sad",
			getMood: hash.getMood
		};
		
		Assert.assertEquals("Bound function failed to draw on bound context.",
			"happy", foreignContext.getMood());
		Assert.assertEquals("Unbound function failed to draw on foreign context.",
			"goodbye", foreignContext.getMessage());
	}

	[Test]
	public function testMemoize():void {
		var factorial:Function = function(n:Number):Number {
			if (n <= 0) return 0;
			else if (n == 1) return 1;
			else return n * factorial(n - 1);
		};
		
		var memoized:Function = _(factorial).memoize();
		
		Assert.assertEquals("Nonmemoized factorial produces correct result in the first place.",
			120, factorial(5));
		Assert.assertEquals("Memoized and nonmemoized factorials produce identical results.",
			factorial(5), memoized(5));
		
		var f:Function = function(n:int):String {
			return (n >= 0) ? "positive" : "negative";
		}
		
		var hashRecord:Array = [];
		var hasher:Function = function(n:int):String {
			var hashCode:String = (n >= 0) ? "a" : "b";
			_(hashRecord).includes(hashCode) || hashRecord.push(hashCode);
			return hashCode;
		}
		
		f = _(f).memoize(hasher);
		
		for (var i:int = 100; i >= -100; i--) {
			f(i);
		}
		
		Assert.assertEquals("Memoized high-low function failed for some reason.",
			"positive", f(100));
		Assert.assertEquals("Memoized high-low function failed for some reason.",
			"negative", f(-50));
		Assert.assertEquals("Hasher function was not called correctly.",
			"a", hashRecord[0]);
		Assert.assertEquals("Hasher function was not called correctly.",
			"b", hashRecord[1]);
	}

	[Test(async)]
	public function testDelay():void {
		var n:int = 0;
		var m:int = 0;

		_(function():void {
			n = 10;
		}).delay(500);

		_(function(amount:int):void {
			m += amount;
		}).delay(500, 10);

		runAfterTimeout(this, 750, function():void {
			Assert.assertEquals("Delayed function did not execute.",
				10, n);
			Assert.assertEquals("Delayed function did not receive argument.",
				10, m);
		});
	}

	[Test(async)]
	public function testThrottle():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			trace("inc invoked");
			invocationCount += n;
		};

		var throttled:Function = _(inc).throttle(300);	// allow once per 300 ms
		_(_.range(0, 700, 100)).each(function(n:int):void {
			_.delay(throttled, n);
		});

		runAfterTimeout(this, 900, function():void {
			Assert.assertEquals("Failed to throttle incrementor.", 2, invocationCount);
		});
	}

	[Test(async)]
	public function testThrottle_Args():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var throttled:Function = _(inc).throttle(300);	// allow once per 300 ms
		_(_.range(0, 700, 100)).each(function(n:int):void {
			_.delay(throttled, n, 10);
		});
		runAfterTimeout(this, 900, function():void {
			Assert.assertEquals("Failed to throttle incrementor.", 20, invocationCount);
		});
	}

	[Test(async)]
	public function testDebounce():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var debounced:Function = _(inc).debounce(300);	// allow once per 300 ms

		debounced(); // initial call
		_.delay(debounced, 100);
		_.delay(debounced, 200); // occurs 500ms after call

		// after 500ms, verify that there was only one call
		runAfterTimeout(this, 750, function():void {
			Assert.assertEquals("Failed to debounce incrementor.", 1, invocationCount);
		});
	}

	[Test(async)]
	public function testDebounce_Args():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var debounced:Function = _(inc).debounce(300);	// allow once per 300 ms

		debounced(10);
		_.delay(debounced, 100, 20);
		_.delay(debounced, 200, 30); // occurs 500ms after call

		runAfterTimeout(this, 750, function():void {
			Assert.assertTrue("Failed to debounce incrementor.", invocationCount < 60);
			Assert.assertEquals("Failed to execute only the last call.", 30, invocationCount);
		});
	}


	[Test]
	public function testWrap():void {
		var sayGreeting:Function = function(name:String):String {
			return "hi " + name;
		};
		
		var yellGreeting:Function = _(sayGreeting).wrap(
			function(f:Function, name:String):String {
				return f(name).toUpperCase() + "!";
			});
		
		Assert.assertEquals("Failed to wrap sayGreeting.",
			yellGreeting("Alan"), "HI ALAN!");
		
		var inner:Function = function():String {
			return "Hello ";
		};
		
		var obj:Object = {name: "Alan"};
		obj.hi = _.wrap(inner, function(f:Function):String {
			return f() + this.name;
		});
		
		Assert.assertEquals("Wrapper failed to take on its local context.",
			"Hello Alan", obj.hi());
	}

	[Test]
	public function testCompose():void {
		var appendExclamationPoint:Function = function(input:String):String {
			return input + "!";
		};
		
		var prependGreeting:Function = function(input:String):String {
			return "Hello, " + input;
		};
		
		var cruiseControlForCool:Function = function(input:String):String {
			return input.toUpperCase();
		};
		
		var composed:Function = _.compose(
			appendExclamationPoint, prependGreeting, cruiseControlForCool);
		
		Assert.assertEquals("Failed to create composed function.",
			"HELLO, ALAN!", composed("Alan"));
	}
	
	[Test]
	public function testAfter():void {
		var count:int = 0;
		
		var incrementCount:Function = _.after(3, function():void {
			count++;
		});
		
		incrementCount(); // nothing
		incrementCount(); // nothing
		incrementCount(); // do increment
		
		Assert.assertEquals(1, count);
	}
}
}
