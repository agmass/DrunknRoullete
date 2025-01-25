package entity.bosses;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class RatKingBoss extends HumanoidEntity
{
	var children:FlxTypedSpriteGroup<SmallRatEntity> = new FlxTypedSpriteGroup();

	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.rat__png);
		typeTranslationKey = "rat";
		bossHealthBar = true;
		originalSpriteSizeX = 64;
		originalSpriteSizeY = 64;
		rewards = new Rewards(FlxG.random.int(6, 9), true);
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(6, true));
		attributes.set(Attribute.SIZE_Y, new Attribute(6, true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(600, true));
	}

	var damageUntilStateSwitch = 100;

	var behaviourState = 0;
	var randomRatBirth = 0.1;

	override function update(elapsed:Float)
	{
		randomRatBirth -= elapsed;
		if (randomRatBirth < 0)
		{
			if (behaviourState == 0)
			{
				randomRatBirth = FlxG.random.float(0.6, 2.4);
				for (i in 0...FlxG.random.int(1, 3))
				{
					children.add(new SmallRatEntity(getMidpoint().x, getMidpoint().y));
				}
			}
		}
		if (lastHealth > health)
		{
			damageUntilStateSwitch += Math.round(health - lastHealth);
			trace(damageUntilStateSwitch);
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
			if (!isOnScreen())
			{
				FlxG.camera.shake(0.025, 0.1);
				behaviourState = 0;
				velocity.y = -1250;
				x = FlxG.random.int(300, 1600);
				y = FlxG.height - 100;
				acceleration.y = 900;
				maxVelocity.y = 900;
				noclip = false;
			}
		}
		children.update(elapsed);
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		children.draw();
	}
}