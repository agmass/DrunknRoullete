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
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

class RatGun extends Equipment
{
	public var bulletSpeed = 2400;
	public var maxBullets = 10;
	public var shootyAnimation = 0.0;
	public var bullets:FlxTypedSpriteGroup<SmallRatEntity> = new FlxTypedSpriteGroup();

	override public function new(entity)
	{
		super(entity);
		weaponSpeed = 1.25;
		weaponScale = 2;
		loadGraphic(AssetPaths.ratlauncher__png);
	}	
	override function attack(player:EquippedEntity)
	{
		if (bullets.length >= maxBullets)
		{
			MultiSoundManager.playRandomSound(player, "out_of_ammo", FlxG.random.float(0.9, 1.1));
			return;
		}
		var bullet = new SmallRatEntity(player.getMidpoint().x, player.getMidpoint().y);
		bullet.y -= (bullet.height / 2);
		if (flipX)
		{
			bullet.x -= bullet.width;
			bullet.flipX = true;
		}
		shootyAnimation = 1.0;
		var vel = new FlxPoint(bulletSpeed, 0).rotateByDegrees(angle - 90);
		bullet.velocity = new FlxPoint(vel.x, vel.y);
		bullets.add(bullet);
		bullet.forPlayers = true;
		player.extraVelocity = vel.scaleNew(0.1).negate();
		var sound = FlxG.sound.play(AssetPaths.critswing__ogg);
		sound.pitch = 1.8;
		sound.volume = 0.45;
		FlxG.camera.shake(0.002, 0.1);
		MultiSoundManager.playRandomSound(player, "shoot", FlxG.random.float(0.5, 0.7), 1);
		super.attack(player);
	}

	var lastShootSelf = 0.0;

	override function update(elapsed:Float)
	{
		shootyAnimation -= elapsed * (shootyAnimation * 6);
		for (projectile in bullets)
		{
			if (FlxG.state is PlayState)
			{
				var ps:PlayState = cast(FlxG.state);
				FlxG.collide(projectile, ps.mapLayer);
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