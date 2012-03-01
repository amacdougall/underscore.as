package com.paperlesspost.test {
// imports
import com.alanmacdougall.underscore._;
import com.controul.utils.string.Patch;
import com.paperlesspost.card.model.TextPosition;
import com.paperlesspost.utils.Debug;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;


/**
 * Test TextPosition.cut().
 */
public class FormatCut {
	/* INSTANCE VARIABLES */
	protected var format:TextPosition;
	protected var legacyFormat:TextPosition;

	/** Convenient list of all property names. Handy for iterating over all. */
	protected var formatProperties:Array = ["font", "size", "color", "align", "leading", "letterSpacing"];


	/* INSTANCE METHODS */
	[Before]
	public function setup():void {
		format = new TextPosition();
		format.size = [
			{start:  0, end:  6, value: 11}, // alpha
			{start:  6, end: 11, value: 14}, // beta
			{start: 11, end: 17, value: 18}, // gamma
			{start: 17, end: 22, value: 24}  // delta
		];

		format.font = [{start: 0, end: 22, value: "ATSackersGothicHeavy"}];
		format.color = [{start: 0, end: 22, value: 0x000000}];
		format.align = [{start: 0, end: 22, value: "center"}];
		format.leading = [{start: 0, end: 22, value: 8}];
		format.letterSpacing = [{start: 0, end: 22, value: 0}];

		var legacyData:Object = {
			size: [
				{start:  0, end: -1, value: 11}, // alpha
				{start:  6, end: -1, value: 14}, // beta
				{start: 11, end: -1, value: 18}, // gamma
				{start: 17, end: -1, value: 24}  // delta
			],

			font: [{start: 0, end: -1, value: "ATSackersGothicHeavy"}],
			color: [{start: 0, end: -1, value: 0x000000}],
			align: [],
			leading: null,
			letterSpacing: [{start: 0, end: -1, value: 0}]
		};

		legacyFormat = new TextPosition();
		legacyFormat.updateData(legacyData);
	}

	[Test]
	public function testZeroWidthCut():void {
		var startingLength:int = format.length;
		var fragment:TextPosition = format.cut(0, 0);

		Assert.assertNull(fragment);
		Assert.assertEquals("Zero-width cut altered format length.",
			startingLength, format.length);
	}

	[Test]
	public function testLegacyZeroWidthCut():void {
		var startingLength:int = legacyFormat.length;
		var fragment:TextPosition = legacyFormat.cut(0, 0);

		Assert.assertNull(fragment);
		Assert.assertEquals("Zero-width cut altered format length.",
			startingLength, legacyFormat.length);
	}

	[Test]
	public function testSingleSpanCut():void {
		var fragment:TextPosition = format.cut(0, 6);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Span was wrong width for " + property,
				6, fragment[property][0].end - fragment[property][0].start);
		}

		Assert.assertEquals("Format had wrong number of spans after cut.",
			3, format.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(format.size).pluck("start"), hasItems(0, 5, 11));
		assertThat("Format spans had wrong end points after cut.",
			_(format.size).pluck("end"), hasItems(5, 11, 16)); 
		assertThat("Format spans had wrong values after cut.",
			_(format.size).pluck("value"), hasItems(14, 18, 24));
	}

	[Test]
	public function testLegacySingleSpanCut():void {
		var fragment:TextPosition = legacyFormat.cut(0, 6);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Span was wrong width for " + property,
				6, fragment[property][0].end - fragment[property][0].start);
		}

		Assert.assertEquals("Format had wrong number of spans after cut.",
			3, legacyFormat.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(legacyFormat.size).pluck("start"), hasItems(0, 5, 11));
		assertThat("Format spans had wrong end points after cut.",
			_(legacyFormat.size).pluck("end"), hasItems(5, 11, -1)); 
		assertThat("Format spans had wrong values after cut.",
			_(legacyFormat.size).pluck("value"), hasItems(14, 18, 24));
	}

	/* From this point on, consider only the complex "size" property. */
	[Test]
	public function testTwoSpanCut():void {
		var fragment:TextPosition = format.cut(0, 11);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Cut fragment had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Cut fragment had wrong total span length.",
			11, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Cut fragment had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));

		Assert.assertEquals("Format had wrong number of spans after cut.",
			2, format.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(format.size).pluck("start"), hasItems(0, 6));
		assertThat("Format spans had wrong end points after cut.",
			_(format.size).pluck("end"), hasItems(6, 11)); 

		assertThat("Format had wrong values after cut.",
			_(format.size).pluck("value"), hasItems(18, 24));
	}

	[Test]
	public function testLegacyTwoSpanCut():void {
		var fragment:TextPosition = legacyFormat.cut(0, 11);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Cut fragment had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Cut fragment had wrong total span length.",
			11, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Cut fragment had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));

		Assert.assertEquals("Format had wrong number of spans after cut.",
			2, legacyFormat.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(legacyFormat.size).pluck("start"), hasItems(0, 6));
		assertThat("Format spans had wrong end points after cut.",
			_(legacyFormat.size).pluck("end"), hasItems(6, -1)); 

		assertThat("Format had wrong values after cut.",
			_(legacyFormat.size).pluck("value"), hasItems(18, 24));
	}

	[Test]
	public function testPartialSpanCut():void {
		var fragment:TextPosition = format.cut(0, 5);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Range had wrong span value.",
				format[property][0].value, fragment[property][0].value);
			Assert.assertEquals("Span was wrong width for " + property,
				5, fragment[property][0].end - fragment[property][0].start);
		}

		Assert.assertEquals("Format had wrong number of spans after cut.",
			4, format.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(format.size).pluck("start"), hasItems(0, 1, 6, 12));
		assertThat("Format spans had wrong end points after cut.",
			_(format.size).pluck("end"), hasItems(1, 6, 12, 17)); 

		assertThat("Format had wrong values after cut.",
			_(format.size).pluck("value"), hasItems(11, 14, 18, 24));
	}

	[Test]
	public function testLegacyPartialSpanCut():void {
		var fragment:TextPosition = legacyFormat.cut(0, 5);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Range had wrong span value.",
				legacyFormat[property][0].value, fragment[property][0].value);
			Assert.assertEquals("Span was wrong width for " + property,
				5, fragment[property][0].end - fragment[property][0].start);
		}

		Assert.assertEquals("Format had wrong number of spans after cut.",
			4, legacyFormat.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(legacyFormat.size).pluck("start"), hasItems(0, 1, 6, 12));
		assertThat("Format spans had wrong end points after cut.",
			_(legacyFormat.size).pluck("end"), hasItems(1, 6, 12, -1)); 

		assertThat("Format had wrong values after cut.",
			_(legacyFormat.size).pluck("value"), hasItems(11, 14, 18, 24));
	}

	[Test]
	public function testPartialTwoSpanCut():void {
		var fragment:TextPosition = format.cut(1, 10);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Range had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Range had wrong total span length.",
			9, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Range had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));

		Assert.assertEquals("Format had wrong number of spans after cut.",
			4, format.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(format.size).pluck("start"), hasItems(0, 1, 2, 8));
		assertThat("Format spans had wrong end points after cut.",
			_(format.size).pluck("end"), hasItems(1, 2, 8, 13)); 

		assertThat("Format had wrong values after cut.",
			_(format.size).pluck("value"), hasItems(11, 14, 18, 24));
	}

	[Test]
	public function testLegacyPartialTwoSpanCut():void {
		var fragment:TextPosition = legacyFormat.cut(1, 10);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Range had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Range had wrong total span length.",
			9, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Range had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));

		Assert.assertEquals("Format had wrong number of spans after cut.",
			4, legacyFormat.size.length);

		assertThat("Format spans had wrong start points after cut.",
			_(legacyFormat.size).pluck("start"), hasItems(0, 1, 2, 8));
		assertThat("Format spans had wrong end points after cut.",
			_(legacyFormat.size).pluck("end"), hasItems(1, 2, 8, -1)); 
		assertThat("Format had wrong values after cut.",
			_(legacyFormat.size).pluck("value"), hasItems(11, 14, 18, 24));
	}

	[Test]
	public function testCutMergesAdjacentValues():void {
		// deleting the middle span should merge the two others
		format.color = [
			{start: 0, end: 10, value: 0x000000},
			{start: 10, end: 20, value: 0xffffff},
			{start: 20, end: 22, value: 0x000000}
		];
		var fragment:TextPosition = format.cut(10, 20);

		Assert.assertEquals("Adjacent identical formats were not merged.",
			1, format.color.length);
		Assert.assertEquals("Merged span was not correct length.",
			12, format.length);
		Assert.assertEquals("Merged span did not have the correct value.",
			0x000000, format.color[0].value);
	}

	[Test]
	public function testLegacyCutMergesAdjacentValues():void {
		// deleting the middle span should merge the two others
		legacyFormat.color = [
			{start: 0, end: 10, value: 0x000000},
			{start: 10, end: 20, value: 0xffffff},
			{start: 20, end: -1, value: 0x000000}
		];
		var fragment:TextPosition = legacyFormat.cut(10, 20);

		Assert.assertEquals("Adjacent identical formats were not merged.",
			1, legacyFormat.color.length);
		Assert.assertEquals("Last merged span did not have correct end value.",
			-1, _(legacyFormat.color).last().end);
		Assert.assertEquals("Merged span was not correct length.",
			-1, legacyFormat.length);
		Assert.assertEquals("Merged span did not have the correct value.",
			0x000000, legacyFormat.color[0].value);
	}

	[Test(expects="RangeError")]
	public function testOutOfRangeCut():void {
		var fragment:TextPosition = format.cut(0, 1000);
	}

	[Test]
	public function testLegacyOutOfRangeCut():void {
		var fragment:TextPosition = legacyFormat.cut(0, 1000);
		Assert.assertEquals("Cut taken from indefinite format was as long as requested.",
			1000, fragment.length);
	}

	/* utility */
	/** For use with _.reduce: sums up span lengths (i.e. end - start). */
	protected function sumSpanLengths(accumulator:int, span:Object):int {
		return accumulator + span.end - span.start;
	}
}
}
