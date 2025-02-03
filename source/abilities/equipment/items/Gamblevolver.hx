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
	var shootSelf = 0.0;

	override public function new(entity)
	{
		super(entity);
		weaponSpeed = 0.25;
		loadGraphic(AssetPaths.revolver__png);
	}	

	override function alt_fire(player:EquippedEntity)
	{
		shootSelf = 3.0;
		super.alt_fire(player);
	}

	override function attack(player:EquippedEntity)
	{
		if (shootSelf > 0)
			return;
		if (bullets.length >= maxBullets)
		{
			MultiSoundManager.playRandomSound(player, "out_of_ammo", Main.randomProvider.float(0.9, 1.1));
			return;
		}
		var bullet = new BulletProjectile(player.getMidpoint().x, player.getMidpoint().y);
		if (Main.randomProvider.bool(20))
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
		MultiSoundManager.playRandomSound(player, "shoot", Main.randomProvider.float(0.5, 0.7), 1);
		super.attack(player);
	}

	var lastShootSelf = 0.0;

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
		shootSelf -= elapsed * 3;
		if (shootSelf <= 0)
		{
			if (flipX)
			{
				angle += FlxMath.lerp(0, 50, FlxMath.bound(shootyAnimation, 0, 1));
			}
			else
			{
				angle -= FlxMath.lerp(0, 50, FlxMath.bound(shootyAnimation, 0, 1));
			}
		}
		else
		{
			if (shootSelf >= 1.5)
			{
				angle = FlxMath.lerp(0, angle, 1 - easeOutBounce(1 - ((shootSelf - 1.5) / 1.5)));
			}
			else
			{
				if (lastShootSelf >= 1.5)
				{
					CursedBulletProjectile.roll(wielder, wielder);
					wielder.damage(5, wielder);
				}
				angle = FlxMath.lerp(angle, 0, 1 - easeOutSine(1 - (shootSelf / 1.5)));
			}
		}
		lastShootSelf = shootSelf;
		if (equipped)
		{
			offset.y = wielder.holdY + Math.sin(idleSwing);
			offset.x = wielder.holdX;
		}
		else
		{
			offset.y = 6;
			offset.x = 0;
		}
	}
	function easeOutSine(x:Float)
	{
		return Math.sin((x * Math.PI) / 2);
	}

	function easeOutBounce(x:Float)
	{
		var n1 = 7.5625;
		var d1 = 2.75;

		if (x < 1 / d1)
		{
			return n1 * x * x;
		}
		else if (x < 2 / d1)
		{
			return n1 * (x -= 1.5 / d1) * x + 0.75;
		}
		else if (x < 2.5 / d1)
		{
			return n1 * (x -= 2.25 / d1) * x + 0.9375;
		}
		else
		{
			return n1 * (x -= 2.625 / d1) * x + 0.984375;
		}
	}

	override function draw()
	{
		bullets.draw();
		super.draw();
	}
}