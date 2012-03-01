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
 * Test TextPosition.insert().
 */
public class FormatInsert {
	/* INSTANCE VARIABLES */
	protected var format:TextPosition;
	protected var fragment:TextPosition;

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
	}

	/** Tests "extending" a span by inserting one with an identical format. */
	[Test]
	public function testMergeAtStart():void {
		fragment = format.range(0, 1);

		format.insert(fragment, 0);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			4, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			7, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);
	}

	/** Tests extending a span by inserting into the middle of it. */
	[Test]
	public function testMergeInMiddle():void {
		fragment = format.range(0, 1);

		format.insert(fragment, 1);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			4, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			7, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);
	}

	[Test]
	/** Tests extending a span by inserting at the end. */
	public function testMergeAtEnd():void {
		fragment = format.range(0, 1);
		fragment.size[0].value = 24; // same as last span

		format.insert(fragment, format.length);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			4, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			6, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);

		span = format.size[3];
		Assert.assertEquals("Last span had wrong start after insert.",
			17, span.start);
		Assert.assertEquals("Last span had wrong end after insert.",
			23, span.end);
		Assert.assertEquals("Last span had wrong value after insert.",
			24, span.value);
	}

	[Test]
	public function testInsertAtStart():void {
		fragment = format.range(0, 1);
		fragment.size[0].value = 8;

		format.insert(fragment, 0);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			5, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			1, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			8, span.value);

		span = format.size[1];
		Assert.assertEquals("Second span had wrong start after insert.",
			1, span.start);
		Assert.assertEquals("Second span had wrong end after insert.",
			7, span.end);
		Assert.assertEquals("Second span had wrong value after insert.",
			11, span.value);
	}

	[Test]
	public function testInsertInMiddle():void {
		fragment = format.range(0, 1);
		fragment.size[0].value = 8;

		format.insert(fragment, 1);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			6, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			1, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);

		span = format.size[1];
		Assert.assertEquals("Second span had wrong start after insert.",
			1, span.start);
		Assert.assertEquals("Second span had wrong end after insert.",
			2, span.end);
		Assert.assertEquals("Second span had wrong value after insert.",
			8, span.value);

		span = format.size[2];
		Assert.assertEquals("Third span had wrong start after insert.",
			2, span.start);
		Assert.assertEquals("Third span had wrong end after insert.",
			7, span.end);
		Assert.assertEquals("Third span had wrong value after insert.",
			11, span.value);

		span = format.size[3];
		Assert.assertEquals("Fourth span had wrong start after insert.",
			7, span.start);
		Assert.assertEquals("Fourth span had wrong end after insert.",
			12, span.end);
		Assert.assertEquals("Fourth span had wrong value after insert.",
			14, span.value);
	}

	[Test]
	public function testInsertAtEnd():void {
		fragment = format.range(0, 1);
		fragment.size[0].value = 8;

		format.insert(fragment, format.length);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			5, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			6, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);

		span = format.size[format.size.length - 1];
		Assert.assertEquals("Last span had wrong start after insert.",
			22, span.start);
		Assert.assertEquals("Last span had wrong end after insert.",
			23, span.end);
		Assert.assertEquals("Last span had wrong value after insert.",
			8, span.value);
	}

	/**
	 * Tests inserting between spans with a value identical to that of the
	 * preceding span, forcing a merge.
	 */
	[Test]
	public function testMergeWithPreviousAtSeam():void {
		fragment = format.range(0, 1);

		format.insert(fragment, format.size[1].start);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			4, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			7, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);
	}

	/**
	 * Tests inserting between spans with a value identical to that of the
	 * following span, forcing a merge.
	 */
	[Test]
	public function testMergeWithNextAtSeam():void {
		fragment = format.range(0, 1);
		fragment.size[0].value = 14;

		format.insert(fragment, format.size[1].start);

		Assert.assertEquals("Format was wrong length after insert.",
			23, format.length);
		Assert.assertEquals("Size property had wrong number of spans after insert.",
			4, format.size.length);

		var span:Object = format.size[0];
		Assert.assertEquals("First span had wrong start after insert.",
			0, span.start);
		Assert.assertEquals("First span had wrong end after insert.",
			6, span.end);
		Assert.assertEquals("First span had wrong value after insert.",
			11, span.value);

		span = format.size[1];
		Assert.assertEquals("Second span had wrong start after insert.",
			6, span.start);
		Assert.assertEquals("Second span had wrong end after insert.",
			12, span.end);
		Assert.assertEquals("Second span had wrong value after insert.",
			14, span.value);
	}

	/* utility */
	/** For use with _.reduce: sums up span lengths (i.e. end - start). */
	protected function sumSpanLengths(accumulator:int, span:Object):int {
		return accumulator + span.end - span.start;
	}
}
}
