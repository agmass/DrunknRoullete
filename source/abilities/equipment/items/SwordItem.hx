package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import objects.hitbox.SweepHitbox;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class SwordItem extends Equipment
{
	var wielder:EquippedEntity;

	override public function new(entity:EquippedEntity)
	{
		super();
		weaponSpeed = 0.5;
		loadGraphic(AssetPaths.sword__png);
		wielder = entity;
	}

	var lastSwing = new FlxPoint(0, 0);

	override function attack(player:EquippedEntity)
	{
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
			FlxG.sound.play(AssetPaths.critswing__ogg);
			Main.subtitles.set(Language.get("subtitle.critical_swing"), 4);
		}
		else
		{
			MultiSoundManager.playRandomSound(player, "swing");
		}
		super.attack(player);
	}

	override function update(elapsed:Float)
	{

		offset.x = FlxMath.lerp(0, lastSwing.x,
			Math.max(wielder.timeUntilAttack / (weaponSpeed + wielder.attributes.get(Attribute.ATTACK_SPEED).getValue()), 0));
		offset.y = FlxMath.lerp(0, lastSwing.y,
			Math.max(wielder.timeUntilAttack / (weaponSpeed + wielder.attributes.get(Attribute.ATTACK_SPEED).getValue()), 0));
		if (wielder.holsteredWeapon != null)
		{
			if (wielder.holsteredWeapon.ID == ID)
			{
				offset.x = 0;
				offset.y = 0;
			}
		}
		super.update(elapsed);
	}

	override public function createAttributes()
	{
		attributes.set(Attribute.ATTACK_DAMAGE, new AttributeContainer(AttributeOperation.FIRST_ADD, 12));
	}
}