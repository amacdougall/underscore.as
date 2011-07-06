package {
// imports
import asunit.textui.TestRunner;
import com.alanmacdougall.underscore._;
import flash.display.MovieClip;
import test.com.alanmacdougall.underscore.*;

public class UnderscoreTestRunner extends TestRunner {
	/* INSTANCE VARIABLES */
	public function UnderscoreTestRunner() {
		start(UnderscoreTestSuite);
	}
}
}
