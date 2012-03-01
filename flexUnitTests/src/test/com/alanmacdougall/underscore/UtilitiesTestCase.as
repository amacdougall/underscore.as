package test.com.alanmacdougall.underscore {
// imports
import com.alanmacdougall.underscore._;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;


/**
 * Test underscore.as utility methods.
 */
public class UtilitiesTestCase {
	[Test]
	public function testTimes():void {
		var n:int = 5;
		_(5).times(function():void {n++;});
		Assert.assertEquals("Failed to execute function multiple times.",
			10, n);
		
		var counter:int = 0;
		_(5).times(function(i:int):void {
			counter = i;
		});
		Assert.assertEquals("Failed to take loop counter as an argument.",
			4, counter);
	}

	[Test]
	public function testMixin():void {
		_.mixin({
			emphasize: function(input:String):String {
				return input.toUpperCase();
			},
			append: function(input:String, suffix:String):String {
				return input + suffix;
			}
		});
		
		Assert.assertEquals("Failed to mix in method.",
			"HELLO", _.emphasize("hello"));
		Assert.assertEquals("Failed to mix in method.",
			"hello!", _.append("hello", "!"));
			
		Assert.assertEquals("Failed to use mixed-in method with wrapper.",
			"HELLO", _("hello").emphasize());
		Assert.assertEquals("Failed to use mixed-in method with wrapper.",
			"hello!", _("hello").append("!"));
		
		Assert.assertEquals("Failed to chain mixin methods.",
			"HELLO!", _("hello").chain().append("!").emphasize().value());
	}
}
}
