package entity;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.math.FlxMath;

class SmallRatEntity extends HumanoidEntity
{
	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.rat__png);
		typeTranslationKey = "rat";
		bossHealthBar = true;
		originalSpriteSizeX = 64;
		originalSpriteSizeY = 64;
	}

	override function createAttributes()
	{
		super.createAttributes();
		var size = FlxG.random.float(0.4, 0.6);
		attributes.set(Attribute.SIZE_X, new Attribute(size, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(size, true));
		attributes.set(Attribute.CRIT_CHANCE, new Attribute(5, true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(10 + FlxG.random.int(10 * Main.run.roomsTraveled, 10 * Main.run.roomsTraveled), true));
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(400 + FlxG.random.int(10 * Main.run.roomsTraveled, 10 * Main.run.roomsTraveled), true));
	}

	var overlappedLastFrame = false;

	override function update(elapsed:Float)
	{
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
			flipX = closest.x < x;
			acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1,
				1) * (attributes.get(Attribute.MOVEMENT_SPEED).getValue() * 3));
			if (!overlappedLastFrame && FlxG.overlap(this, closest))
			{
				closest.damage(2, this);
			}
			overlappedLastFrame = FlxG.overlap(this, closest);
		}
		super.update(elapsed);
	}
}