package projectiles;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import abilities.equipment.items.SwordItem;
import entity.Entity;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import sound.FootstepManager.MultiSoundManager;
import util.Language;
import util.Projectile;

class CursedBulletProjectile extends BulletProjectile
{
	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
		{
			if (dropTime <= 0.0 && !returnToShooter)
			{
				MultiSoundManager.playRandomSound(entity, "pickup_bullet", Main.randomProvider.float(0.9, 1.2));
				returnToShooter = true;
			}
			return;
		}
		if (hitEntity)
		{
			return;
		}
		if (dropTime <= -3.5)
		{
			return;
		}
		hitEntities.push(entity.ID);
		entity.damage(24, shooter);
		FlxG.camera.shake(0.001, 0.05);
		hitEntity = true;
		entity.velocity = velocity.scaleNew(shooter.attributes.get(Attribute.ATTACK_KNOCKBACK).getValue()).scalePoint(new FlxPoint(3, 1.5));
		roll(entity, shooter);
	}

	public static function roll(p:Entity, shooter:Entity)
	{
		var lostOrWon = Main.randomProvider.bool(20);
		if (shooter == p)
		{
			lostOrWon = Main.randomProvider.bool(80);
		}

		var amount = 0.0;

		var operation:AttributeOperation = [AttributeOperation.ADD, AttributeOperation.MULTIPLY][Main.randomProvider.int(0, 1)];
		var listForBet = [];
		for (key => value in p.attributes)
		{
			listForBet.push(key);
		}
		var type = listForBet[Main.randomProvider.int(0, listForBet.length - 1)];
		if (type == Attribute.SIZE_X || type == Attribute.SIZE_Y || type == Attribute.ATTACK_SPEED || type == Attribute.ATTACK_KNOCKBACK
			|| type == Attribute.CROUCH_SCALE)
		{
			if (shooter == p)
			{
				lostOrWon = Main.randomProvider.bool(20);
			}
			else
			{
				lostOrWon = Main.randomProvider.bool(80);
			}
		}
		if (!p.attributes.exists(type))
		{
			lostOrWon = true;
		}
		else
		{
			if (type.maxBound <= p.attributes.get(type).getValue())
			{
				lostOrWon = false;
			}
			if (type.minBound >= p.attributes.get(type).getValue())
			{
				lostOrWon = true;
			}
		}
		if (type.mustBeAddition)
		{
			operation = ADD;
		}
		if (operation.equals(MULTIPLY))
		{
			if (lostOrWon)
			{
				amount = Main.randomProvider.float(1.1, 2);
			}
			else
			{
				amount = Main.randomProvider.float(0.4, 0.9);
			}
			amount = FlxMath.roundDecimal(amount, 1);
		}
		else
		{
			amount = [10.0, 10.0, 10.0, 10.0, 10.0, 25.0, 25.0, 25.0, 25.0, 25.0, 50.0, 100.0][Main.randomProvider.int(0, 11)];
			if (type.additionMultiplier <= 0.001 && amount <= 50)
			{
				amount = 100.0;
			}
			amount *= type.additionMultiplier;
			if (type == Attribute.JUMP_COUNT)
			{
				amount = [1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0][Main.randomProvider.int(0, 13)] *= type.additionMultiplier;
			}
			if (!lostOrWon)
				amount = -amount;
		}

		if (!p.attributes.exists(type))
		{
			p.attributes.set(type, new Attribute(type.minBound));
			p.attributes.get(type).min = type.minBound;
			p.attributes.get(type).max = type.maxBound;
		}
		var positive = lostOrWon;
		if (type == Attribute.SIZE_X || type == Attribute.SIZE_Y || type == Attribute.ATTACK_SPEED || type == Attribute.CROUCH_SCALE
			|| type == Attribute.ATTACK_KNOCKBACK)
			positive = !lostOrWon;
		if (type == Attribute.SIZE_X || type == Attribute.SIZE_Y)
		{
			p.attributes.get(Attribute.SIZE_Y).addTemporaryOperation(new AttributeContainer(operation, amount), 4.5);
			p.attributes.get(Attribute.SIZE_X).addTemporaryOperation(new AttributeContainer(operation, amount), 4.5);
		}
		else
		{
			var timeBonus = 0;
			if (positive && shooter == p)
				timeBonus += 3;
			if (!positive && shooter != p)
				timeBonus += 3;
			p.attributes.get(type).addTemporaryOperation(new AttributeContainer(operation, amount), Main.randomProvider.float(5, 8) + timeBonus);
		}
		if (type == Attribute.MAX_HEALTH)
		{
			p.health += amount;
		}

		var text = "";
		if (operation == MULTIPLY)
		{
			text += "x" + amount;
		}
		else
		{
			if (lostOrWon)
			{
				text += "+" + amount;
			}
			else
			{
				text += amount;
			}
		}
		text += " " + Language.get("attribute." + type.id);
		p.spawnFloatingText(text, FlxColor.YELLOW, 26);
	}
}