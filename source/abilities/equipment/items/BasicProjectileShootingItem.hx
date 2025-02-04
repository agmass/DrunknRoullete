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
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

class BasicProjectileShootingItem extends Equipment
{

	public var bulletSpeed = 1200;
	public var maxBullets = 8;
	public var shootyAnimation = 0.0;
	public var bullets:FlxTypedSpriteGroup<BulletProjectile> = new FlxTypedSpriteGroup();

	override public function new(entity)
	{
		super(entity);
		weaponSpeed = 0.25;
		loadGraphic(AssetPaths.gun__png);
	}

	var burst = 5;
	var burstCool = 0.1;

	override function alt_fire(player:EquippedEntity)
	{
		if (burst == 5)
		{
			burst = -4;
			burstCool = 0;
		}
		super.alt_fire(player);
	}

	override function attack(player:EquippedEntity)
	{
		if (bullets.length >= maxBullets)
		{
			MultiSoundManager.playRandomSound(player, "out_of_ammo", Main.randomProvider.float(0.9, 1.1));
			return;
		}
		var bullet = new BulletProjectile(player.getMidpoint().x, player.getMidpoint().y);
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
		MultiSoundManager.playRandomSound(player, "shoot", Main.randomProvider.float(0.9, 1.1), 1);
		super.attack(player);
	}

	override function addSomeSortOfNetworkedProjectile(proj:Projectile)
	{
		if (proj is BulletProjectile)
		{
			var vel = new FlxPoint(bulletSpeed, 0).rotateByDegrees(proj.angle);
			proj.body.velocity = new Vec2(vel.x, vel.y);
			proj.body.rotate(proj.body.position, (proj.angle) * FlxAngle.TO_RAD);
			proj.shooter = wielder;
			bullets.add(cast(proj));
		}
		super.addSomeSortOfNetworkedProjectile(proj);
	}

	override function update(elapsed:Float)
	{
		if (bullets.length >= maxBullets)
		{
			burst = 5;
		}
		if (burst != 5)
		{
			burstCool -= elapsed;
			if (burstCool <= 0)
			{
				burstCool = 0.025;
				angle = angle + burst + Main.randomProvider.float(-30, 30);
				attack(wielder);
				burst++;
			}
		}
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