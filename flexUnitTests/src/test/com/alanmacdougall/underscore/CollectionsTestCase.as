package test.com.alanmacdougall.underscore {
// imports
import com.alanmacdougall.underscore._;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;

import flash.utils.Dictionary;


/**
 * Test underscore.as general collection methods.
 */
public class CollectionsTestCase {

	[Test]
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
		
		Assert.assertEquals("_.each did not execute over keys.",
			3, keys.length);
		Assert.assertEquals("_.each did not execute over values.",
			3, values.length);
	}

	[Test]
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
		Assert.assertEquals("Iterated over wrong number of nodes.",
			3, nodes.length);
		Assert.assertEquals("Iterated over nodes incorrectly.",
			"baz", nodes[2].text());
	}

	[Test]
	public function testEach_Context():void {
		var list:Array = [1, 2, 3];
		var result:int = 0;
		var context:Object = {
			multiplier: 10
		}
		_(list).each(function(n:int):void {
			result += n * context.multiplier;
		}, context);
		
		Assert.assertEquals("Context object was not accessed.",
			60, result);
	}

	[Test]
	public function testMap():void {
		var list:Array = [1, 2, 3];
		var lastIndex:int = 0;
		
		var output:Array = _.map(list, function(n:int, i:int):int {
			lastIndex = i;
			return n * 2;
		});
		
		Assert.assertEquals("_.map did not execute over " + list,
			list[0] * 2, output[0]);
		Assert.assertEquals("_.map did not provide correct indices to iterator.",
			2, lastIndex);
	}

	[Test]
	public function testReduce():void {
		var sumDoubled:Function = function(memo:int, n:int):int {
			return memo + (n * 2);
		};
		var result:int = _([1, 2, 3]).reduce(sumDoubled, 100);
		Assert.assertEquals("_.reduce failed somehow.", 112, result);
	}

	[Test]
	public function testReduce_NullMemo():void {
		var sum:Function = function(memo:int, n:int):int {
			return memo + n;
		};
		var result:int = _([1, 2, 3]).reduce(sum);
		Assert.assertEquals("_.reduce failed without memo argument.", 6, result);
	}

	[Test]
	public function testDetect():void {
		var list:Array = [4, 1, 5, 7, 10];
		var result:* = _(list).detect(function(n:int):Boolean {
			return n <= 2;
		});
		Assert.assertEquals("_.detect failed to find correct element.", 1, result);
		
		result = _(list).detect(function(n:int):Boolean {
			return n > 1000;
		});
		Assert.assertEquals("_.detect found element where none should match.", null, result);
	}

	[Test]
	public function testFilter():void {
		var input:Array = [1, 2, 3];
		var output:Array = _.filter(input, function(n:int):Boolean {
			return n < 2;
		});
		
		Assert.assertEquals("_.filter did not exclude enough elements.",
			1, output.length);
		Assert.assertEquals("_.filter did not exclude the correct elements.",
			1, output[0]);
		
		output = _(input).filter(function(n:int):Boolean {
			return n > 1000;
		});
		Assert.assertEquals("_.filter did not exclude enough elements.",
			0, output.length);
		output = _(input).filter(function(n:int):Boolean {
			return n < 1000;
		});
		Assert.assertEquals("_.filter excluded too many elements.",
			3, output.length);
	}

	[Test]
	public function testReject():void {
		Assert.assertEquals("_.reject did not exclude enough elements.",
			1, _([1, 2, 3]).reject(function(n:int):Boolean {return n > 1;}).length);
		Assert.assertEquals("_.reject did not exclude correct elements.",
			1, _([1, 2, 3]).reject(function(n:int):Boolean {return n > 2;})[0]);
		Assert.assertEquals("_.reject did not exclude enough elements.",
			0, _([1, 2, 3]).reject(function(n:int):Boolean {return n < 1000;}).length);
		Assert.assertEquals("_.reject excluded too many elements.",
			3, _([1, 2, 3]).reject(function(n:int):Boolean {return n > 3;}).length);
	}

	[Test]
	public function testAny():void {
		var input:Array = [1, 2, 3];
		
		Assert.assertTrue("Invalid false result from any() test.",
			_(input).any(function(n:int):Boolean {return n > 2;}));
		Assert.assertFalse("Invalid true result from any() test.",
			_(input).any(function(n:int):Boolean {return n == 0;}));
		Assert.assertFalse("Invalid true result from any() test on empty collection.",
			_([]).any(function(n:int):Boolean {return true;}));
	}

	[Test]
	public function testAll():void {
		Assert.assertTrue("Invalid false result from all() test.",
			_([1, 2, 3]).all(function(n:int):Boolean {return n > 0;}));
		Assert.assertFalse("Invalid true result from all() test.",
			_([1, 2, 3]).all(function(n:int):Boolean {return n < 1;}));
		Assert.assertTrue("Invalid false result from all() test on empty collection.",
			_([]).all(function(n:int):Boolean {return false;}));
	}

	[Test]
	public function testIncludes():void {
		Assert.assertTrue("Invalid false result from include() test.",
			_([1, 2, 3]).includes(1));
		Assert.assertFalse("Invalid true result from include() test.",
			_([1, 2, 3]).includes(4));
	}

	[Test]
	public function testInvoke():void {
		var strings:Array = ["hello"];
		var uppercaseStrings:Array = _(strings).invoke("toUpperCase");
		Assert.assertEquals("Failed to invoke method without argument.",
			"HELLO", uppercaseStrings[0]);
		
		var chains:Array = [
			["h", "i"],
			["b", "y", "e"]
		];
		var joinedChains:Array = _(chains).invoke("join", "-");
		Assert.assertTrue("Failed to invoke method with argument.",
			_(joinedChains).includes("h-i"));
		
		Assert.assertEquals("Failed to return mapped array from invoke.",
			"HELLO", _(["hello"]).invoke("toUpperCase")[0]);
	}

	[Test]
	public function testPluck():void {
		var hashes:Array = [
			{name: "foo"},
			{name: "bar"},
			{name: "baz"}
		];
		var names:Array = _(hashes).pluck("name");
		
		Assert.assertTrue("Failed to pluck values from array of hashes.",
			_(names).includes("foo"));
		Assert.assertEquals("Failed to pluck all values from array of hashes.",
			3, names.length);
	}

	[Test]
	public function testMax():void {
		var numbers:Array = [1, 4, 3, 2];
		var lists:Array = [[1, 2, 3], [1, 2], [3, 4, 5], [4, 5, 6, 7]];
		var dates:Array = [
			new Date(1776, 07, 04), // American independence
			new Date(1949, 10, 01), // Mao declares PRC
			new Date(1789, 07, 14)	// Bastille Day
		];
		
		Assert.assertEquals("Failed to get max number.", 4, _(numbers).max());
		Assert.assertEquals("Failed to get longest list using length test.",
			4, _(lists).max(function(list:Array):Number {return list.length;}).length);
		Assert.assertEquals("Failed to get most recent date.", dates[1], _(dates).max());
	}

	[Test]
	public function testMin():void {
		var numbers:Array = [1, 4, 3, 2];
		var lists:Array = [[1, 2, 3], [1, 2], [3, 4, 5], [4, 5, 6, 7]];
		var dates:Array = [
			new Date(1776, 07, 04),
			new Date(1949, 10, 01),
			new Date(1789, 07, 14)
		];
		
		Assert.assertEquals("Failed to get min number.", 1, _(numbers).min());
		Assert.assertEquals("Failed to get shortest list using length test.",
			2, _(lists).min(function(list:Array):Number {return list.length;}).length);
		Assert.assertEquals("Failed to get least recent date.", dates[0], _(dates).min());
	}

	[Test]
	public function testSortBy():void {
		var numbers:Array = [4, 2, 0, 1];
		var strings:Array = ["aaab", "baaa", "abaa"];
		
		Assert.assertEquals("Failed to sort numbers using reversal iterator.",
			4, _(numbers).sortBy(function(n:int):int {return -(n);})[0]);
		
		var findLetter:Function = function(letter:String):Function {
			return function(s:String):int {
				return s.indexOf(letter);
			};
		};
		Assert.assertEquals("Failed to sort strings using indexOf(b) iterator.",
			"baaa", _(strings).sortBy(findLetter("b"))[0]);
	}

	[Test]
	public function testSortedIndex():void {
		var numbers:Array = [10, 20, 30, 40];
		var strings:Array = ["baaa", "abaa", "aaab"];
		
		Assert.assertEquals("Failed to find insertion point in numeric list.",
			3, _(numbers).sortedIndex(35));
		
		var findLetter:Function = function(letter:String):Function {
			return function(s:String):int {
				return s.indexOf(letter);
			};
		};
		Assert.assertEquals("Failed to find insertion point in string list using indexOf test.",
			2, _(strings).sortedIndex("aaba", findLetter("b")));
	}

	[Test]
	public function testToArray():void {
		var hash:Object = {
			name: "foo",
			value: "bar"
		};
		
		var list:Array = _(hash).toArray();
		
		Assert.assertTrue("Failed to convert hash to array.",
			list is Array);
		Assert.assertTrue("Failed to get values from hash.",
			_(list).includes("foo") && _(list).includes("bar"));
			
		list = [1, 2, 3, 4];
		
		Assert.assertTrue("Failed to convert list to new list.",
			_(list).toArray() is Array);
		Assert.assertEquals("Failed to convert list to have correct values.",
			4, _(list).toArray().length);
	}

	[Test]
	public function testSize():void {
		var list:Array = [1, 2, 3, 4];
		var hash:Object = {
			name: "foo",
			value: "bar"
		};
		
		Assert.assertEquals("Failed to get correct size for object.",
			2, _(hash).size());
		Assert.assertEquals("Failed to get correct size for array.",
			4, _(list).size());
	}

	[Test]
	public function testIsEmpty():void {
		var list:Array = [1, 2, 3];
		var emptyList:Array = [];
		var hash:Object = {foo: "a", bar: "b"};
		var emptyHash:Object = {};
		
		Assert.assertFalse("_.isEmpty failed on non-empty list.", _(list).isEmpty());
		Assert.assertTrue("_.isEmpty failed on empty list.", _(emptyList).isEmpty());
		Assert.assertFalse("_.isEmpty failed on non-empty hash.", _(hash).isEmpty());
		Assert.assertTrue("_.isEmpty failed on empty hash.", _(emptyHash).isEmpty());
		// TO DO: test error case
	}

	[Test]
	public function testEquals():void {
		var a:*, b:*;

		a = [1, 2, 3];
		b = [1, 2, 3];
		Assert.assertTrue("Failed to detect equal arrays.", _(a).isEqual(b));

		a = [1, 2, 3];
		b = [1, 2, 4];
		Assert.assertFalse("Failed to detect unequal arrays.", _(a).isEqual(b));

		a = {a: 1, b: 2, c: 3};
		b = {a: 1, b: 2, c: 3};
		Assert.assertTrue("Failed to detect equal objects.", _(a).isEqual(b));

		a = {a: 1, b: 2, c: 3};
		b = {a: 0, b: 2, c: 3};
		Assert.assertFalse("Failed to detect unequal objects.", _(a).isEqual(b));

		a = 1;
		b = 1;
		Assert.assertTrue("Failed to detect equal numbers.", _(a).isEqual(b));

		a = 1;
		b = 2;
		Assert.assertFalse("Failed to detect unequal numbers.", _(a).isEqual(b));

		a = "Hello";
		b = "Hello";
		Assert.assertTrue("Failed to detect equal strings.", _(a).isEqual(b));

		a = "Hello";
		b = "Goodbye";
		Assert.assertFalse("Failed to detect unequal strings.", _(a).isEqual(b));

		a = {a: 1};
		b = new Dictionary();
		b["a"] = 1;
		Assert.assertFalse("Failed to detect different types.", _(a).isEqual(b));
	}

	[Test]
	public function testNestedEquals():void {
		var a:*, b:*;

		a = [[1, 2], [3, 4]];
		b = [[1, 2], [3, 4]];
		Assert.assertTrue("Failed to detect equal nested arrays.", _(a).isEqual(b));

		a = [[1, 2], [3, 4]];
		b = [[1, 2], [6, 4]];
		Assert.assertFalse("Failed to detect unequal nested arrays.", _(a).isEqual(b));

		a = {meta: {a: 1, b: 2}, hyper: {a: 3, b: 4}};
		b = {meta: {a: 1, b: 2}, hyper: {a: 3, b: 4}};
		Assert.assertTrue("Failed to detect equal nested objects.", _(a).isEqual(b));

		a = {meta: {a: 1, b: 2}, hyper: {a: 3, b: 4}};
		b = {meta: {a: 1, b: 3}, hyper: {a: 3, b: 4}};
		Assert.assertFalse("Failed to detect unequal nested objects.", _(a).isEqual(b));
	}
}
}
