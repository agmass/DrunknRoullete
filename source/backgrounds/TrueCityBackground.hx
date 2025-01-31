package backgrounds;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

class TrueCityBackground extends FlxTypedGroup<FlxSprite>
{
	var layer1:FlxSprite = new FlxSprite(0, 0, AssetPaths.truecity_back_1__png);
	var layer2:FlxSprite = new FlxSprite(0, 0, AssetPaths.truecity_back_2__png);
	var layerBG:FlxSprite = new FlxSprite(0, 0, AssetPaths.truecity_back_3__png);

	override public function new()
	{
		super();
		add(layerBG);
		add(layer2);
		add(layer1);
		layer1.scale.set(1.5, 1.5);
		layer2.scale.set(1.5, 1.5);
		layerBG.scale.set(1.5, 1.5);
		layer1.updateHitbox();
		layer2.updateHitbox();
		layerBG.updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			var bgTarget = ps.playerLayer.getFirstAlive();
			if (bgTarget != null)
			{
				layer1.x = (((960 - bgTarget.x) / 960) * 40);
				layer1.y = (((540 - bgTarget.y) / 540) * 40);
				layer2.x = (((960 - bgTarget.x) / 960) * 25);
				layer2.y = (((540 - bgTarget.y) / 540) * 25);
			}
		}
		super.update(elapsed);
	}
}