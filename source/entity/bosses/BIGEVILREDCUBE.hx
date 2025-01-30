package entity.bosses;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import abilities.equipment.items.BasicProjectileShootingItem;
import abilities.equipment.items.SwordItem;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class BIGEVILREDCUBE extends HumanoidEntity
{
	var behaviourState = 0;
	var lives = 1;
	var downtime = 1.0;
	var bits:FlxTypedSpriteGroup<FlxNapeSprite> = new FlxTypedSpriteGroup();

	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.retirement__png, true, 24, 32);
		typeTranslationKey = "evil_cube";
		entityName = Language.get("entity.evil_cube");
		bossHealthBar = true;
		animation.add("state0", [0]);
		animation.add("state1", [1]);
		handWeapon = new SwordItem(this);
		rewards = new Rewards(FlxG.random.int(3, 6), true);
		health = attributes.get(Attribute.MAX_HEALTH).getValue();
	}


	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(6, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(6, true));
		attributes.set(Attribute.ATTACK_SPEED,
			new Attribute(3.5 + FlxG.random.float(-0.005 * (Main.run.roomsTraveled), 0.5 + (-0.005 * (Main.run.roomsTraveled))), true));
		attributes.set(Attribute.ATTACK_DAMAGE,
			new Attribute(1.0 + FlxG.random.float(-0.005 * (Main.run.roomsTraveled), 0.5 + (-0.005 * (Main.run.roomsTraveled))), true));
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(100 + FlxG.random.int(20 * (Main.run.roomsTraveled - 1), 20 * Main.run.roomsTraveled), true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(200 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * Main.run.roomsTraveled), true));
	}

	var downscale = new AttributeContainer(AttributeOperation.MULTIPLY, 0.5);
	var upscale = new AttributeContainer(AttributeOperation.MULTIPLY, 3.4);

	override function update(elapsed:Float)
	{
		if (behaviourState == 0)
		{
			animation.play("state0");
		}
		else
		{
			animation.play("state1");
		}
		if (behaviourState == 1 && health == attributes.get(Attribute.MAX_HEALTH).getValue())
		{
			lives = 2;
			health = 0;
		}
		if (health <= 0)
		{
			if (lives > 0)
			{
				lives--;
				if (lives == 0)
				{
					attributes.get(Attribute.SIZE_X).addOperation(downscale);
					attributes.get(Attribute.SIZE_Y).addOperation(downscale);
					attributes.get(Attribute.ATTACK_SPEED).addOperation(downscale);
					attributes.get(Attribute.MOVEMENT_SPEED).addOperation(upscale);
					behaviourState = 1;
					var backslotWeapon = holsteredWeapon;
					holsteredWeapon = handWeapon;
					handWeapon = backslotWeapon;
					switchingAnimation = 0.5;
					health = attributes.get(Attribute.MAX_HEALTH).getValue() / 2;
					for (i in 0...3)
					{
						var bit = new FlxNapeSprite(x, y, false, true);
						bit.loadGraphic(AssetPaths.retirement_bits__png, true, 11, 13);
						bit.animation.add("a", [i]);
						bit.animation.play("a");
						bit.scale.set(3, 3);
						bit.updateHitbox();
						bit.createRectangularBody(33, 13 * 3);
						bit.body.velocity.setxy(FlxG.random.float(-800, 800), FlxG.random.float(-800, 800));
						bit.body.rotate(bit.body.position, FlxG.random.float(-180, 180));
						bit.body.space = Main.napeSpace;
						bit.setBodyMaterial(0.5, 0.4, 0.7, 0.2, 1);
						bits.add(bit);
						MultiSoundManager.playRandomSound(this, "flesh", 1, 1);
					}
				}
				else
				{
					attributes.get(Attribute.SIZE_X).removeOperation(downscale);
					attributes.get(Attribute.SIZE_Y).removeOperation(downscale);
					attributes.get(Attribute.ATTACK_SPEED).removeOperation(downscale);
					attributes.get(Attribute.MOVEMENT_SPEED).removeOperation(upscale);
					behaviourState = 0;
					var backslotWeapon = holsteredWeapon;
					holsteredWeapon = handWeapon;
					handWeapon = backslotWeapon;
					switchingAnimation = 0.5;
					health = attributes.get(Attribute.MAX_HEALTH).getValue();
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
			health += elapsed * 3;
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
		bits.update(elapsed);
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
						player.damage(20, this);
						velocity.y = -900;
					}
				});
			}
		}

	}
	var wantsToGoDown = false;
	override function draw()
	{
		bits.draw();
		super.draw();
	}
}