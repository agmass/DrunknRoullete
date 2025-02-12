package abilities.equipment.items;

import entity.EquippedEntity;
import flixel.util.FlxColor;

class KeyItem extends Equipment
{
	override public function new(entity:EquippedEntity)
	{
		super(entity);
		makeGraphic(16, 24, FlxColor.YELLOW);
	}
}