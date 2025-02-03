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
	public var hitEntities = [];
	public var dropTime = 0.25;

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
		dropTime -= 0.5;
		super.onOverlapWithMap();
	}

	var hitEntity = false;

	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
		{
			if (dropTime <= 0.0 && !returnToShooter)
			{
				MultiSoundManager.playRandomSound(entity, "pickup_bullet", Main.randomProvider.float(0.9, 1.2));
				returnToShooter = true;
			}
			return;
		}
		if (hitEntities.contains(entity.ID))
		{
			return;
		}
		if (dropTime <= -3.5)
		{
			return;
		}
		hitEntities.push(entity.ID);
		entity.damage(12, shooter);
		FlxG.camera.shake(0.001, 0.05);
		hitEntity = true;
		entity.velocity = velocity.scaleNew(shooter.attributes.get(Attribute.ATTACK_KNOCKBACK).getValue()).scalePoint(new FlxPoint(3, 1.5));
		super.onOverlapWithEntity(entity);
	}


	override function update(elapsed:Float)
	{
		if (!inWorldBounds())
		{
			returnToShooter = true;
		}
		dropTime -= elapsed;
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
	}
}