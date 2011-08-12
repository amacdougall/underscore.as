package test.com.alanmacdougall.underscore {
// imports
import asunit.framework.TestSuite;

public class UnderscoreTestSuite extends TestSuite {
	public function UnderscoreTestSuite() {
		super();
		
		addTest(new CollectionsTestCase("testEach_Array"));
		addTest(new CollectionsTestCase("testEach_VariableIteratorArguments"));
		addTest(new CollectionsTestCase("testEach_Object"));
		addTest(new CollectionsTestCase("testEach_XMLList"));
		addTest(new CollectionsTestCase("testEach_Context"));
		addTest(new CollectionsTestCase("testMap"));
		addTest(new CollectionsTestCase("testReduce"));
		addTest(new CollectionsTestCase("testReduce_NullMemo"));
		addTest(new CollectionsTestCase("testDetect"));
		addTest(new CollectionsTestCase("testFilter"));
		addTest(new CollectionsTestCase("testReject"));
		addTest(new CollectionsTestCase("testAny"));
		addTest(new CollectionsTestCase("testAll"));
		addTest(new CollectionsTestCase("testIncludes"));
		addTest(new CollectionsTestCase("testInvoke"));
		addTest(new CollectionsTestCase("testPluck"));
		addTest(new CollectionsTestCase("testMax"));
		addTest(new CollectionsTestCase("testMin"));
		addTest(new CollectionsTestCase("testSortBy"));
		addTest(new CollectionsTestCase("testSortedIndex"));
		addTest(new CollectionsTestCase("testToArray"));
		addTest(new CollectionsTestCase("testSize"));
		addTest(new CollectionsTestCase("testIsEmpty"));
		
		addTest(new ArraysTestCase("testFirst"));
		addTest(new ArraysTestCase("testRest"));
		addTest(new ArraysTestCase("testCompact"));
		addTest(new ArraysTestCase("testFlatten"));
		addTest(new ArraysTestCase("testWithout"));
		addTest(new ArraysTestCase("testUnique"));
		addTest(new ArraysTestCase("testIntersect"));
		addTest(new ArraysTestCase("testZip"));
		addTest(new ArraysTestCase("testRange"));
		
		addTest(new FunctionsTestCase("testBind"));
		addTest(new FunctionsTestCase("testBindAll"));
		addTest(new FunctionsTestCase("testBindAll_Selected"));
		addTest(new FunctionsTestCase("testMemoize"));
		addTest(new FunctionsTestCase("testDelay"));
		addTest(new FunctionsTestCase("testThrottle"));
		addTest(new FunctionsTestCase("testThrottle_Args"));
		addTest(new FunctionsTestCase("testDebounce"));
		addTest(new FunctionsTestCase("testDebounce_Args"));
		addTest(new FunctionsTestCase("testChoke"));
		addTest(new FunctionsTestCase("testChoke_Args"));
		addTest(new FunctionsTestCase("testWrap"));
		addTest(new FunctionsTestCase("testCompose"));
		
		addTest(new ObjectsTestCase("testKeys"));
		addTest(new ObjectsTestCase("testValues"));
		addTest(new ObjectsTestCase("testFunctions"));
		addTest(new ObjectsTestCase("testExtend"));
		addTest(new ObjectsTestCase("testClone"));
		addTest(new ObjectsTestCase("testTap"));
		
		addTest(new UtilitiesTestCase("testTimes"));
		addTest(new UtilitiesTestCase("testMixin"));
		
		addTest(new ChainingTestCase("testWrapper"));
		addTest(new ChainingTestCase("testWrapperChain"));

		addTest(new MixinTestCase("testChokeDebounce"));
		addTest(new MixinTestCase("testChokeDebounce_Args"));
	}
}
}
