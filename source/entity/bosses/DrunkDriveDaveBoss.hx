package entity.bosses;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class DrunkDriveDaveBoss extends HumanoidEntity
{
	var furElise:FlxSound = new FlxSound();

	public static var quietDownFurEliseIsPlaying = false;
	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.drunk_drive_dave__png, true, 64, 48);
		bossHealthBar = true;
		originalSpriteSizeX = 64;
		originalSpriteSizeY = 48;
		typeTranslationKey = "dave";
		animation.add("driving", [0]);
		animation.play("driving");
		animation.add("crashing", [1]);
		rewards = new Rewards(FlxG.random.int(6, 9), true);
		entityName = Language.get("entity." + typeTranslationKey);
		furElise.loadEmbedded(AssetPaths.furelise__ogg, true);
		quietDownFurEliseIsPlaying = true;
		furElise.play();
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(4.5, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(4.5, true));
		attributes.set(Attribute.MAX_HEALTH,
		new Attribute(250 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * Main.run.roomsTraveled), true));
		if (Main.run.roomsTraveled >= 5)
		{
			attributes.set(Attribute.CRIT_CHANCE,
			new Attribute(FlxG.random.int(3 * (Main.run.roomsTraveled - 6), 3 * (Main.run.roomsTraveled - 5)), true));
		}
	}

	var damageUntilStateSwitch = 100;

	var behaviourState = 0;
	var anger = 1.0;
	var damagecool = 0.0;

	override function onCollideWithEntity(e:Entity)
	{
		super.onCollideWithEntity(e);
		if (behaviourState == 0)
		{
			if (e.y > y + (32 * 4.5) && damagecool < 0)
			{
				damagecool = 0.3;
				if (Math.abs(Math.round(velocity.x / 35)) > 0)
				{
					e.damage(Math.abs(Math.round(velocity.x / 35)), this);
				}
				if (e.x > x)
				{
					velocity.x = -900;
				}
				else
				{
					velocity.x = 900;
				}
			}
		}
	}
	override function destroy()
	{
		furElise.looped = false;
		furElise.stop();
		furElise.destroy();
		quietDownFurEliseIsPlaying = false;
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		furElise.proximity(x, y, Main.audioPanner, 1740, true);
		damagecool -= elapsed;
		var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
		var closest:PlayerEntity = null;
		var closestDistance = 900000.0;
		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
			{
				if (!p.alive && !p.isTouching(FLOOR))
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
			flipX = closest.x > x;
			acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1, 1) * (SPEED * anger));
		}

		if (lastHealth > health)
		{
			damageUntilStateSwitch += Math.round(health - lastHealth);
			anger += Math.abs(Math.round(health - lastHealth) / 50);
		}

		super.update(elapsed);
	}
	override function damage(amount:Float, attacker:Entity)
	{
		if (alpha < 0.7)
		{
			return;
		}
		super.damage(amount, attacker);
	}

}