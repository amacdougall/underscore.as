package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;

public class UtilitiesTestCase extends TestCase {

	public function UtilitiesTestCase(testMethod:String) {
		super(testMethod);
	}
	
	public function testTimes():void {
		var n:int = 5;
		_(5).times(function():void {n++;});
		assertEquals("Failed to execute function multiple times.",
			10, n);
		
		var counter:int = 0;
		_(5).times(function(i:int):void {
			counter = i;
		});
		assertEquals("Failed to take loop counter as an argument.",
			4, counter);
	}
	
	public function testMixin():void {
		_.mixin({
			emphasize: function(input:String):String {
				return input.toUpperCase();
			},
			append: function(input:String, suffix:String):String {
				return input + suffix;
			}
		});
		
		assertEquals("Failed to mix in method.",
			"HELLO", _.emphasize("hello"));
		assertEquals("Failed to mix in method.",
			"hello!", _.append("hello", "!"));
			
		assertEquals("Failed to use mixed-in method with wrapper.",
			"HELLO", _("hello").emphasize());
		assertEquals("Failed to use mixed-in method with wrapper.",
			"hello!", _("hello").append("!"));
		
		assertEquals("Failed to chain mixin methods.",
			"HELLO!", _("hello").chain().append("!").emphasize().value());
	}
}
}