package entity.bosses;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class DrunkDriveDaveBoss extends HumanoidEntity
{
	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.drunk_drive_dave__png, true, 64, 48);
		bossHealthBar = true;
		originalSpriteSizeX = 64;
		originalSpriteSizeY = 48;
		typeTranslationKey = "dave";
		animation.add("driving", [0]);
		animation.add("crashing", [1]);
		rewards = new Rewards(FlxG.random.int(6, 9), true);
		entityName = Language.get("entity." + typeTranslationKey);
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(6, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(6, true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(600 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * Main.run.roomsTraveled), true));
	}

	var damageUntilStateSwitch = 100;

	var behaviourState = 0;
	var anger = 1.0;

	override function update(elapsed:Float)
	{
		var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
		var closest:PlayerEntity = null;
		var closestDistance = 900000.0;
		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
			{
				if (!p.alive)
					return;
				if (closestDistance > p.getMidpoint().distanceTo(getMidpoint()))
				{
					closestDistance = p.getMidpoint().distanceTo(getMidpoint());
					closest = p;
				}
			});
		}
		if (closest != null)
		{
			acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1, 1) * (SPEED * anger));
		}
		if (lastHealth > health)
		{
			damageUntilStateSwitch += Math.round(health - lastHealth);
			anger += Math.abs(Math.round(health - lastHealth) / 30);
		}
		if (damageUntilStateSwitch <= 0 && behaviourState == 0)
		{
			FlxG.camera.shake(0.015, 0.075);
			damageUntilStateSwitch = 100;
			behaviourState = 1;
		}
		if (behaviourState == 1)
		{
			if (an)
		}
		super.update(elapsed);
	}
}