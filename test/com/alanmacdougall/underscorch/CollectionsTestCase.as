package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;

public class CollectionsTestCase extends TestCase {

	public function CollectionsTestCase(testMethod:String) {
		super(testMethod);
	}
	
	public function testEach_Array():void {
		var list:Array = [1, 2, 3];
		var sum:int = 0;
		var lastIndex:int = 0;
		var listLength:int = 0;
		
		var iterator:Function = function(n:*, i:int, list:Array):void {
			sum += n;
			lastIndex = i;
			listLength = list.length;
		};
		
		_.each(list, iterator);
		
		assertEquals("_.each (3 args) did not execute over n.", 6, sum);
		assertEquals("_.each (3 args) did not execute over i.", 2, lastIndex);
		assertEquals("_.each (3 args) did not execute over list.", 3, listLength);
		
		// TO DO: test error case
	}
	
	public function testEach_VariableIteratorArguments():void {
		var list:Array = [1, 2, 3];
		var sum:int = 0;
		var lastIndex:int = 0;
		var iterator:Function = function(n:*, i:int):void {
			sum += n;
			lastIndex = i;
		};
		
		_.each(list, iterator);
		
		assertEquals("_.each (2 args) did not execute over n.", 6, sum);
		assertEquals("_.each (2 args) did not execute over i.", 2, lastIndex);
		
		sum = 0;
		iterator = function(n:*):void {
			sum += n;
		};
		
		_.each(list, iterator);
		
		assertEquals("_.each (1 arg) did not execute over n.", 6, sum);
	}
	
	/*
		Once we test each(obj:Object), we can have confidence that filter and
		map-based operations will work on objects as well as arrays. The output
		will always be an array anyway.
	*/
	public function testEach_Object():void {
		var hash:Object = {
			foo: "foo",
			bar: "bar",
			baz: "baz"
		};
		
		var keys:Array = [];
		var values:Array = [];
		
		_.each(hash, function(s:String, key:String):void {
			keys.push(key);
			values.push(s);
		});
		
		assertEquals("_.each did not execute over keys.",
			3, keys.length);
		assertEquals("_.each did not execute over values.",
			3, values.length);
	}
	
	public function testEach_XMLList():void {
		var xml:XML = <root>
			<element>foo</element>
			<element>bar</element>
			<element>baz</element>
		</root>;
		var xmlList:XMLList = xml.element;
		
		var nodes:Array = [];
		_(xmlList).each(function(node:XML):void {
			nodes.push(node);
		});
		assertEquals("Iterated over wrong number of nodes.",
			3, nodes.length);
		assertEquals("Iterated over nodes incorrectly.",
			"baz", nodes[2].text());
	}
	
	public function testEach_Context():void {
		var list:Array = [1, 2, 3];
		var result:int = 0;
		var context:Object = {
			multiplier: 10
		}
		_(list).each(function(n:int):void {
			result += n * context.multiplier;
		}, context);
		
		assertEquals("Context object was not accessed.",
			60, result);
	}
	
	public function testMap():void {
		var list:Array = [1, 2, 3];
		var lastIndex:int = 0;
		
		var output:Array = _.map(list, function(n:int, i:int):int {
			lastIndex = i;
			return n * 2;
		});
		
		assertEquals("_.map did not execute over " + list,
			list[0] * 2, output[0]);
		assertEquals("_.map did not provide correct indices to iterator.",
			2, lastIndex);
	}
	
	public function testReduce():void {
		var sumDoubled:Function = function(memo:int, n:int):int {
			return memo + (n * 2);
		};
		var result:int = _([1, 2, 3]).reduce(sumDoubled, 100);
		assertEquals("_.reduce failed somehow.", 112, result);
	}
	
	public function testReduce_NullMemo():void {
		var sum:Function = function(memo:int, n:int):int {
			return memo + n;
		};
		var result:int = _([1, 2, 3]).reduce(sum);
		assertEquals("_.reduce failed without memo argument.", 6, result);
	}
	
	// TO DO: test reduceRight
	
	public function testDetect():void {
		var list:Array = [4, 1, 5, 7, 10];
		var result:* = _(list).detect(function(n:int):Boolean {
			return n <= 2;
		});
		assertEquals("_.detect failed to find correct element.", 1, result);
		
		result = _(list).detect(function(n:int):Boolean {
			return n > 1000;
		});
		assertEquals("_.detect found element where none should match.", null, result);
	}
	
	public function testFilter():void {
		var input:Array = [1, 2, 3];
		var output:Array = _.filter(input, function(n:int):Boolean {
			return n < 2;
		});
		
		assertEquals("_.filter did not exclude enough elements.",
			1, output.length);
		assertEquals("_.filter did not exclude the correct elements.",
			1, output[0]);
		
		output = _(input).filter(function(n:int):Boolean {
			return n > 1000;
		});
		assertEquals("_.filter did not exclude enough elements.",
			0, output.length);
		output = _(input).filter(function(n:int):Boolean {
			return n < 1000;
		});
		assertEquals("_.filter excluded too many elements.",
			3, output.length);
	}
	
	public function testReject():void {
		assertEquals("_.reject did not exclude enough elements.",
			1, _([1, 2, 3]).reject(function(n:int):Boolean {return n > 1;}).length);
		assertEquals("_.reject did not exclude correct elements.",
			1, _([1, 2, 3]).reject(function(n:int):Boolean {return n > 2;})[0]);
		assertEquals("_.reject did not exclude enough elements.",
			0, _([1, 2, 3]).reject(function(n:int):Boolean {return n < 1000;}).length);
		assertEquals("_.reject excluded too many elements.",
			3, _([1, 2, 3]).reject(function(n:int):Boolean {return n > 3;}).length);
	}
	
