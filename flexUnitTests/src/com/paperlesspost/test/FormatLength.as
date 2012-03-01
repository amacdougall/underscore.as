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
 * Test TextPosition.length.
 */
public class FormatLength {
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

		var legacyData:Object = {};
		legacyData.size = [
			{start:  0, end: -1, value: 11}, // alpha
			{start:  6, end: -1, value: 14}, // beta
			{start: 11, end: -1, value: 18}, // gamma
			{start: 17, end: -1, value: 24}  // delta
		];

		legacyData.font = [{start: 0, end: -1, value: "ATSackersGothicHeavy"}];
		legacyData.color = [{start: 0, end: -1, value: 0x000000}];
		legacyData.align = [{start: 0, end: -1, value: "center"}];
		legacyData.leading = [{start: 0, end: -1, value: 8}];
		legacyData.letterSpacing = [{start: 0, end: -1, value: 0}];

		legacyFormat = new TextPosition();
		legacyFormat.updateData(legacyData);
	}

	[Test]
	public function testFormatLength():void {
		Assert.assertEquals("Wrong format length.",
			22, format.length);
	}

	[Test]
	public function testLegacyFormatLength():void {
		Assert.assertEquals("Wrong legacy format length.",
			-1, legacyFormat.length);
	}

	[Test]
	public function testFormatIsNotIndefinite():void {
		Assert.assertFalse("Precise format was indefinite.", 
			format.isIndefinite);
	}

	[Test]
	public function testLegacyFormatIsIndefinite():void {
		Assert.assertTrue("Legacy format was not indefinite.",
			legacyFormat.isIndefinite);
	}

	[Test]
	public function testFormatLengthWithUnevenSpans():void {
		format.font[0].end += 1;
		Assert.assertEquals("Wrong format length with uneven span lengths.",
			23, format.length);
	}

	[Test]
	public function testLegacyFormatLengthWithUnevenSpans():void {
		legacyFormat.font[0].end = 22; // rest are -1, i.e. indefinite
		Assert.assertEquals("Wrong format length with uneven span lengths.",
			-1, legacyFormat.length);
	}

	[Test]
	public function testUnevenSpansCorrectedOnUpdate():void {
		var unevenData:Object;
		var unevenFormat:TextPosition;
		var property:String;
		var span:Object;

		unevenData = {};
		unevenData.size = [
			{start:  0, end: 6, value: 11}, // alpha
			{start:  6, end: 11, value: 14}, // beta
			{start: 11, end: 17, value: 18}, // gamma
			{start: 17, end: 22, value: 24}  // delta
		];

		unevenData.font = [{start: 0, end: 18, value: "ATSackersGothicHeavy"}];
		unevenData.color = [{start: 0, end: 14, value: 0x000000}];
		unevenData.align = [{start: 0, end: 1, value: "center"}];
		unevenData.leading = [{start: 0, end: 15, value: 8}];
		unevenData.letterSpacing = [{start: 0, end: 17, value: 0}];

		unevenFormat = new TextPosition();
		unevenFormat.updateData(unevenData);

		for each (property in formatProperties) {
			span = _(unevenFormat[property]).last();
			Assert.assertEquals("Uneven formats were not extended to max definite length.",
				22, span.end);
		}

		unevenData = {};
		unevenData.size = [
			{start:  0, end: -1, value: 11}, // alpha
			{start:  6, end: -1, value: 14}, // beta
			{start: 11, end: -1, value: 18}, // gamma
			{start: 17, end: -1, value: 24}  // delta
		];

		unevenData.font = [{start: 0, end: 18, value: "ATSackersGothicHeavy"}];
		unevenData.color = [{start: 0, end: 14, value: 0x000000}];
		unevenData.align = [{start: 0, end: 1, value: "center"}];
		unevenData.leading = [{start: 0, end: 15, value: 8}];
		unevenData.letterSpacing = [{start: 0, end: 17, value: 0}];

		unevenFormat = new TextPosition();
		unevenFormat.updateData(unevenData);

		for each (property in formatProperties) {
			span = _(unevenFormat[property]).last();
			Assert.assertEquals("Uneven formats were not extended to indefinite length.",
				-1, span.end);
		}
	}
}
}
