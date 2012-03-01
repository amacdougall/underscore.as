package com.paperlesspost.test {
// imports
import com.alanmacdougall.underscore._;
import com.paperlesspost.card.model.TextPosition;
import com.paperlesspost.utils.Debug;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;


/**
 * Test initializing TextPosition with invalid or obsolete data.
 */
public class FormatCorrect {
	/* INSTANCE VARIABLES */
	protected var format:TextPosition;

	/** Convenient list of all property names. Handy for iterating over all. */
	protected var formatProperties:Array = ["font", "size", "color", "align", "leading", "letterSpacing"];


	/* INSTANCE METHODS */
	[Before]
	public function setup():void {
		var data:Object = {
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

		format = new TextPosition();
		format.updateData(data); // simulate creating from JSON
	}

	/**
	 * An end value of -1 means that a format should be applied to the rest of
	 * the text field. Unless they occur at the end of the format, such values
	 * should be corrected to definite endpoints.
	 */
	[Test]
	public function testEndValuesAreCorrected():void {
		Assert.assertEquals("Indefinite end value was not clamped to start of subsequent span.",
			6, format.size[0].end);
		Assert.assertEquals("Indefinite end value for sole span was not left untouched.",
			-1, format.font[0].end);
		Assert.assertEquals("Indefinite end value at end of series was not left untouched.",
			-1, format.size[3].end);
	}

	[Test]
	public function testInvalidValuesAreCorrected():void {
		Assert.assertEquals("Empty format was not corrected to one full-length span.",
			0, format.align[0].start);
		Assert.assertEquals("Empty format was not corrected to one full-length span.",
			-1, format.align[0].end);
		Assert.assertEquals("Empty format was not corrected to one null-value span.",
			null, format.align[0].value);

		Assert.assertEquals("Null format was not corrected to one full-length span.",
			0, format.leading[0].start);
		Assert.assertEquals("Null format was not corrected to one full-length span.",
			-1, format.leading[0].end);
		Assert.assertEquals("Null format was not corrected to one null-value span.",
			null, format.leading[0].value);
	}
}
}
