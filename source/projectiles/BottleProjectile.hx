package projectiles;

import abilities.attributes.Attribute;
import abilities.equipment.items.SwordItem;
import entity.Entity;
import entity.EquippedEntity;
import util.Projectile;

class BottleProjectile extends Projectile
{
	public var dontPickUp = 0.3;

	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
		{
			if (dontPickUp <= 0)
			{
				this.kill();
			}
			return;
		}
		entity.health -= 60 * shooter.attributes.get(Attribute.ATTACK_DAMAGE).getValue();
		super.onOverlapWithEntity(entity);
	}

	override function update(elapsed:Float)
	{
		dontPickUp -= elapsed;
		super.update(elapsed);
	}
}