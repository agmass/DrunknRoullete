package projectiles;

import abilities.attributes.Attribute;
import abilities.equipment.items.SwordItem;
import entity.Entity;
import entity.EquippedEntity;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxPoint;
import sound.FootstepManager.MultiSoundManager;
import util.Projectile;

class BulletProjectile extends Projectile
{
	public var dropped = false;

	override public function new(x, y)
	{
		super(x, y, null, false, true);
		loadGraphic(AssetPaths.bullet__png);
		createRectangularBody();
		body.space = Main.napeSpace;
		setBodyMaterial(0.15, 0.3, 0.3, 4, 0.01);
	}

	override function onOverlapWithMap()
	{
		super.onOverlapWithMap();
		dropped = true;
	}

	var hitEntity = false;

	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
		{
			if (dropped)
			{
				returnToShooter = true;
			}
			return;
		}
		if (dropped)
		{
			return;
		}
		dropped = true;
		entity.health -= 15 * shooter.attributes.get(Attribute.ATTACK_DAMAGE).getValue();
		FlxG.camera.shake(0.001, 0.05);
		hitEntity = true;
		entity.velocity = velocity.scaleNew(shooter.attributes.get(Attribute.ATTACK_KNOCKBACK).getValue()).scalePoint(new FlxPoint(3, 1.5));
		super.onOverlapWithEntity(entity);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
	}
}