package entity.bosses;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class BIGEVILREDCUBE extends HumanoidEntity
{
	var behaviourState = 0;

	override public function new(x, y)
	{
		super(x, y);
		makeGraphic(32, 32, FlxColor.WHITE);
		color = FlxColor.RED;
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(6, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(6, true));
		attributes.set(Attribute.ATTACK_SPEED, new Attribute(2));
	}

	override function update(elapsed:Float)
	{
		var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
		if (behaviourState == 0)
		{
			var closest:PlayerEntity = null;
			var closestDistance = 900000.0;
			if (FlxG.state is PlayState)
			{
				var ps:PlayState = cast(FlxG.state);
				ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
				{
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
				handWeapon.angle = getMidpoint().degreesFrom(closest.getMidpoint()) - 90;
				if (Math.abs(closestDistance) > (32 * 6) + 300)
				{
					acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1, 1) * (SPEED * 3));
				}
				else
				{
					if (timeUntilAttack <= 0)
					{
						timeUntilAttack = handWeapon.weaponSpeed * attributes.get(Attribute.ATTACK_SPEED).getValue();
						handWeapon.attack(this);
					}
					acceleration.x = 0;
				}
			}
		}
		maxVelocity.x = SPEED;
		super.update(elapsed);
	}
}