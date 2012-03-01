package com.paperlesspost.test {
// imports
import com.controul.utils.string.Patch;

import org.flexunit.Assert;
import org.flexunit.assertThat;
import org.hamcrest.collection.hasItems;
import org.hamcrest.number.greaterThan;


/**
 * Test text diff and patch functions.
 */
public class TextDiff {
	/* INSTANCE VARIABLES */
	protected var patch:Patch;
	protected var oldText:String;
	protected var newText:String;
	

	/* INSTANCE METHODS */
	[Before]
	public function setup():void {
		patch = new Patch();
	}

	[Test]
	public function testNoChangeGivesNullRanges():void {
		oldText = "alpha";
		newText = "alpha";
		patch.diff(oldText, newText, true);
		
		Assert.assertNull(patch.ranges.inserted);
		Assert.assertNull(patch.ranges.deleted);
	}

	[Test]
	public function testAllDeletedGivesNullInsertRange():void {
		oldText = "alpha";
		newText = "";
		patch.diff(oldText, newText, true);

		Assert.assertNull(patch.ranges.inserted);
	}

	[Test]
	public function testAllInsertedGivesNullDeleteRange():void {
		oldText = "";
		newText = "beta";
		patch.diff(oldText, newText, true);

		Assert.assertNull(patch.ranges.deleted);
	}

	/* Verify basic diff functions when deleting from end or beginning. When
	 * deleting from the center, the semantic alignment sometimes vaccuums up
	 * unaffected adjacent words, making testing difficult. The stray words are
	 * included in the add part of the diff as well, resulting in no change, so
	 * it's not something worth debugging.
	 */
	[Test]
	public function testDeleteFromStartDiff():void {
		oldText = "alpha beta";
		newText = "alpha";
		patch.diff(oldText, newText, true); // semantic alignment

		Assert.assertTrue("Generated wrong diff when deleting from end of string.",
			patch.string.indexOf("- beta") != -1);
	}

	[Test]
	public function testDeleteFromEndDiff():void {
		oldText = "alpha beta";
		newText = "beta";
		patch.diff(oldText, newText, true);
		Assert.assertTrue("Generated wrong diff when deleting from start of string.",
			patch.string.indexOf("-alpha ") != -1);
	}

	[Test]
	public function testDeleteFromStartDiffRange():void {
		oldText = "alpha beta";
		newText = "alpha";
		patch.diff(oldText, newText, true);

		Assert.assertEquals("Got wrong delete start index.",
			5, patch.ranges.deleted.start);
		Assert.assertEquals("Got wrong delete end index.",
			10, patch.ranges.deleted.end);
		Assert.assertNull("Got insert range when no insert occurred.",
			patch.ranges.inserted);
	}

	[Test]
	public function testDeleteFromEndDiffRange():void {
		oldText = "alpha beta";
		newText = "beta";
		patch.diff(oldText, newText, true);

		Assert.assertEquals("Got wrong delete start index.",
			0, patch.ranges.deleted.start);
		Assert.assertEquals("Got wrong delete end index.",
			6, patch.ranges.deleted.end);
		Assert.assertNull("Got insert range when no insert occurred.",
			patch.ranges.inserted);
	}

	[Test]
	public function testInsertAtEndDiff():void {
		oldText = "alpha";
		newText = "alpha beta";
		patch.diff(oldText, newText, true);

		Assert.assertTrue("Generated wrong diff when inserting at end of string.",
			patch.string.indexOf("+ beta") != -1);
	}

	[Test]
	public function testInsertAtStartDiff():void {
		oldText = "beta";
		newText = "alpha beta";
		patch.diff(oldText, newText, true);

		Assert.assertTrue("Generated wrong diff when inserting at start of string.",
			patch.string.indexOf("+alpha ") != -1);
	}

	[Test]
	public function testInsertAtStartDiffRange():void {
		oldText = "beta";
		newText = "alpha beta";
		patch.diff(oldText, newText, true);

		Assert.assertEquals("Got wrong insert start index.",
			0, patch.ranges.inserted.start);
		Assert.assertEquals("Got wrong insert end index.",
			6, patch.ranges.inserted.end);
		Assert.assertNull("Got delete range when no delete occurred.",
			patch.ranges.deleted);
	}

	[Test]
	public function testInsertAtEndDiffRange():void {
		oldText = "alpha";
		newText = "alpha beta";
		patch.diff(oldText, newText, true);

		Assert.assertEquals("Got wrong insert start index.",
			5, patch.ranges.inserted.start);
		Assert.assertEquals("Got wrong insert end index.",
			10, patch.ranges.inserted.end);
		Assert.assertNull("Got delete range when no delete occurred.",
			patch.ranges.deleted);
	}

	[Test]
	public function testApplyPatch():void {
		oldText = "alpha";
		newText = "alpha beta";
		patch.diff(oldText, newText, true);

		var patched:String = patch.patch(oldText);

		Assert.assertEquals("Applying patch did not change old text into new text.",
			newText, patched);
	}

	[Test]
	public function testApplyReversedPatch():void {
		oldText = "alpha";
		newText = "alpha beta";
		patch.diff(oldText, newText, true);

		patch.reversed = true;
		var patched:String = patch.patch(oldText);

		Assert.assertEquals("Applying reversed patch did not change new text into old text.",
			oldText, patched);
	}
}
}
