package objects;

import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import substate.SlotsSubState;

class SlotMachine extends SpriteToInteract
{
	override function interact(p:PlayerEntity)
	{
		super.interact(p);
		FlxG.state.openSubState(new SlotsSubState(p));
	}
}