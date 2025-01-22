package objects;

import abilities.equipment.items.BasicProjectileShootingItem;
import abilities.equipment.items.SwordItem;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import substate.SlotsSubState;

class WheelOfFortune extends SpriteToInteract
{
	override function interact(p:PlayerEntity)
	{
		super.interact(p);
		p.handWeapon = new SwordItem(p);
		p.holsteredWeapon = new BasicProjectileShootingItem(p);
	}
}