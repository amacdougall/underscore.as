package test.com.alanmacdougall.underscore {
// imports
import com.alanmacdougall.underscore._;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;


/**
 * Test underscore.as method chaining.
 */
public class ChainingTestCase {
	[Test]
	public function testWrapper():void {
		var list:Array = [1];
		var result:int = 0;
		_(list).each(function(n:int):void {result += n;});
		Assert.assertEquals("Wrapper fails to execute each() iterator.", result, 1);
		
		var double:Function = function(n:int):int {return n * 2;};
		var transformedList:* = _(list).map(double);
		Assert.assertEquals("Wrapper fails to return results of map() iterator.",
			transformedList[0], 2);
	}

	[Test]
	public function testWrapperChain():void {
		var double:Function = function(n:int):int {return n * 2;};
		Assert.assertEquals("Wrapper chain failed to return value.",
			_([1]).chain().map(double).map(double).value()[0], 4);
	}
}
}
