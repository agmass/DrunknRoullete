package entity;

import abilities.attributes.Attribute;
import abilities.equipment.Equipment;
import abilities.equipment.items.SwordItem;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import objects.hitbox.Hitbox;
import util.Projectile;

class EquippedEntity extends Entity
{
	public var handWeapon:Equipment;
	public var holsteredWeapon:Equipment;
	public var hitboxes:FlxTypedSpriteGroup<Hitbox> = new FlxTypedSpriteGroup();
	public var collideables:FlxTypedSpriteGroup<Projectile> = new FlxTypedSpriteGroup<Projectile>();

	public var switchingAnimation = 0.0;
	public var timeUntilAttack = 0.0;
	public var extraVelocity:FlxPoint = new FlxPoint();

	override public function new(x, y)
	{
		super(x, y);
		// handWeapon = new SwordItem(this);
	}
	override function createAttributes()
	{
		super.createAttributes();
		attributes.set(Attribute.ATTACK_DAMAGE, new Attribute(1));
		attributes.set(Attribute.ATTACK_KNOCKBACK, new Attribute(1));
		attributes.set(Attribute.ATTACK_SPEED, new Attribute(1));
	}

	override function update(elapsed:Float)
	{
		switchingAnimation -= elapsed * (1 + (switchingAnimation * 3));
		hitboxes.update(elapsed);

		for (hitbox in hitboxes)
		{
			if (hitbox.inactive)
			{
				hitboxes.remove(hitbox);
				hitbox.destroy();
			}
		}
		timeUntilAttack -= elapsed;
		if (handWeapon != null)
		{
			handWeapon.equipped = true;
			handWeapon.update(elapsed);
		}
		if (holsteredWeapon != null)
		{
			holsteredWeapon.equipped = false;
			holsteredWeapon.update(elapsed);
		}
		if (!extraVelocity.isZero())
		{
			if (isTouching(FLOOR) || isTouching(UP))
			{
				extraVelocity.y *= 0;
			}
			if (isTouching(WALL))
			{
				extraVelocity.x *= 0;
			}
		}
		if (extraVelocity.x < 0 && velocity.x > 0 || extraVelocity.x > 0 && velocity.x < 0)
		{
			extraVelocity.x = FlxMath.lerp(extraVelocity.x, 0, elapsed * 6);
		}
		if (extraVelocity.y < 0 && velocity.y > 0 || extraVelocity.y > 0 && velocity.y < 0)
		{
			extraVelocity.y = FlxMath.lerp(extraVelocity.y, 0, elapsed * 6);
		}
        
		super.update(elapsed);
		if (!extraVelocity.isZero())
		{
			x += extraVelocity.x * (elapsed * 4);
			y += extraVelocity.y * (elapsed * 4);
			extraVelocity.x -= extraVelocity.x * (elapsed * 4);
			extraVelocity.y -= extraVelocity.y * (elapsed * 4);
		}
	}

	override function draw()
	{
		if (ragdoll != null)
		{
			ragdoll.draw();
			blood.draw();
			floatingTexts.draw();
			return;
		}
		if (holsteredWeapon != null)
		{
			holsteredWeapon.x = getGraphicMidpoint().x - (holsteredWeapon.width / 2);
			holsteredWeapon.y = getGraphicMidpoint().y - (holsteredWeapon.height / 2);
			holsteredWeapon.flipX = flipX;
			if (switchingAnimation <= 0)
			{
				if (holsteredWeapon.flipX)
				{
					holsteredWeapon.angle = 45;
				}
				else
				{
					holsteredWeapon.angle = -45;
				}
			}
			else
			{
				holsteredWeapon.x += FlxMath.lerp(holsteredWeapon.flipX ? -8 : 8, 0, (Math.abs(0.5 - switchingAnimation) * 2));
			}
			holsteredWeapon.scale.x = attributes.get(Attribute.SIZE_X).getValue() * holsteredWeapon.weaponScale;
			holsteredWeapon.scale.y = attributes.get(Attribute.SIZE_Y).getValue() * holsteredWeapon.weaponScale;
			if (holsteredWeapon.weaponScale != 1)
				holsteredWeapon.updateHitbox();
			if (switchingAnimation < 0.25)
				holsteredWeapon.draw();
		}
		if (handWeapon != null)
		{
			if (switchingAnimation > 0.25)
				handWeapon.draw();
		}
		hitboxes.draw();
		super.draw();
		if (handWeapon != null)
		{
			handWeapon.x = getGraphicMidpoint().x - (handWeapon.width / 2);
			handWeapon.y = getGraphicMidpoint().y - (handWeapon.height / 2);
			handWeapon.flipX = flipX;
			handWeapon.scale.x = attributes.get(Attribute.SIZE_X).getValue() * handWeapon.weaponScale;
			handWeapon.scale.y = attributes.get(Attribute.SIZE_Y).getValue() * handWeapon.weaponScale;
			if (handWeapon.weaponScale != 1)
				handWeapon.updateHitbox();
			if (switchingAnimation <= 0)
			{
				if (handWeapon.flipX)
				{
					handWeapon.x -= 8;
				}
				else
				{
					handWeapon.x += 8;
				}
			}
			else
			{
				handWeapon.x += FlxMath.lerp(0, handWeapon.flipX ? -8 : 8, (Math.abs(0.5 - switchingAnimation) * 2));
			}
			if (switchingAnimation < 0.25)
				handWeapon.draw();
		}
		if (holsteredWeapon != null)
		{
			if (switchingAnimation > 0.25)
				holsteredWeapon.draw();
		}
	}
}