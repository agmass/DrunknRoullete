package objects;

import flixel.FlxSprite;

class SpriteToInteract extends FootstepChangingSprite
{
	public var showTip = false;
	public var tooltipSprite:FlxSprite = new FlxSprite(0, 0, AssetPaths.interactTip__png);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (showTip)
		{
			tooltipSprite.alpha += elapsed * 3;
		}
		else
		{
			tooltipSprite.alpha -= elapsed * 3;
		}
		tooltipSprite.x = getGraphicMidpoint().x - (tooltipSprite.width / 2);
		tooltipSprite.y = getGraphicBounds().y - tooltipSprite.height - 20;
	}

	override function draw()
	{
		super.draw();
		tooltipSprite.draw();
	}
}