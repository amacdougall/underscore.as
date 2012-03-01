package com.paperlesspost.test
{
// imports


[Suite]
[RunWith("org.flexunit.runners.Suite")]	
public class TextEditSuite
{
	/* tests be run automagically */
	public var textDiff:TextDiff;
	public var formatLength:FormatLength;
	public var formatRange:FormatRange;
	public var formatCut:FormatCut;
	public var formatInsert:FormatInsert;
	public var formatCorrect:FormatCorrect;
}
}