	public function testAny():void {
		var input:Array = [1, 2, 3];
		
		assertTrue("Invalid false result from any() test.",
			_(input).any(function(n:int):Boolean {return n > 2;}));
		assertFalse("Invalid true result from any() test.",
			_(input).any(function(n:int):Boolean {return n == 0;}));
		assertFalse("Invalid true result from any() test on empty collection.",
			_([]).any(function(n:int):Boolean {return true;}));
	}
	
	public function testAll():void {
		assertTrue("Invalid false result from all() test.",
			_([1, 2, 3]).all(function(n:int):Boolean {return n > 0;}));
		assertFalse("Invalid true result from all() test.",
			_([1, 2, 3]).all(function(n:int):Boolean {return n < 1;}));
		assertFalse("Invalid true result from all() test on empty collection.",
			_([]).all(function(n:int):Boolean {return true;}));
	}
	
	public function testIncludes():void {
		assertTrue("Invalid false result from include() test.",
			_([1, 2, 3]).includes(1));
		assertFalse("Invalid true result from include() test.",
			_([1, 2, 3]).includes(4));
	}
	
	public function testInvoke():void {
		var strings:Array = ["hello"];
		var uppercaseStrings:Array = _(strings).invoke("toUpperCase");
		assertEquals("Failed to invoke method without argument.",
			"HELLO", uppercaseStrings[0]);
		
		var chains:Array = [
			["h", "i"],
			["b", "y", "e"]
		];
		var joinedChains:Array = _(chains).invoke("join", "-");
		assertTrue("Failed to invoke method with argument.",
			_(joinedChains).includes("h-i"));
		
		assertEquals("Failed to return mapped array from invoke.",
			"HELLO", _(["hello"]).invoke("toUpperCase")[0]);
	}
	
	public function testPluck():void {
		var hashes:Array = [
			{name: "foo"},
			{name: "bar"},
			{name: "baz"}
		];
		var names:Array = _(hashes).pluck("name");
		
		assertTrue("Failed to pluck values from array of hashes.",
			_(names).includes("foo"));
		assertEquals("Failed to pluck all values from array of hashes.",
			3, names.length);
	}
	
	public function testMax():void {
		var numbers:Array = [1, 4, 3, 2];
		var lists:Array = [[1, 2, 3], [1, 2], [3, 4, 5], [4, 5, 6, 7]];
		
		assertEquals("Failed to get max number.", 4, _(numbers).max());
		assertEquals("Failed to get longest list using length test.",
			4, _(lists).max(function(list:Array):Number {return list.length;}).length);
	}
		
	public function testMin():void {
		var numbers:Array = [1, 4, 3, 2];
		var lists:Array = [[1, 2, 3], [1, 2], [3, 4, 5], [4, 5, 6, 7]];
		
		assertEquals("Failed to get min number.", 1, _(numbers).min());
		assertEquals("Failed to get shortest list using length test.",
			2, _(lists).min(function(list:Array):Number {return list.length;}).length);
	}
	
	public function testSortBy():void {
		var numbers:Array = [4, 2, 0, 1];
		var strings:Array = ["aaab", "baaa", "abaa"];
		
		assertEquals("Failed to sort numbers using reversal iterator.",
			4, _(numbers).sortBy(function(n:int):int {return -(n);})[0]);
		
		var findLetter:Function = function(letter:String):Function {
			return function(s:String):int {
				return s.indexOf(letter);
			};
		};
		assertEquals("Failed to sort strings using indexOf(b) iterator.",
			"baaa", _(strings).sortBy(findLetter("b"))[0]);
	}
	
	public function testSortedIndex():void {
		var numbers:Array = [10, 20, 30, 40];
		var strings:Array = ["baaa", "abaa", "aaab"];
		
		assertEquals("Failed to find insertion point in numeric list.",
			3, _(numbers).sortedIndex(35));
		
		var findLetter:Function = function(letter:String):Function {
			return function(s:String):int {
				return s.indexOf(letter);
			};
		};
		assertEquals("Failed to find insertion point in string list using indexOf test.",
			2, _(strings).sortedIndex("aaba", findLetter("b")));
	}
	
	public function testToArray():void {
		var hash:Object = {
			name: "foo",
			value: "bar"
		};
		
		var list:Array = _(hash).toArray();
		
		assertTrue("Failed to convert hash to array.",
			list is Array);
		assertTrue("Failed to get values from hash.",
			_(list).includes("foo") && _(list).includes("bar"));
			
		list = [1, 2, 3, 4];
		
		assertTrue("Failed to convert list to new list.",
			_(list).toArray() is Array);
		assertEquals("Failed to convert list to have correct values.",
			4, _(list).toArray().length);
	}
	
	public function testSize():void {
		var list:Array = [1, 2, 3, 4];
		var hash:Object = {
			name: "foo",
			value: "bar"
		};
		
		assertEquals("Failed to get correct size for object.",
			2, _(hash).size());
		assertEquals("Failed to get correct size for array.",
			4, _(list).size());
	}
	
	public function testIsEmpty():void {
		var list:Array = [1, 2, 3];
		var emptyList:Array = [];
		var hash:Object = {foo: "a", bar: "b"};
		var emptyHash:Object = {};
		
		assertFalse("_.isEmpty failed on non-empty list.", _(list).isEmpty());
		assertTrue("_.isEmpty failed on empty list.", _(emptyList).isEmpty());
		assertFalse("_.isEmpty failed on non-empty hash.", _(hash).isEmpty());
		assertTrue("_.isEmpty failed on empty hash.", _(emptyHash).isEmpty());
		// TO DO: test error case
	}
}
}