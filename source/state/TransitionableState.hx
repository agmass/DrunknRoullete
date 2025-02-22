package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.system.FlxAssets.FlxShader;
import openfl.display.BitmapData;
import shader.MonochromeOut;
import shader.MouthwashingFadeOutEffect;

class TransitionableState extends FlxState
{
	public var shaderToApply:FlxShader;

	public var fadeIn = false;

	var oldSprite:FlxSprite = new FlxSprite();

	public static var bitmapData:BitmapData;

	override public function new() {
		super();
		shaderToApply = new MonochromeOut();
	}
	override function create()
	{
		super.create();

		if (bitmapData != null)
		{
			oldSprite.makeGraphic(FlxG.width, FlxG.height);
			oldSprite.graphic.bitmap = bitmapData;
			if (!FlxG.save.data.shadersDisabled)
				oldSprite.shader = shaderToApply;
			add(oldSprite);
		}
	}

	override function startOutro(onOutroComplete:() -> Void)
	{
		oldSprite.alpha = 0;
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
		if (shaderToApply != null && oldSprite.alive)
		{
			if (FlxG.save.data.shadersDisabled)
			{
				oldSprite.alpha -= elapsed;
			}
			else
			{
				if (shaderToApply is MonochromeOut) {
					var shaderCasted:MonochromeOut = cast(shaderToApply);
					if (shaderCasted.level.value[0] < 1.0)
					{
						shaderCasted.level.value[0] += elapsed*1.9;
					}
					else
					{
						oldSprite.alive = false;
						remove(oldSprite);
						oldSprite.shader = null;
					}
				}
				if (shaderToApply is MouthwashingFadeOutEffect) {
					var shaderCasted:MouthwashingFadeOutEffect = cast(shaderToApply);
					if (shaderCasted.level.value[0] > 0.0)
					{
						shaderCasted.level.value[0] -= elapsed;
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
