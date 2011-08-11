package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;

public class ArraysTestCase extends TestCase {

	public function ArraysTestCase(testMethod:String) {
		super(testMethod);
	}
	
	public function testFirst():void {
		assertEquals("Failed to get first array element.",
			1, _([1, 2]).first());
		
		assertEquals("Failed to get first mapped array element.",
			2, _.first(_.map([1, 2], function(n:int):int {return n * 2;})));
		
		assertEquals("Failed to get first n array elements.",
			3, _([1, 2, 3, 4]).first(3).length);
		assertEquals("Failed to get correct n array elements.",
			3, _([1, 2, 3, 4]).first(3)[2]);
		
		var nestedList = [[1, 2], [3, 4]];
		var firstItems = _.map(nestedList, _.first);
		assertEquals("Got wrong number of items using first as a map iterator.",
			2, firstItems.length);
		assertTrue("Failed to get correct items using first as a map iterator.",
			_(firstItems).includes(1) && _(firstItems).includes(3));
	}
	
	public function testRest():void {
		assertEquals("Failed to get rest of array elements.",
			3, _([1, 2, 3, 4]).rest().length);
		assertEquals("Failed to get correct rest of array elements.",
			2, _([1, 2, 3, 4]).rest()[0]);
		assertEquals("Failed to get last n array elements.",
			2, _([1, 2, 3, 4]).rest(2).length);
		assertEquals("Failed to get correct last n array elements.",
			3, _([1, 2, 3, 4]).rest(2)[0]);
			
		assertEquals("Got wrong elements using rest as a _.map iterator.",
			5, _([[1, 2, 3], [4, 5, 6]]).map(_.rest)[1][0]);
		assertEquals("Got wrong numbers of elements using rest as a _.map iterator.",
			2, _([[1, 2, 3], [4, 5, 6]]).map(_.rest)[0].length);
	}
	
	public function testCompact():void {
		var foo:Object;
		assertEquals("Failed to excise falsy array elements.",
			1, _([true, false, 0, "", Math.sqrt(-1), null, foo]).compact().length);
	}
	
	public function testFlatten():void {
		var nested:Array = [
			[1, 2],
			[3, 4]
		];
		var flat:Array = _(nested).flatten();
		assertEquals("Failed to flatten nested array.",
			4, flat.length);
		assertEquals("Failed to preserve relative order in flattened array.",
			1, _(flat).first());
		assertEquals("Failed to preserve relative order in flattened array.",
			4, _(flat).last());
	}
	
	public function testWithout():void {
		var list:Array = [1, 2, 3, 4];
		assertEquals("Failed to filter out elements.",
			2, _(list).without(1, 4).length);
		assertFalse("Failed to filter out correct elements.",
			_(list).chain().without(1, 4).includes(1).value());
	}
	
	public function testUnique():void {
		var list:Array = [1, 1, 2, 3, 4, 4, 5, 1];
		var unique:Array = _(list).unique();
		assertEquals("Failed to filter out duplicate elements.",
			5, unique.length);
		assertTrue("Failed to filter out correct elements, or elements were not in initial order.",
			(function(list:Array):Boolean {
				// works as long as unique list should be [1, 2, 3, 4, 5]
				for (var i:int = 0; i < list.length; i++) {
					if (list[i] != i + 1) return false;
				}
				return true;
			})(unique));
	}
	
	public function testIntersect():void {
		var list:Array = [1, 2, 3, 400, 500, 6, 7, 8, 9];
		var foo:Array = [400, "a", "b", "c", 500];
		var bar:Array = [500, 400, 300, 200];
		
		var intersection:Array = _(list).intersect(foo, bar);
		assertEquals("Failed to get correct number of intersecting elements.",
			2, intersection.length);
		assertTrue("Failed to get correct intersecting element.",
			_(intersection).includes(400) &&
			_(intersection).includes(500));
	}
	
	public function testZip():void {
		var foo:Array = [1, 2, 3, 4];
		var bar:Array = ["one", "two", "three", "four"];
		var baz:Array = ["uno", "dos", "tres", "quatro"];
		var zipped:Array = _(foo).zip(bar, baz);
		
		assertEquals("Failed to generate correct length zipped list.",
			4, zipped.length);
		assertTrue("Failed to zip nested list.",
			_(zipped).all(function(element:*):Boolean {
				return element is Array
			}));
		assertEquals("Failed to zip correct values.",
			"dos", zipped[1][2]);
	}
	
	public function testRange():void {
		var straight:Array = _.range(10);	// 0 to 9
		var high:Array = _.range(10, 20);	// 10 to 19
		var skip:Array = _.range(0, 10, 2);	// even numbers 0 to 8
		var fractions:Array = _.range(0.0, 1.1, 0.1);	// tenths, 0.0 to 1.0
		
		assertEquals("Wrong length for 0-9 sequence.",
			10, straight.length);
		assertEquals("Wrong first value for 0-9 sequence.",
			0, _(straight).first());
		assertEquals("Wrong last value for 0-9 sequence.",
			9, _(straight).last());
			
		assertEquals("Wrong length for 10-19 sequence.",
			10, high.length);
		assertEquals("Wrong first value for 10-19 sequence.",
			10, _(high).first());
		assertEquals("Wrong last value for 10-19 sequence.",
			19, _(high).last());
			
		assertEquals("Wrong length for evens sequence.",
			5, skip.length);
		assertEquals("Wrong first value for evens sequence.",
			0, _(skip).first());
		assertEquals("Wrong last value for evens sequence.",
			8, _(skip).last());
		
		assertEquals("Wrong length for 0-1.0 sequence.",
			11, fractions.length);
		assertEquals("Wrong first value for 0-1.0 sequence.",
			0, _(fractions).first());
		
		// float addition is not perfectly accurate; allow 1/1000th margin of error
		var tolerance:Number = 1.0 / 1000;
		assertTrue("Wrong last value for 0-1.0 sequence, was " + _(fractions).last() +
			", which was not within " + tolerance + " of 1.0",
			Math.abs(_(fractions).last() - 1.0) <= tolerance);
	}
}
}