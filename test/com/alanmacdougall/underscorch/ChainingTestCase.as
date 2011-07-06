package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;

public class ChainingTestCase extends TestCase {

	public function ChainingTestCase(testMethod:String) {
		super(testMethod);
	}
	
	public function testWrapper():void {
		var list:Array = [1];
		var result:int = 0;
		_(list).each(function(n:int):void {result += n;});
		assertEquals("Wrapper fails to execute each() iterator.", result, 1);
		
		var double:Function = function(n:int):int {return n * 2;};
		var transformedList:* = _(list).map(double);
		assertEquals("Wrapper fails to return results of map() iterator.",
			transformedList[0], 2);
	}
	
	public function testWrapperChain():void {
		var double:Function = function(n:int):int {return n * 2;};
		assertEquals("Wrapper chain failed to return value.",
			_([1]).chain().map(double).map(double).value()[0], 4);
	}
}
}