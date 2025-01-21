package objects;

import entity.PlayerEntity;
import flixel.FlxG;
import openfl.display.BitmapData;
import state.MidState;

class Elevator extends SpriteToInteract
{
	public var interactable = false;

	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.elevator__png, true, 256, 256);
		animation.add("open", [0]);
		animation.add("closed", [1]);
		animation.play("closed");
	}

	override function update(elapsed:Float)
	{
		if (interactable)
		{
			animation.play("open");
			super.update(elapsed);
		}
		else
		{
			if (smallPause > -9999999998.0)
			{
				smallPause -= elapsed;
				if (smallPause <= 0)
				{
					FlxG.switchState(new MidState());
				}
			}
			tooltipSprite.alpha = 0;
		}
	}

	var smallPause = -9999999999.0;

	override function interact(p:PlayerEntity)
	{
		if (interactable)
		{
			interactable = false;
			animation.play("closed");
			p.kill();
			smallPause = 0.4;
			super.interact(p);
		}
	}
}