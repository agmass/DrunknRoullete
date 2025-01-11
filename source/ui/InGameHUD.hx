package ui;

import flixel.FlxSprite;
import flixel.text.FlxText;

class InGameHUD extends FlxSprite
{
	public var token:FlxSprite = new FlxSprite(0, 0, AssetPaths.token__png);
	public var amountText:FlxText = new FlxText(0, 0, 0, "0", 24);

	override public function new()
	{
		super(0, 0);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		token.x = 20;
		token.y = 20;
		token.scale.set(2, 2);
		amountText.x = 45;
		amountText.y = 15;
	}

	override function draw()
	{
		token.draw();
		amountText.draw();
	}
}