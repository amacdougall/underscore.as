package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;
import flash.events.*;
import flash.utils.Timer;

public class FunctionsTestCase extends TestCase {

	public function FunctionsTestCase(testMethod:String) {
		super(testMethod);
	}
	
	public function testBind():void {
		var hash:Object = {
			adjective: "curried"
		};
		
		var getAdjective:Function = function():String {
			return this.adjective;
		};
		
		var bound:Function = _.bind(getAdjective, hash);
		assertEquals("Could not bind function to object.",
			"curried", bound());
		
		bound = _(getAdjective).bind(hash);
		assertEquals("Could not bind function to object with OO style.",
			"curried", bound());
		
		var getDish:Function = function(meat:String):String {
			return this.adjective + " " + meat;
		};
		
		var curried:Function = _(getDish).bind(hash, "lambda");
		assertEquals("Failed to create fully applied function with OO style.",
			"curried lambda", curried());
		
		var getMeal:Function = function(meat:String, side:String):String {
			return this.adjective + " " + meat + " with " + side;
		};
		
		curried = _(getMeal).bind(hash, "lambda");
		assertEquals("Failed to create partially applied function.",
			"curried lambda with rice", curried("rice"));
	}
	
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
		
		assertEquals("Failed to bind all methods to hash.",
			"hello", foreignContext.getMessage());
		assertEquals("Failed to bind all methods to hash.",
			"collie", foreignContext.getDog());
	}
	
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
		
		assertEquals("Bound a method not specified in arguments.",
			f, hash.getMessage);
		
		var foreignContext:Object = {
			message: "goodbye",
			getMessage: hash.getMessage,
			mood: "sad",
			getMood: hash.getMood
		};
		
		assertEquals("Bound function failed to draw on bound context.",
			"happy", foreignContext.getMood());
		assertEquals("Unbound function failed to draw on foreign context.",
			"goodbye", foreignContext.getMessage());
	}
	
	public function testMemoize():void {
		var factorial:Function = function(n:Number):Number {
			if (n <= 0) return 0;
			else if (n == 1) return 1;
			else return n * factorial(n - 1);
		};
		
		var memoized:Function = _(factorial).memoize();
		
		assertEquals("Nonmemoized factorial produces correct result in the first place.",
			120, factorial(5));
		assertEquals("Memoized and nonmemoized factorials produce identical results.",
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
		
		assertEquals("Memoized high-low function failed for some reason.",
			"positive", f(100));
		assertEquals("Memoized high-low function failed for some reason.",
			"negative", f(-50));
		assertEquals("Hasher function was not called correctly.",
			"a", hashRecord[0]);
		assertEquals("Hasher function was not called correctly.",
			"b", hashRecord[1]);
	}
	
	public function testDelay():void {
		_.delay(addAsync(), 500); // proves it happens at all
		_.delay(addAsync(function(n:int):void {
			assertEquals("Delayed function did not receive argument.", 10, n);
		}), 500, 10);
	}
	
	// defer uses delay, so shouldn't need its own test case
	
	public function testThrottle():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var throttled:Function = _(inc).throttle(300);	// allow once per 300 ms
		_(_.range(0, 700, 100)).each(function(n:int):void {
			_.delay(throttled, n);
		});
		_.delay(addAsync(function():void {
			assertEquals("Failed to throttle incrementor.", 2, invocationCount);
		}), 900);
	}
	
	public function testThrottle_Args():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var throttled:Function = _(inc).throttle(300);	// allow once per 300 ms
		_(_.range(0, 700, 100)).each(function(n:int):void {
			_.delay(throttled, n, 10);
		});
		_.delay(addAsync(function():void {
			assertEquals("Failed to throttle incrementor.", 20, invocationCount);
		}), 900);
	}
	
	public function testDebounce():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var debounced:Function = _(inc).debounce(300);	// allow once per 300 ms

		// call incrementor once at 0ms, once at 100ms, once at 200ms, and once at 300ms;
		// that is, four times, once every 100ms
		_(_.range(0, 300, 100)).each(function(n:int):void {
			_.delay(debounced, n);
		});

		// after 900ms, verify that there was only one call
		_.delay(addAsync(function():void {
			assertEquals("Failed to debounce incrementor.", 1, invocationCount);
		}), 900);
	}
	
	public function testDebounce_Args():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var debounced:Function = _(inc).debounce(300);	// allow once per 300 ms

		// as above, but attempt to increment by 10 instead of the default 1
		_(_.range(0, 300, 100)).each(function(n:int):void {
			_.delay(debounced, n, 10);
		});

		_.delay(addAsync(function():void {
			assertEquals("Failed to debounce incrementor.", 10, invocationCount);
		}), 900);
	}

	// see testDebounce and testDebounce_Args comments for implementation details
	public function testChoke():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var choked:Function = _(inc).choke(300);	// allow once per 300 ms

		choked(); // test initial call
		assertEquals("Initial call to choked function had no effect.", 1, invocationCount);

		_.delay(choked, 100);
		_.delay(choked, 200);

		_.delay(addAsync(function():void {
			assertEquals("Failed to choke incrementor.", 1, invocationCount);
		}), 500);
	}
	
	public function testChoke_Args():void {
		var invocationCount:int = 0;
		var inc:Function = function(n:int = 1):void {
			invocationCount += n;
		};
		var choked:Function = _(inc).choke(300);	// allow once per 300 ms

		choked(10); // test initial call
		assertEquals("Initial call to choked function had no effect.", 10, invocationCount);

		_.delay(choked, 100, 10);
		_.delay(choked, 200, 10);

		_.delay(addAsync(function():void {
			assertEquals("Failed to choke incrementor.", 10, invocationCount);
		}), 500);
	}
	
	public function testWrap():void {
		var sayGreeting:Function = function(name:String):String {
			return "hi " + name;
		};
		
		var yellGreeting:Function = _(sayGreeting).wrap(
			function(f:Function, name:String):String {
				return f(name).toUpperCase() + "!";
			});
		
		assertEquals("Failed to wrap sayGreeting.",
			yellGreeting("Alan"), "HI ALAN!");
		
		var inner:Function = function():String {
			return "Hello ";
		};
		
		var obj:Object = {name: "Alan"};
		obj.hi = _.wrap(inner, function(f:Function):String {
			return f() + this.name;
		});
		
		assertEquals("Wrapper failed to take on its local context.",
			"Hello Alan", obj.hi());
	}
	
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
		
		assertEquals("Failed to create composed function.",
			"HELLO, ALAN!", composed("Alan"));
	}
}
}
