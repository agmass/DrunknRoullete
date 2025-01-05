package entity;

import abilities.attributes.Attribute;
import abilities.equipment.Equipment;
import abilities.equipment.items.SwordItem;

class EquippedEntity extends Entity
{
	var handWeapon:Equipment = new SwordItem();
	var holsteredWeapon:Equipment;
	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.ATTACK_DAMAGE, new Attribute(0));
		attributes.set(Attribute.ATTACK_SPEED, new Attribute(0));
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		handWeapon.x = getGraphicMidpoint().x - (handWeapon.width / 2);
		handWeapon.y = getGraphicMidpoint().y - (handWeapon.height / 2);
		handWeapon.flipX = flipX;
		handWeapon.scale.x = attributes.get(Attribute.SIZE_X).getValue();
		handWeapon.scale.y = attributes.get(Attribute.SIZE_Y).getValue();
		if (handWeapon.flipX)
		{
			handWeapon.x -= 8;
		}
		else
		{
			handWeapon.x += 8;
		}
		handWeapon.draw();
	}
}