package objects;

import entity.PlayerEntity;
import flixel.FlxG;
import flixel.text.FlxText;
import openfl.display.BitmapData;
import state.MidState;
import util.Language;

class Elevator extends SpriteToInteract
{
	public var interactable = false;
	public var errorTip:FlxText = new FlxText(0, 0, 0, "", 19);

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
		if (showTip)
		{
			errorTip.alpha += elapsed * 3;
		}
		else
		{
			errorTip.alpha -= elapsed * 3;
		}
		errorTip.x = getGraphicMidpoint().x - (errorTip.width / 2);
		errorTip.y = getGraphicBounds().y - errorTip.height - 20;
	}

	override function draw()
	{
		super.draw();
		if (!interactable)
			errorTip.draw();
	}

	var smallPause = -9999999999.0;

	override function interact(p:PlayerEntity)
	{
		if (interactable)
		{
			interactable = false;
			animation.play("closed");
			var ps:PlayState = cast(FlxG.state);
			ps.playersSpawned = false;
			p.kill();
			smallPause = 0.4;
			super.interact(p);
		}
	}
}