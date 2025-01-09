package util;

import entity.Entity;
import flixel.addons.nape.FlxNapeSprite;

class Projectile extends FlxNapeSprite
{
	public var shooter:Entity;
	public var destroyOnCollision = false;

	public function onOverlapWithEntity(entity:Entity) {}
}