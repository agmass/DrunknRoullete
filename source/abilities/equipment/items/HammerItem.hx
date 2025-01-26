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
		weaponScale = 3;
		scale.set(3, 3);
		updateHitbox();
	}

	override function alt_fire(player:EquippedEntity)
	{
		super.alt_fire(player);
	}

	override function attack(player:EquippedEntity)
	{
		super.attack(player);
	}

	var lastangle = 0.0;
	var angleChecker = 0.15;

	override function update(elapsed:Float)
	{
		angleChecker -= elapsed;
		if (angleChecker <= 0 && equipped)
		{
			if (Math.abs(lastangle - angle) > 20)
			{
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
				MultiSoundManager.playRandomSound(wielder, "toyhammer", FlxG.random.float(0.9, 1.1));
			}
			lastangle = angle;
			angleChecker = 0.15 * wielder.attributes.get(Attribute.ATTACK_SPEED).getValue();
		}
		offset.x = 0;
		offset.y = 6;
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
	}
}