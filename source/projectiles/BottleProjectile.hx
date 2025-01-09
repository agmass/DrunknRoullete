package projectiles;

import abilities.attributes.Attribute;
import abilities.equipment.items.SwordItem;
import entity.Entity;
import entity.EquippedEntity;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import sound.FootstepManager.MultiSoundManager;
import util.Projectile;

class BottleProjectile extends Projectile
{
	public var dontPickUp = 0.3;
	public var broken = false;

	var shards:FlxEmitter = new FlxEmitter(0, 0, 6);

	override public function new(x, y, originalBottle)
	{
		super(x, y, null, false, true);
		loadGraphicFromSprite(originalBottle);
		createRectangularBody(14, 41);
		shards.loadParticles(AssetPaths.shard__png, 6, 18, true);
		shards.acceleration.set(0, 400);
		shards.alpha.set(1, 1, 0, 0);
	}

	override function onOverlapWithMap()
	{
		super.onOverlapWithMap();
		if (broken)
			return;
		broken = true;
		FlxG.camera.shake(0.0025, 0.2);
		MultiSoundManager.playRandomSoundByItself(x, y, "glass_break", FlxG.random.float(0.8, 1.2));
		shards.start(true, 0.1, 0);
	}

	var hitEntity = false;
	override function onOverlapWithEntity(entity:Entity)
	{
		if (entity == shooter)
		{
			if (dontPickUp <= 0)
			{
				this.kill();
			}
			return;
		}
		if (broken)
		{
			return;
		}
		entity.health -= 20 * shooter.attributes.get(Attribute.ATTACK_DAMAGE).getValue();
		broken = true;
		FlxG.camera.shake(0.0025, 0.2);
		hitEntity = true;
		MultiSoundManager.playRandomSoundByItself(x, y, "glass_break", FlxG.random.float(0.8, 1.2));
		shards.start(true, 0.1, 0);
		super.onOverlapWithEntity(entity);
	}

	override function update(elapsed:Float)
	{
		shards.x = x;
		shards.y = y;
		if (broken)
		{
			animation.play("broken");
		}
		else
		{
			animation.play("full");
		}
		dontPickUp -= elapsed;
		super.update(elapsed);
		shards.update(elapsed);
		if (hitEntity)
		{
			this.kill();
		}
	}

	override function draw()
	{
		super.draw();
		shards.draw();
	}
}