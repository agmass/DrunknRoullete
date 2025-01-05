package abilities.equipment.items;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import flixel.FlxSprite;

class SwordItem extends Equipment
{
	override public function new()
	{
		super();
		loadGraphic(AssetPaths.sword__png);
	}

	override public function createAttributes()
	{
		attributes.set(Attribute.ATTACK_DAMAGE, new AttributeContainer(AttributeOperation.FIRST_ADD, 12));
	}
}