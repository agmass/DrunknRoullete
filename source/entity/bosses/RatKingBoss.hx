package entity.bosses;

import abilities.attributes.Attribute;
import abilities.equipment.items.RatGun;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
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
	}

	var damageUntilStateSwitch = 100;

	var behaviourState = 0;
	var randomRatBirth = 0.1;

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
		if (behaviourState == 1)
		{
			acceleration.y = acceleration.y * (1 + elapsed);
			maxVelocity.y = acceleration.y;
		}
		if (!isOnScreen())
		{
			MultiSoundManager.playRandomSound(this, "dig", FlxG.random.float(0.9, 1.1));
			FlxG.camera.shake(0.025, 0.1);
			behaviourState = 0;
			velocity.y = -1250;
			x = FlxG.random.int(500, 1000);
			y = FlxG.height - 100;
			acceleration.y = 900;
			maxVelocity.y = 900;
			noclip = false;
		}
		super.update(elapsed);
	}

}