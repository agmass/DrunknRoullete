package entity.bosses;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
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
		animation.play("driving");
		animation.add("crashing", [1]);
		rewards = new Rewards(FlxG.random.int(6, 9), true);
		entityName = Language.get("entity." + typeTranslationKey);
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(4.5, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(4.5, true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(600 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * Main.run.roomsTraveled), true));
	}

	var damageUntilStateSwitch = 100;

	var behaviourState = 0;
	var anger = 1.0;
	var damagecool = 0.0;
	var immobilized = 0.0;

	override function onCollideWithEntity(e:Entity)
	{
		super.onCollideWithEntity(e);
		if (!charging && behaviourState == 1)
		{
			acceleration.x = 0;
			velocity.x = 0;
			charging = true;
		}
		if (charging)
		{
			if (alpha < 0.8 && immobilized < 0.0)
				return;

			e.damage(75, this);
			immobilized = 2.0;
		}
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
	override function update(elapsed:Float)
	{
		damagecool -= elapsed;
		immobilized -= elapsed;
		if (immobilized > 0)
		{
			alpha = 1;
			super.update(elapsed);
			return;
		}
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
		if (!charging)
		{
			if (closest != null)
			{
				acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1, 1) * (SPEED * anger));
			}
		}
		if (lastHealth > health)
		{
			damageUntilStateSwitch += Math.round(health - lastHealth);
			anger += Math.abs(Math.round(health - lastHealth) / 50);
		}
		if (damageUntilStateSwitch <= 0 && behaviourState == 0)
		{
			FlxG.camera.shake(0.015, 0.075);
			damageUntilStateSwitch = 150;
			behaviourState = 1;
		}
		if (damageUntilStateSwitch <= 0 && behaviourState == 1)
		{
			FlxG.camera.shake(0.015, 0.075);
			damageUntilStateSwitch = 100;
			behaviourState = 0;
		}
		if (drivingBackProgress < 1.0 && behaviourState == 0)
		{
			drivingBackProgress += elapsed;
			charging = true;
		}
		if (drivingBackProgress < 1.0 && behaviourState == 1 && charging)
		{
			drivingBackProgress += elapsed * 1.3;
		}
		if (drivingBackProgress > 0.0 && behaviourState == 1 && !charging)
		{
			drivingBackProgress -= elapsed;
		}
		alpha = FlxMath.lerp(0.5, 1.0, FlxMath.bound(drivingBackProgress, 0, 1));

		if (behaviourState == 0 && drivingBackProgress >= 1.0)
		{
			charging = false;
			if (animation.name == "crashing")
			{
				animation.play("driving");
				originalSpriteSizeX = 64;
				originalSpriteSizeY = 48;
				drivingBackProgress = 0.0;
			}
		}
		if (behaviourState == 1)
		{
			if (drivingBackProgress >= 1.0)
			{
				if (!wasImmobilized)
				{
					immobilized = 3.0;
					wasImmobilized = true;
				}
				else
				{
					charging = false;
					wasImmobilized = false;
				}
			}
			if (animation.name == "driving")
			{
				animation.play("crashing");
				originalSpriteSizeX = 35;
				originalSpriteSizeY = 48;
				drivingBackProgress = 1.0;
			}
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

	var drivingBackProgress = 1.0;
	var charging = false;
	var wasImmobilized = false;
}