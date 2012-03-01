package {
// imports
import mx.core.Application;

import org.flexunit.listeners.UIListener;
import org.flexunit.internals.TraceListener;
import org.flexunit.runner.FlexUnitCore;
// import org.flexunit.runner.Request;
// import org.flexunit.runner.notification.async.XMLListener;

import test.com.alanmacdougall.underscore.*;


/** Code-behind for TestContainer.mxml. */
public class TestContainerBase extends Application {
	/* INSTANCE VARIABLES */
	// child objects
	public var uiListener:*;

	private var core:FlexUnitCore;

	/* INSTANCE METHODS */
	public function init():void {
		core = new FlexUnitCore();

		// Listener for outputting to the trace console via the trace method, ActionScript or Flex
		core.addListener(new TraceListener());

		// Listener for the UI
		core.addListener(new UIListener(uiListener));
		
		core.run(UnderscoreSuite);
		// core.run(FormatLength);
		
		// EXAMPLE CODE:
		// The run method can take a single class or suite
		// core.run( FrameworkSuite ); or core.run( TestAssert );

		// It can take a request, which allows you to selected specific tests
		// core.run( Request.method( TestTwo, "testTwo3" ) );
		
		// It can take a comma separated list of the previous choices
		// core.run( FrameworkSuite, TestAssert, Request.method( TestAssert, "testFail" ) );
		
		// It can take an array
		// var ar:Array = new Array();
		// ar.push( Request.method( TestAssert, "testFail" ) );
		// ar.push( FrameworkSuite );
		// core.run( ar );

		// Or a combination of any of the above
		// var ar:Array = new Array();
		// ar.push( Request.method( TestAssert, "testFail" ) );
		// ar.push( FrameworkSuite );
		// core.run( FrameworkSuite, ar, TestAssert  );

		// The only really important thing is that you pass them all at once. You don't want to call core.run() more than once at this time
	}
}
}
