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
import objects.hitbox.FriendlyExplosionHitbox;
import sound.FootstepManager.MultiSoundManager;
import util.Projectile;

class FriendlyShellProjectile extends ShellProjectile
{
	override public function new(x, y)
	{
		super(x, y);
		color = FlxColor.BLUE.getLightened(0.4);
	}

	override function onOverlapWithMap()
	{
			FlxG.camera.shake(0.0025, 0.1);
			var explosion = new FriendlyExplosionHitbox(x - (196 / 2), y - (196 / 2), 0);
			explosion.damage = 0;
			returnToShooter = true;
		shooter.hitboxes.add(explosion);
	}

	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
			return;
		FlxG.camera.shake(0.005, 0.1);
		var explosion = new FriendlyExplosionHitbox(x - (196 / 2), y - (196 / 2), 0);
		returnToShooter = true;
		explosion.damage = 0;
		shooter.hitboxes.add(explosion);
	}
}