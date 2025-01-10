package util;

import entity.Entity;
import flixel.addons.nape.FlxNapeSprite;

class Projectile extends FlxNapeSprite
{
	public var shooter:Entity;
	public var returnToShooter = false;

	override public function new(x, y, a, c, e)
	{
		super(x, y, a, c, e);
	}

	public function onOverlapWithEntity(entity:Entity) {}
	public function onOverlapWithMap() {}
}