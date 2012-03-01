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
 * Test TextPosition.range().
 */
public class FormatRange {
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
	public function testZeroWidthRange():void {
		var fragment:TextPosition = format.range(0, 0);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Zero-width range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Zero-width range had more than one-character-wide span for " + property,
				1, fragment[property][0].end - fragment[property][0].start);
		}
	}

	[Test]
	public function testLegacyZeroWidthRange():void {
		var fragment:TextPosition = legacyFormat.range(0, 0);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Zero-width range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Zero-width range had more than one-character-wide span for " + property,
				1, fragment[property][0].end - fragment[property][0].start);
		}
	}

	[Test]
	public function testSingleSpanRange():void {
		var fragment:TextPosition = format.range(0, 6);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Span was wrong width for " + property,
				6, fragment[property][0].end - fragment[property][0].start);
		}
	}

	[Test]
	public function testLegacySingleSpanRange():void {
		var fragment:TextPosition = legacyFormat.range(0, 6);

		for each (var property:String in formatProperties) {
			Assert.assertNotNull("No spans found for " + property,
				fragment[property]);
			Assert.assertEquals("Range had more than one span for " + property,
				1, fragment[property].length);
			Assert.assertEquals("Span was wrong width for " + property,
				6, fragment[property][0].end - fragment[property][0].start);
		}
	}

	/* From this point on, consider only the complex "size" property. */
	[Test]
	public function testTwoSpanRange():void {
		var fragment:TextPosition = format.range(0, 11);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Range had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Range had wrong total span length.",
			11, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Range had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));
	}

	[Test]
	public function testLegacyTwoSpanRange():void {
		var fragment:TextPosition = legacyFormat.range(0, 11);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Range had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Range had wrong total span length.",
			11, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Range had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));
	}

	[Test]
	public function testPartialSpanRange():void {
		var fragment:TextPosition = format.range(0, 5);

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
	}

	public function testLegacyPartialSpanRange():void {
		var fragment:TextPosition = legacyFormat.range(0, 5);

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
	}

	[Test]
	public function testPartialTwoSpanRange():void {
		var fragment:TextPosition = format.range(1, 10);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Range had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Range had wrong total span length.",
			9, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Range had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));
	}

	[Test]
	public function testLegacyPartialTwoSpanRange():void {
		var fragment:TextPosition = legacyFormat.range(1, 10);

		Assert.assertNotNull("No spans found for size property.",
			fragment.size);
		Assert.assertEquals("Range had wrong number of spans.",
			2, fragment.size.length);
		Assert.assertEquals("Range had wrong total span length.",
			9, _(fragment.size).reduce(sumSpanLengths, 0));
		assertThat("Range had wrong span values.",
			_(fragment.size).pluck("value"), hasItems(11, 14));
	}

	[Test(expects="RangeError")]
	public function testOutOfRange():void {
		var fragment:TextPosition = format.range(0, 1000);
	}

	[Test]
	public function testLegacyOutOfRange():void {
		var fragment:TextPosition = legacyFormat.range(0, 1000);
		Assert.assertEquals("Range taken from indefinite format was as long as requested.",
			1000, fragment.length);
	}

	/* utility */
	/** For use with _.reduce: sums up span lengths (i.e. end - start). */
	protected function sumSpanLengths(accumulator:int, span:Object):int {
		return accumulator + span.end - span.start;
	}
}
}
