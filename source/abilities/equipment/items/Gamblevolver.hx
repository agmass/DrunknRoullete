package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import nape.geom.Vec2;
import objects.hitbox.SweepHitbox;
import projectiles.BottleProjectile;
import projectiles.BulletProjectile;
import projectiles.CursedBulletProjectile;
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

class Gamblevolver extends Equipment
{
	public var bulletSpeed = 2400;
	public var maxBullets = 6;
	public var shootyAnimation = 0.0;
	public var bullets:FlxTypedSpriteGroup<BulletProjectile> = new FlxTypedSpriteGroup();

	override public function new(entity)
	{
		super(entity);
		weaponSpeed = 0.25;
		loadGraphic(AssetPaths.revolver__png);
	}

	override function alt_fire(player:EquippedEntity)
	{
		super.alt_fire(player);
	}

	override function attack(player:EquippedEntity)
	{
		if (bullets.length >= maxBullets)
		{
			MultiSoundManager.playRandomSound(player, "out_of_ammo", FlxG.random.float(0.9, 1.1));
			return;
		}
		var bullet = new BulletProjectile(player.getMidpoint().x, player.getMidpoint().y);
		if (FlxG.random.bool(20))
		{
			bullet = new CursedBulletProjectile(player.getMidpoint().x, player.getMidpoint().y);
		}
		bullet.shooter = player;
		bullet.y -= (bullet.height / 2);
		if (flipX)
		{
			bullet.x -= bullet.width;
			bullet.flipX = true;
		}
		shootyAnimation = 1.0;
		var vel = new FlxPoint(bulletSpeed, 0).rotateByDegrees(angle - 90);
		bullet.body.velocity = new Vec2(vel.x, vel.y);
		bullet.body.rotate(bullet.body.position, (angle + 90) * FlxAngle.TO_RAD);
		bullets.add(bullet);
		bullet.angle = angle;
		player.extraVelocity = vel.scaleNew(0.1).negate();
		player.collideables.add(bullet);
		var sound = FlxG.sound.play(AssetPaths.critswing__ogg);
		sound.pitch = 1.8;
		sound.volume = 0.45;
		FlxG.camera.shake(0.002, 0.1);
		MultiSoundManager.playRandomSound(player, "shoot", FlxG.random.float(0.5, 0.7), 1);
		super.attack(player);
	}

	override function update(elapsed:Float)
	{
		shootyAnimation -= elapsed * (shootyAnimation * 6);
		for (projectile in bullets)
		{
			if (projectile.returnToShooter)
			{
				projectile.body.position.setxy(-1000, -1000);
				projectile.destroy();
				wielder.collideables.remove(projectile);
				bullets.remove(projectile, true);
				projectile = null;
			}
		}
		bullets.update(elapsed);
		super.update(elapsed);
		if (flipX)
		{
			angle += FlxMath.lerp(0, 50, FlxMath.bound(shootyAnimation, 0, 1));
		}
		else
		{
			angle -= FlxMath.lerp(0, 50, FlxMath.bound(shootyAnimation, 0, 1));
		}
		offset.y = 6;
		offset.x = 0;
	}

	override function draw()
	{
		bullets.draw();
		super.draw();
	}
}