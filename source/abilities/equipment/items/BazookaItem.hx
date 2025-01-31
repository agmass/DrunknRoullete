package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.EquippedEntity;
import entity.PlayerEntity;
import entity.SmallRatEntity;
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
import projectiles.FriendlyShellProjectile;
import projectiles.ShellProjectile;
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

class BazookaItem extends Equipment
{
	public var bulletSpeed = 800;
	public var maxBullets = 1;
	public var altCooldown = 0.0;
	public var shootyAnimation = 0.0;
	public var bullets:FlxTypedSpriteGroup<ShellProjectile> = new FlxTypedSpriteGroup();

	override public function new(entity)
	{
		super(entity);
		weaponSpeed = 1;
		weaponScale = 2;
		loadGraphic(AssetPaths.bazooka__png);
	}

	override function alt_fire(player:EquippedEntity)
	{
		if (altCooldown > 0)
			return;
		altCooldown = 0.5;
		if (bullets.length >= maxBullets)
		{
			MultiSoundManager.playRandomSound(player, "out_of_ammo", FlxG.random.float(0.9, 1.1));
			return;
		}
		var bullet = new FriendlyShellProjectile(player.getMidpoint().x, player.getMidpoint().y);
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
		MultiSoundManager.playRandomSound(player, "shoot", FlxG.random.float(0.1, 0.25), 1);
		super.attack(player);
	}

	override function attack(player:EquippedEntity)
	{
		if (bullets.length >= maxBullets)
		{
			MultiSoundManager.playRandomSound(player, "out_of_ammo", FlxG.random.float(0.9, 1.1));
			return;
		}
		var bullet = new ShellProjectile(player.getMidpoint().x, player.getMidpoint().y);
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
		MultiSoundManager.playRandomSound(player, "shoot", FlxG.random.float(0.1, 0.25), 1);
		super.attack(player);
	}

	var lastShootSelf = 0.0;

	override function update(elapsed:Float)
	{
		altCooldown -= elapsed;
		shootyAnimation -= elapsed * (shootyAnimation * 6);
		for (projectile in bullets)
		{
			if (projectile.returnToShooter || !projectile.isOnScreen())
			{
				bullets.remove(projectile, true);
				projectile.destroy();
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

	override function draw()
	{
		bullets.draw();
		super.draw();
	}
}