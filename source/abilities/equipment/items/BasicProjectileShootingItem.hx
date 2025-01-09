package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import objects.hitbox.SweepHitbox;
import projectiles.BottleProjectile;
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

/*
 * Should be expanded by other classes to specify stats and graphics, or custom behaviour
 */
class BasicProjectileShootingItem extends Equipment
{
	public var broken = 0.0;

	override public function new(entity:EquippedEntity)
	{
		super();
		weaponSpeed = 0.5;
		loadGraphic(AssetPaths.sword__png, true, 24, 48);
		animation.add("full", [0]);
		animation.add("broken", [1]);
		wielder = entity;
	}

	var lastSwing = new FlxPoint(0, 0);

	public var bottle:BottleProjectile = null;

	override function alt_fire(player:EquippedEntity)
	{
		if (broken > 0)
			return;
		if (bottle == null)
		{
			bottle = new BottleProjectile(x, y, this);
			var add = new FlxPoint(800, 0).rotateByDegrees(angle - 90);
			bottle.body.velocity.setxy(add.x, add.y);
			bottle.body.rotate(bottle.body.position, angle * FlxAngle.TO_RAD);
			bottle.shooter = player;
			bottle.setBodyMaterial(0.5, 0.4, 0.7, 0.2, 1);
			player.collideables.add(bottle);
			MultiSoundManager.playRandomSound(player, "swing", 1.8, 0.45);
		}
		super.alt_fire(player);
	}

	override function attack(player:EquippedEntity)
	{
		if (bottle != null)
		{
			return;
		}
		var swordSweep = new SweepHitbox(player.getMidpoint().x, player.getMidpoint().y, Math.floor(player.attributes.get(Attribute.SIZE_X).getValue() - 1));
		swordSweep.shooter = player;
		swordSweep.y -= (swordSweep.height / 2);
		if (flipX)
		{
			swordSweep.x -= swordSweep.width;
			swordSweep.flipX = true;
		}
		player.hitboxes.add(swordSweep);
		lastSwing = new FlxPoint(80, 0).rotateByDegrees(angle - 90).negate();
		var add = new FlxPoint(50, 0).rotateByDegrees(angle - 90).negate();
		player.extraVelocity = lastSwing.scaleNew(1.2).negateNew();
		swordSweep.y += -add.y;
		swordSweep.velocity = new FlxPoint(300, 0).rotateByDegrees(angle - 90);
		swordSweep.damage *= player.attributes.get(Attribute.ATTACK_DAMAGE).getValue();
		if (player.isTouching(FLOOR))
		{
			var sound = FlxG.sound.play(AssetPaths.critswing__ogg);
			sound.pitch = 1.8;
			sound.volume = 0.45;
			Main.subtitles.set(Language.get("subtitle.critical_swing"), 4);
		}
		else
		{
			MultiSoundManager.playRandomSound(player, "swing", 1.8, 0.45);
		}
		super.attack(player);
	}

	override function update(elapsed:Float)
	{
		if (bottle != null)
		{
			if (bottle.broken)
				broken = 2.0;
			if (!bottle.alive)
			{
				bottle = null;
			}
			else
			{
				bottle.update(elapsed);
			}
		}
		if (broken > 0.0)
		{
			animation.play("broken");
		}
		else
		{
			animation.play("full");
		}
		broken -= elapsed;
		offset.x = FlxMath.lerp(0, lastSwing.x,
			Math.max(wielder.timeUntilAttack / (weaponSpeed + wielder.attributes.get(Attribute.ATTACK_SPEED).getValue()), 0));
		offset.y = FlxMath.lerp(6 * wielder.attributes.get(Attribute.SIZE_X).getValue(), lastSwing.y,
			Math.max(wielder.timeUntilAttack / (weaponSpeed + wielder.attributes.get(Attribute.ATTACK_SPEED).getValue()), 0));
		super.update(elapsed);
	}

	override public function createAttributes()
	{
		attributes.set(Attribute.ATTACK_DAMAGE, new AttributeContainer(AttributeOperation.FIRST_ADD, 12));
	}

	override function draw()
	{
		if (bottle != null)
		{
			bottle.draw();
		}
		else
		{
			super.draw();
		}
	}
}