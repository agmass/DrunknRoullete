package entity;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import sound.FootstepManager;

class HumanoidEntity extends EquippedEntity
{
	public var poofParticles = new FlxEmitter();
	public var wasGrounded = false;

	override public function new(x, y)
	{
		super(x, y);

		acceleration.y = 900;
		maxVelocity.y = 900;
		drag.x = 1200;
		poofParticles.makeParticles(13, 13);
		poofParticles.angle.set(-360, 360);
		poofParticles.alpha.set(1, 1, 0, 0);
		poofParticles.lifespan.set(0.55, 0.65);
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(450));
		attributes.set(Attribute.SIZE_X, new Attribute(1));
		attributes.set(Attribute.SIZE_Y, new Attribute(1));
	}

	function jumpParticles()
	{
		poofParticles.x = getMidpoint().x;
		poofParticles.y = getGraphicBounds().bottom - 8;
		var sc = attributes.get(Attribute.SIZE_X).getValue();
		poofParticles.speed.set(50 * sc, 50 * sc, 0, 0);
		poofParticles.scale.set(0.8 * sc, 0.8 * sc, 1.2 * sc, 1.2 * sc, 0.2 * sc, 0.2 * sc, 0.2 * sc, 0.2 * sc);
		poofParticles.launchAngle.set(-180, 0);
		poofParticles.start(true, 0.1, FlxG.random.int(3, 6));
	}

	override function update(elapsed:Float)
	{
		poofParticles.update(elapsed);
		if (isTouching(FLOOR) && !wasGrounded)
		{
			var sc = attributes.get(Attribute.SIZE_X).getValue();
			MultiSoundManager.playFootstepForEntity(this);
			poofParticles.x = getMidpoint().x;
			poofParticles.y = getGraphicBounds().bottom + 2;
			poofParticles.speed.set(50 * sc, 50 * sc, 0, 0);
			poofParticles.scale.set(0.8 * sc, 0.8 * sc, 1.2 * sc, 1.2 * sc, 0.2 * sc, 0.2 * sc, 0.2 * sc, 0.2 * sc);
			poofParticles.launchAngle.set(180, 0);
			poofParticles.start(true, 0.1, FlxG.random.int(3, 6));
		}
		wasGrounded = isTouching(FLOOR);
		super.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		poofParticles.draw();
	}
}