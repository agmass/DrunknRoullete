package entity.bosses;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import abilities.equipment.Equipment;
import abilities.equipment.items.BasicProjectileShootingItem;
import abilities.equipment.items.Gamblevolver;
import abilities.equipment.items.SwordItem;
import flixel.FlxG;
import flixel.addons.nape.FlxNapeSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import input.ModifiableInputSource;
import sound.FootstepManager.MultiSoundManager;
import util.Language;

class RobotBoss extends PlayerEntity
{
	var behaviourState = 0;
	var lives = 1;
	var downtime = 1.0;
	var modifiable:ModifiableInputSource = new ModifiableInputSource();

	override public function new(x, y)
	{
		super(x, y, Language.get("entity.robot"));
		color = FlxColor.GRAY;
		input = modifiable;
		rewards = new Rewards(FlxG.random.int(5, 6), true);
		var array:Array<Class<Equipment>> = [SwordItem, BasicProjectileShootingItem, Gamblevolver];
		handWeapon = Type.createInstance(array[FlxG.random.int(0, 2)], [this]);
		typeTranslationKey = "robot";
		bossHealthBar = true;
		usePlayerVolume = false;
	}

	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.ATTACK_SPEED,
			new Attribute(1 + FlxG.random.float(-0.005 * (Main.run.roomsTraveled), 0.5 + (-0.005 * (Main.run.roomsTraveled))), true));
		attributes.set(Attribute.DASH_SPEED, new Attribute(250 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * (Main.run.roomsTraveled)), true));
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(450 + FlxG.random.int(5 * (Main.run.roomsTraveled - 1), 5 * Main.run.roomsTraveled), true));
		attributes.set(Attribute.MAX_HEALTH, new Attribute(125 + FlxG.random.int(40 * (Main.run.roomsTraveled - 1), 40 * Main.run.roomsTraveled), true));
		attributes.set(Attribute.ATTACK_DAMAGE,
			new Attribute(1.0 + FlxG.random.float(-0.005 * (Main.run.roomsTraveled), 0.5 + (-0.005 * (Main.run.roomsTraveled))), true));
	}

	var downscale = new AttributeContainer(AttributeOperation.MULTIPLY, 0.5);
	var upscale = new AttributeContainer(AttributeOperation.MULTIPLY, 3.4);

	override function update(elapsed:Float)
	{
		if (ragdoll != null)
		{
			super.update(elapsed);
			return;
		}
		if (behaviourState == 1 && health == attributes.get(Attribute.MAX_HEALTH).getValue())
		{
			lives = 2;
			health = 0;
		}
		var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
		var closest:PlayerEntity = null;
		var closestDistance = 900000.0;
		var attackRange = 270;
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
			if (closest != null)
			{
				modifiable.movement = getPosition().addPoint(closest.getPosition().negate()).negate().normalize();
				if (handWeapon is SwordItem)
				{
					var sw = cast(handWeapon, SwordItem);
					if (sw.bottle != null)
					{
						modifiable.movement = getPosition().addPoint(sw.bottle.getPosition().negate()).negate().normalize().scale(1.35);
					}
				}
				if (handWeapon is BasicProjectileShootingItem)
				{
					var sw = cast(handWeapon, BasicProjectileShootingItem);
					if (sw.bullets.length >= sw.maxBullets)
					{
						modifiable.movement = getPosition().addPoint(sw.bullets.getFirstAlive().getPosition().negate())
							.negate()
							.normalize()
							.scale(1.35);
					}
					attackRange = 700;
				}
				if (Math.abs(closest.getPosition().distanceTo(getPosition())) < attackRange)
				{
					modifiable.movement.scale(0.65);
				}
				modifiable.jumpJustPressed = false;
				modifiable.dashJustPressed = false;
				modifiable.dashPressed = false;
				modifiable.jumpPressed = false;
				flipX = closest.x < x;
				modifiable.look = getMidpoint().degreesFrom(closest.getMidpoint());
				if (Math.abs(closest.getPosition().distanceTo(getPosition())) < attackRange && timeUntilAttack <= 0)
				{
					if (FlxG.random.bool(10))
					{
						handWeapon.alt_fire(this);
					}
					else
					{
						timeUntilAttack = (handWeapon.weaponSpeed * attributes.get(Attribute.ATTACK_SPEED).getValue()) + 0.6;
						handWeapon.attack(this);
					}
				}
				modifiable.movement.y = FlxMath.bound(modifiable.movement.y, -1, 0);
				if (Math.abs(closest.getPosition().distanceTo(getPosition())) > attackRange + 120)
				{
					if (dashCooldown < 0)
					{
						modifiable.dashJustPressed = true;
						dashCooldown = 0.3;
						modifiable.dashPressed = true;
					}
				}
				if (modifiable.movement.y < -0.5 && !modifiable.jumpPressed)
					modifiable.jumpJustPressed = true;
				if (modifiable.movement.y < -0.5)
					modifiable.jumpPressed = true;
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
		noclip = false;
		dashCooldown -= elapsed;
		super.update(elapsed);
	}

	var dashCooldown = 0.7;

	override function draw()
	{
		super.draw();
	}
}