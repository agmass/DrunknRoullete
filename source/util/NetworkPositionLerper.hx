package util;

import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxMath;

class NetworkPositionLerper
{
	public var desiredX = 0;
	public var desiredY = 0;
	public var enabled = false;
	public var parent:FlxSprite = null;

	public var travel = 0.0;

	public function new(parent:FlxSprite)
	{
		this.parent = parent;
	}

	public function update(elapsed:Float)
	{
		if (enabled)
		{
			travel += elapsed;
			if (travel < 1)
				travel = 1;
			parent.x = FlxMath.lerp(parent.x, desiredX, travel);
			parent.y = FlxMath.lerp(parent.y, desiredY, travel);
			if (parent is FlxNapeSprite)
			{
				var pfns:FlxNapeSprite = cast(parent);
				pfns.body.position.setxy(parent.x, parent.y);
			}
		}
	}
}