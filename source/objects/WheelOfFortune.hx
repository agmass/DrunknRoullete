package objects;

import abilities.equipment.items.BasicProjectileShootingItem;
import abilities.equipment.items.SwordItem;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import substate.WheelSubState;

class WheelOfFortune extends SpriteToInteract
{
	override function interact(p:PlayerEntity)
	{
		super.interact(p);
		FlxG.state.openSubState(new WheelSubState());
		p.handWeapon = new SwordItem(p);
		p.holsteredWeapon = new BasicProjectileShootingItem(p);
	}
}