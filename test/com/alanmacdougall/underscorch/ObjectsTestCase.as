package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestCase;
import com.alanmacdougall.underscore._;

public class ObjectsTestCase extends TestCase {

	public function ObjectsTestCase(testMethod:String) {
		super(testMethod);
	}
	
	public function testKeys():void {
		var hash:Object = {foo: "hi"};
		var list:Array = ["a"];
		
		assertEquals("Got incorrect keys list.", _(hash).keys()[0], "foo");
		hash.bar = "bye";
		assertEquals("Got incorrect number of keys.", _(hash).keys().length, 2);
		assertEquals("Got incorrect numeric keys.", _(list).keys()[0], 0);
		list = list.concat(["b"], ["c"]);
		assertEquals("Got incorrect number of numeric keys.", _(list).keys().length, 3);
	}
	
	public function testValues():void {
		var hash:Object = {foo: "hi", bar: "bye"};
		var list:Array = [1, 2, 3];
		var xml:XML = <root>
			<layer value="1"/>
			<layer value="2"/>
			<layer value="3"/>
		</root>;
		var xmlList:XMLList = xml.layer;
		
		assertTrue("Got wrong values for hash.",
			_(hash).chain().values().includes("hi").value());
		
		// list and XMLList have a guaranteed iteration order
		assertEquals("Got wrong values for list.",
			1, _(list).values()[0]);
		assertEquals("Got wrong values for XMLList.",
			"1", XML(_(xmlList).values()[0]).@value);
	}
	
	public function testFunctions():void {
		var action:Function = function() {};
		var message:String = "hi";
		
		var hash:Object = {
			foo: action,
			bar: message
		};
		
		assertEquals("Got incorrect function names.", _(hash).functions()[0], "foo");
		hash.baz = function() {};
		assertEquals("Got incorrect number of function names.", _(hash).functions().length, 2);
	}
	
	public function testExtend():void {
		var a:Object = {foo: "hello"};
		var b:Object = {bar: "goodbye"};
		var c:Object = {baz: "hello again"};
		
		_(a).extend(b, c);
		
		assertTrue("Failed to extend object.",
			"bar" in a && "baz" in a);
		assertEquals("Failed to extend object with correct values.",
			c.baz, a.baz);
	}
	
	public function testClone():void {
		var hash:Object = {
			foo: "hello",
			bar: "goodbye"
		};
		
		var hashClone:Object = _(hash).clone();
		assertEquals("Failed to clone hash.",
			hash.foo, hashClone.foo);
			
		var list:Array = [1, 2, 3, 4];
		var listCopy:Array = _(list).clone();
		assertEquals("Failed to clone array.",
			list[2], listCopy[2]);
	}
	
	public function testTap():void {
		var log:String = "";
		var interceptor:Function = function(obj:*):void {
			log += "entry: " + obj;
		};
		var returned:Object = _.tap("hello", interceptor);
		assertEquals("Did not pass tapped object to interceptor.",
			"entry: hello", log);
		assertEquals("Did not return tapped object.",
			"hello", returned);
		
		log = "";
		
		returned = _([1,2,3]).chain()
			.map(function(n:int):int {return n * 2;})
			.max()
			.tap(interceptor)
			.value();
		
		assertEquals("Did not pass tapped object to interceptor in chain.",
			"entry: 6", log);
		assertEquals("Did not return tapped object in chain.",
			6, returned);
	}
}
}