package projectiles;

import abilities.attributes.Attribute;
import abilities.equipment.items.SwordItem;
import entity.Entity;
import entity.EquippedEntity;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import objects.hitbox.ExplosionHitbox;
import sound.FootstepManager.MultiSoundManager;
import util.Projectile;

class ShellProjectile extends Projectile
{
	override public function new(x, y)
	{
		super(x, y, null, false, true);
		loadGraphic(AssetPaths.ball__png);
		scale.set(3, 3);
		updateHitbox();
		this.y = y - 30;
		color = FlxColor.GRAY;
		createRectangularBody();
		body.space = Main.napeSpace;
		setBodyMaterial(0.15, 0.3, 0.3, 4, 0.01);
	}

	override function onOverlapWithMap()
	{
		FlxG.camera.shake(0.005, 0.1);
		var explosion = new ExplosionHitbox(x - (196 / 2), y - (196 / 2), 0);
		returnToShooter = true;
		shooter.hitboxes.add(explosion);
		super.onOverlapWithMap();
	}

	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
			return;
		entity.damage(24, shooter);
		FlxG.camera.shake(0.005, 0.1);
		var explosion = new ExplosionHitbox(x - (196 / 2), y - (196 / 2), 0);
		returnToShooter = true;
		shooter.hitboxes.add(explosion);
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