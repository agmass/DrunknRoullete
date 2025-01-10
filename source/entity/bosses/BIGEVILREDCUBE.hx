package entity.bosses;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class BIGEVILREDCUBE extends HumanoidEntity
{
	var behaviourState = 0;
	var lives = 3;
	var downtime = 1.0;

	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.evilmf__png);
		typeTranslationKey = "evil_cube";
		entityName = "Evil Red Guy";
		bossHealthBar = true;
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(6, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(6, true));
		attributes.set(Attribute.ATTACK_SPEED, new Attribute(3.5, true));
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(100, true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(200, true));
	}

	var downscale = new AttributeContainer(AttributeOperation.MULTIPLY, 0.5);
	var upscale = new AttributeContainer(AttributeOperation.MULTIPLY, 5);

	override function update(elapsed:Float)
	{
		if (health <= 0)
		{
			if (lives > 0)
			{
				health = attributes.get(Attribute.MAX_HEALTH).getValue();
				lives--;
				if (lives == 2 || lives == 0)
				{
					attributes.get(Attribute.SIZE_X).addOperation(downscale);
					attributes.get(Attribute.SIZE_Y).addOperation(downscale);
					attributes.get(Attribute.MAX_HEALTH).addOperation(downscale);
					attributes.get(Attribute.ATTACK_SPEED).addOperation(downscale);
					attributes.get(Attribute.MOVEMENT_SPEED).addOperation(upscale);
					behaviourState = 1;
					var backslotWeapon = holsteredWeapon;
					holsteredWeapon = handWeapon;
					handWeapon = backslotWeapon;
					switchingAnimation = 0.5;
				}
				else
				{
					attributes.get(Attribute.SIZE_X).removeOperation(downscale);
					attributes.get(Attribute.SIZE_Y).removeOperation(downscale);
					attributes.get(Attribute.MAX_HEALTH).removeOperation(downscale);
					attributes.get(Attribute.ATTACK_SPEED).removeOperation(downscale);
					attributes.get(Attribute.MOVEMENT_SPEED).removeOperation(upscale);
					behaviourState = 0;
					var backslotWeapon = holsteredWeapon;
					holsteredWeapon = handWeapon;
					handWeapon = backslotWeapon;
					switchingAnimation = 0.5;
				}
			}
		}
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
		if (downtime > 0)
		{
			downtime -= elapsed;
			alpha = (Math.round(downtime % 2) == 0 ? 1 : 0.75);
		}
		if (behaviourState == 0 && downtime < 0)
		{
			if (!isTouching(FLOOR) && !wantsToGoDown)
			{
				velocity.y = 400;
			}
			if (closest != null)
			{
				flipX = closest.x < x;
				if (handWeapon != null)
				{
					if (switchingAnimation > 0)
					{
						handWeapon.angle = FlxMath.lerp(getMidpoint().degreesFrom(closest.getMidpoint()) - 90, handWeapon.flipX ? 45 : -45,
							switchingAnimation * 2);
					}
					else
					{
						handWeapon.angle = getMidpoint().degreesFrom(closest.getMidpoint()) - 90;
					}
				}
				if (Math.abs(closestDistance) > (32 * 6) + 300)
				{
					acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1, 1) * (SPEED * 3));
					if (isTouching(WALL))
					{
						if (isTouching(FLOOR))
						{
							velocity.y = -600;
							wantsToGoDown = true;
						}
					}
					else
					{
						if (isTouching(FLOOR))
						{
							wantsToGoDown = false;
						}
					}
				}
				else
				{
					if (timeUntilAttack <= 0)
					{
						timeUntilAttack = handWeapon.weaponSpeed * attributes.get(Attribute.ATTACK_SPEED).getValue();
						handWeapon.attack(this);
					}
					wantsToGoDown = false;
					acceleration.x = 0;
				}
			}
		}
		if (holsteredWeapon != null)
		{
			if (switchingAnimation > 0)
			{
				holsteredWeapon.angle = FlxMath.lerp(holsteredWeapon.flipX ? 45 : -45, getMidpoint().degreesFrom(closest.getMidpoint()) - 90,
					switchingAnimation * 2);
			}
		}
		maxVelocity.x = SPEED;
		var validGroundPound = false;
		if (behaviourState == 1 && downtime < 0)
		{
			if (closest != null)
			{
				flipX = closest.x < x;
				acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1, 1) * (SPEED * 6));

				if (Math.abs(closestDistance) < (32 * 6) + 200)
				{
					if (isTouching(FLOOR))
					{
						velocity.y = -600;
					}
					else
					{
						if (velocity.y > 0)
						{
							velocity.y = 800;
							validGroundPound = true;
						}
					}
				}
			}
		}
		super.update(elapsed);
		if (validGroundPound)
		{
			if (FlxG.state is PlayState)
			{
				var ps:PlayState = cast(FlxG.state);
				ps.playerLayer.forEachOfType(PlayerEntity, (player) ->
				{
					if (player.overlaps(this))
					{
						player.health -= 75;
						velocity.y = -400;
					}
				});
			}
		}

	}
	var wantsToGoDown = false;
}