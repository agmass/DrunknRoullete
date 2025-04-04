package entity.bosses;

import abilities.attributes.Attribute;
import abilities.equipment.items.RatGun;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import objects.DroppedItem;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class RatKingBoss extends HumanoidEntity
{
	var children:FlxTypedSpriteGroup<SmallRatEntity> = new FlxTypedSpriteGroup();

	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.rat__png);
		bossHealthBar = true;
		originalSpriteSizeX = 64;
		originalSpriteSizeY = 64;
		typeTranslationKey = "rat";
		rewards = new Rewards(FlxG.random.int(6, 9), true);
		entityName = Language.get("entity." + typeTranslationKey);
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(6, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(6, true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(600 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * Main.run.roomsTraveled), true));
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(450 + FlxG.random.int(5 * (Main.run.roomsTraveled - 1), 5 * Main.run.roomsTraveled), true));
		if (Main.run.roomsTraveled >= 5)
		{
			attributes.set(Attribute.CRIT_CHANCE, new Attribute(FlxG.random.int(3 * (Main.run.roomsTraveled - 6), 3 * (Main.run.roomsTraveled - 5)), true));
		}
	}

	var damageUntilStateSwitch = 100;

	var behaviourState = 0;
	var randomRatBirth = 0.1;
	var overlappedLastFrame = [];

	override function update(elapsed:Float)
	{
		if (health <= 0 && ragdoll == null)
		{
			if (FlxG.random.bool(5))
			{
				if (FlxG.state is PlayState)
				{
					var ps:PlayState = cast(FlxG.state);
					spawnFloatingText("RARE DROP!", FlxColor.BLUE);
					ps.interactable.add(new DroppedItem(getMidpoint().x, getMidpoint().y, new RatGun(this)));
				}
			}
		}
		for (entity in children)
		{
			if (entity.alive)
			{
				if (!entity.isOnScreen())
				{
					entity.velocity.y = -1250;
					entity.x = FlxG.random.int(500, 1000);
					entity.y = FlxG.height - 100;
					entity.acceleration.y = 900;
					entity.maxVelocity.y = 900;
				}
			}
		}
		randomRatBirth -= elapsed;
		if (randomRatBirth < 0)
		{
			if (behaviourState == 0)	
			{
				randomRatBirth = FlxG.random.float(2, 2.4);
				for (i in 0...FlxG.random.int(1, 3))
				{
					if (FlxG.state is PlayState)
					{
						var ps:PlayState = cast(FlxG.state);
						var rat = new SmallRatEntity(getMidpoint().x, getMidpoint().y);
						ps.enemyLayer.add(rat);
						children.add(rat);
					}
				}
			}
		}
		if (lastHealth > health)
		{
			damageUntilStateSwitch += Math.round(health - lastHealth);
		}
		if (damageUntilStateSwitch <= 0 && behaviourState == 0)
		{
			FlxG.camera.shake(0.015, 0.075);
			damageUntilStateSwitch = 100;
			behaviourState = 1;
			velocity.y = -500;
			noclip = true;
		}
		if (damageUntilStateSwitch <= 0 && behaviourState == 2)
		{
			FlxG.camera.shake(0.025, 0.1);
			behaviourState = 0;
			x = FlxG.random.int(500, 1000);
			velocity.y = -1400;
			acceleration.y = 900;
			acceleration.x = 0;
			damageUntilStateSwitch = 100;
			maxVelocity.y = 900;
			noclip = false;
		}
		if (behaviourState == 1)
		{
			acceleration.y = acceleration.y * (1 + elapsed);
			maxVelocity.y = acceleration.y;
		}
		var newOverlaps = [];
		if (behaviourState == 2)
		{
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
				if (closest != null)
				{
					acceleration.x = -(FlxMath.bound(getPosition().addPoint(closest.getPosition().negateNew()).x, -1,
						1) * attributes.get(Attribute.MOVEMENT_SPEED).getValue());
				}
				FlxG.overlap(this, ps.playerLayer, (r, pl:Entity) ->
				{
					newOverlaps.push(pl);
					if (!overlappedLastFrame.contains(pl))
						pl.damage(25, this);
				});
			}
		}
		overlappedLastFrame = newOverlaps;
		if (!isOnScreen() && y > 0)
		{
			MultiSoundManager.playRandomSound(this, "dig", FlxG.random.float(0.9, 1.1));
			FlxG.camera.shake(0.025, 0.1);
			behaviourState = 2;
			x = FlxG.random.int(300, 800);
			y = -600;
			acceleration.x = 0;
			velocity.x = 0;
			acceleration.y = 900;
			damageUntilStateSwitch = 1;
			maxVelocity.y = 900;
			noclip = true;
		}
		super.update(elapsed);
	}

}