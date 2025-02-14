package ui;

import flixel.FlxG;
import flixel.addons.ui.FlxUICheckBox;

class SavedUICheckBox extends FlxUICheckBox
{
	var saveField:String;

	override public function new(X:Float = 0, Y:Float = 0, ?Box:Dynamic, ?Check:Dynamic, ?Label:String, ?LabelW:Int = 100, saveField:String)
	{
		super(X, Y, Box, Check, Label, LabelW);
		this.saveField = saveField;
		checked = Reflect.field(FlxG.save.data, saveField);
	}

	override function update(elapsed:Float)
	{
		Reflect.setField(FlxG.save.data, saveField, checked);
		super.update(elapsed);
	}
}