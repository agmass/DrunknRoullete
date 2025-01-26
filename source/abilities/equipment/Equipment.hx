package abilities.equipment;

import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import abilities.attributes.AttributeType;
import entity.Entity;
import entity.EquippedEntity;
import entity.PlayerEntity;
import flixel.FlxSprite;

class Equipment extends FlxSprite
{
	public var wielder:EquippedEntity;
	public var translationKey = "";
	public var weaponSpeed:Float = 0.1;
	public var equipped = false;
	public var changePlayerAnimation = false;
	public var weaponScale = 1;

	public function new(entity:EquippedEntity)
	{
		super();
		wielder = entity;
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