package objects.hitbox;

import abilities.attributes.Attribute;
import entity.Entity;
import entity.EquippedEntity;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import objects.hitbox.Hitbox;
import sound.FootstepManager.MultiSoundManager;

class FriendlyExplosionHitbox extends Hitbox
{
	var particles:FlxEmitter = new FlxEmitter();

	override public function new(x, y, size)
	{
		super(x, y);
		damage = 35;
		makeGraphic(196, 196, FlxColor.TRANSPARENT);
		particles.makeParticles(24, 24);
		particles.color.set(FlxColor.CYAN.getDarkened(0.1), FlxColor.CYAN.getLightened(0.1), FlxColor.GRAY.getDarkened(0.1), FlxColor.GRAY.getDarkened(0.2));
		particles.alpha.set(1, 1, 0, 0);
		particles.speed.set(10, 160, 0, 0);
		particles.lifespan.set(0.9, 1.1);
		particles.start(true, 0, 40);
		updateHitbox();
		MultiSoundManager.playRandomSoundByItself(x, y, "explosion");
	}

	var timeLived = 0.0;

	override function onHit(victim:Entity)
	{
		if (timeLived > 0.4)
			return;
		if (victim is EquippedEntity)
		{
			var eq:EquippedEntity = cast(victim);
			eq.velocity.y = -350;
			eq.extraVelocity = eq.getMidpoint().add(getMidpoint().negate().x, getMidpoint().negate().y).scale(1.6);
		}
		hitEntities.push(victim);
	}

	override function update(elapsed:Float)
	{
		timeLived += elapsed;
		if (timeLived > 1.1)
		{
			alive = false;
			inactive = true;
		}
		particles.x = getMidpoint().x;
		particles.y = getMidpoint().y;
		particles.update(elapsed);
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		particles.draw();
	}
}