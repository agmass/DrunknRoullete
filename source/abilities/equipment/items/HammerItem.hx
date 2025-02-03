package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.EquippedEntity;
import entity.HumanoidEntity;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import objects.hitbox.HammerHitbox;
import objects.hitbox.Hitbox;
import objects.hitbox.SweepHitbox;
import projectiles.BottleProjectile;
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

/*
 * This is the "sword item" because that's what it was called during development. This item is really the Beer Bottle.
 */
class HammerItem extends Equipment
{
	override public function new(entity:EquippedEntity)
	{
		super(entity);
		weaponSpeed = 0.5;
		loadGraphic(AssetPaths.hammer__png);
		weaponScale = 4;
		scale.set(4, 4);
		updateHitbox();
	}

	override function alt_fire(player:EquippedEntity)
	{
		if (cooldown < 0)
		{
			spin = 360;
			cooldown = 3.25;
		}
		super.alt_fire(player);
	}

	override function attack(player:EquippedEntity)
	{ 
		if (canSuperJump)
		{
			if (player is HumanoidEntity)
			{
				cast(player, HumanoidEntity).jumpParticleswithColor(FlxColor.YELLOW);
			}
			canSuperJump = false;
			player.velocity.y = 400;
			player.extraVelocity.set(player.velocity.x * 2, player.velocity.y * 2);
		}
		super.attack(player);
	}

	var canSuperJump = false;

	var lastangle = 0.0;
	var angleChecker = 0.15;
	var spin = 0.0;
	var cooldown = 0.0;
	var lastWielderPos:FlxPoint = new FlxPoint();

	override function update(elapsed:Float)
	{
		if (wielder.isTouching(FLOOR))
		{
			canSuperJump = true;
		}
		cooldown -= elapsed;
		if (cooldown > 0)
		{
			alpha = 0.5;
		}
		else
		{
			alpha = 1;
		}
		angleChecker -= elapsed;
		if (angleChecker <= 0 && equipped || spin > 0 && equipped)
		{
			if ((Math.abs(lastangle - angle) > 20
				|| Math.abs(wielder.x - lastWielderPos.x) > 150
				|| Math.abs(wielder.y - lastWielderPos.y) > 150)
				&& spin < 0
				|| (spin > 0 && equipped && Math.round(spin) % 12 == 0))
			{
				if (spin > 0)
					angle = spin;
				var hammer = new HammerHitbox(getGraphicBounds().x, getGraphicBounds().top);
				if (!flipX)
				{
					hammer.x = getGraphicBounds().right - width;
				}
				if (angle < -90)
				{
					hammer.y = getGraphicBounds().bottom - 24;
				}
				hammer.shooter = wielder;
				wielder.hitboxes.add(hammer);
				MultiSoundManager.playRandomSound(wielder, "toyhammer", Main.randomProvider.float(0.9, 1.1), 0.4);
			}
			lastangle = angle;
			lastWielderPos = wielder.getPosition();
			angleChecker = 0.15 * wielder.attributes.get(Attribute.ATTACK_SPEED).getValue();
		}
		if (equipped)
		{
			offset.y = wielder.holdY;
			offset.x = wielder.holdX;
		}
		else
		{
			offset.y = 6;
			offset.x = 0;
		}
		super.update(elapsed);
		if (spin > 0)
		{
			angle = spin;
		}
		spin -= elapsed * 480;
	}

	override function draw()
	{
		super.draw();
	}
}