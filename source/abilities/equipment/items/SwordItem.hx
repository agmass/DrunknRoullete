package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxSprite;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import objects.hitbox.SweepHitbox;

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
		swordSweep.y -= (swordSweep.height / 2);
		if (flipX)
		{
			swordSweep.x -= swordSweep.width;
			swordSweep.flipX = true;
		}
		player.hitboxes.add(swordSweep);
		lastSwing = new FlxPoint(80, 0).rotateByDegrees(angle - 90).negate();
		player.extraVelocity = lastSwing.scaleNew(2).negateNew();
		var add = new FlxPoint(50, 0).rotateByDegrees(angle - 90).negate();
		swordSweep.y += -add.y;
		swordSweep.velocity = new FlxPoint(300, 0).rotateByDegrees(angle - 90);
		super.attack(player);
	}

	override function update(elapsed:Float)
	{
		offset.x = FlxMath.lerp(0, lastSwing.x,
			Math.max(wielder.timeUntilAttack / (weaponSpeed + wielder.attributes.get(Attribute.ATTACK_SPEED).getValue()), 0));
		offset.y = FlxMath.lerp(0, lastSwing.y,
			Math.max(wielder.timeUntilAttack / (weaponSpeed + wielder.attributes.get(Attribute.ATTACK_SPEED).getValue()), 0));
		super.update(elapsed);
	}

	override public function createAttributes()
	{
		attributes.set(Attribute.ATTACK_DAMAGE, new AttributeContainer(AttributeOperation.FIRST_ADD, 12));
	}
}