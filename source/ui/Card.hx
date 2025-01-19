package ui;

import flixel.FlxSprite;

class Card extends FlxSprite
{
	public var desiredX = 0.0;
	public var desiredY = 0.0;
	public var selected = true;

	override public function new()
	{
		super();
		loadGraphic(AssetPaths.attribute_bg__png);
	}
}