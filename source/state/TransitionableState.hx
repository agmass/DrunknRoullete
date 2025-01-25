package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import openfl.display.BitmapData;
import shader.MouthwashingFadeOutEffect;

class TransitionableState extends FlxState
{
	public var mouthwashFadeOut:MouthwashingFadeOutEffect;

	public var fadeIn = false;

	var oldSprite:FlxSprite = new FlxSprite();

	public static var bitmapData:BitmapData;

	override function create()
	{
		super.create();

		if (bitmapData != null)
		{
			mouthwashFadeOut = new MouthwashingFadeOutEffect();
			// mouthwashFadeOut.level.value = [0.0];
			oldSprite.makeGraphic(FlxG.width, FlxG.height);
			oldSprite.graphic.bitmap = bitmapData;
			if (!FlxG.save.data.shadersDisabled)
				oldSprite.shader = mouthwashFadeOut;
			add(oldSprite);
		}
	}

	override function startOutro(onOutroComplete:() -> Void)
	{
		TransitionableState.screengrab();
		super.startOutro(onOutroComplete);
	}

	public static function screengrab()
	{
		bitmapData = BitmapData.fromImage(FlxG.stage.window.readPixels());
		bitmapData.draw(FlxG.camera.canvas, null, null, null, null, false);
	}

	override function update(elapsed:Float)
	{
		if (mouthwashFadeOut != null && oldSprite.alive)
		{
			if (FlxG.save.data.shadersDisabled)
			{
				oldSprite.alpha -= elapsed;
			}
			else
			{
				if (fadeIn)
				{
					if (mouthwashFadeOut.level.value[0] > 0.0)
					{
						mouthwashFadeOut.level.value[0] -= elapsed;
					}
					else
					{
						oldSprite.alive = false;
						remove(oldSprite);
						oldSprite.shader = null;
					}
				}
				else
				{
					if (mouthwashFadeOut.level.value[0] > 0.0)
					{
						mouthwashFadeOut.level.value[0] -= elapsed;
					}
					else
					{
						oldSprite.alive = false;
						remove(oldSprite);
						oldSprite.shader = null;
					}
				}
			}
		}
		super.update(elapsed);
	}
}