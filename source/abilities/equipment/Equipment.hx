package abilities.equipment;

import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import abilities.attributes.AttributeType;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxSprite;

class Equipment extends FlxSprite
{
	public var wielder:EquippedEntity;
	public var translationKey = "";
	public var attributes:Map<AttributeType, AttributeContainer> = new Map<AttributeType, AttributeContainer>();
	public var weaponSpeed:Float = 0;
	public var equipped = false;
	public var changePlayerAnimation = false;

	public function new()
	{
		super();
		createAttributes();
	}
	public function canSwapOut():Bool
	{
		return false;
	}

	public function attack(player:EquippedEntity) {}

	public function alt_fire(player:EquippedEntity) {}

	public function use(player:EquippedEntity) {}

	public function createAttributes() {}

}