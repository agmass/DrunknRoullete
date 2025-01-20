package entity;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.equipment.items.BasicProjectileShootingItem;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.FlxTrail;
import flixel.effects.particles.FlxEmitter;
import flixel.graphics.atlas.TexturePackerAtlas;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import input.InputSource;
import input.KeyboardSource;
import objects.hitbox.Hitbox;
import openfl.filters.ShaderFilter;
import shader.FadingOut;
import sound.FootstepManager;
class PlayerEntity extends HumanoidEntity
{

    public var input:InputSource = new KeyboardSource();
    public var jumps = 0;
	public var canDash = false;
    public var dashMovement = new FlxPoint();
    public var lastNonZeroInput = new FlxPoint();
    public var showPlayerMarker = false;
	public var playerMarkerColor:FlxColor = FlxColor.TRANSPARENT;

	// public var ghostParticles = new FlxEmitter();
	public var toDraw:FlxSpriteGroup = new FlxSpriteGroup();

	public var crouching = false;
	public var trail:FlxTrail;

	public var crouchAttribute_speed:AttributeContainer = new AttributeContainer(MULTIPLY, 0.5);
	public var HITBOX_X = 38;
	public var HITBOX_Y = 68;

	public var GRAPHIC_X = 64;
	public var GRAPHIC_Y = 80;
	override public function new(x, y, username)
	{
        super(x,y);
		// makeGraphic(32, 32, FlxColor.WHITE);
		loadGraphic(AssetPaths.goober__png, true, 40, 69);
		animation.add("idle", [0]);
		animation.add("walk", [1, 0, 2, 0], 3);
		animation.add("idle_no_weapon", [3]);
		animation.add("walk_no_weapon", [4, 3, 5, 3], 3);
        debugTracker.set("Jumps", "jumps");
		debugTracker.set("Can Dash", "canDash");
		trail = new FlxTrail(this, null, 4, 4, 0.8, 0.25);

		// color = FlxColor.BLUE;

		manuallyUpdateSize = true;
		typeTranslationKey = "player";
		entityName = username;
		holsteredWeapon = new BasicProjectileShootingItem(this);
    }

    override function createAttributes() {
		super.createAttributes();
		// attributes.set(Attribute.DASH_SPEED, new Attribute(250));
		attributes.set(Attribute.JUMP_HEIGHT, new Attribute(500));
		attributes.set(Attribute.CROUCH_SCALE, new Attribute(0.75));
		attributes.set(Attribute.JUMP_COUNT, new Attribute(1));
    }

	var trailFade = 0.0;

    override function update(elapsed:Float) {

		if (ragdoll != null)
		{
			healthBar.alpha = 0;
			super.update(elapsed);
			return;
		}
		if (lastHealth != health || health < 20)
		{
			healthBar.alpha = 1;
		}

        // call update() for children here
		// my ex-wife still wont let me see the kids -adi

		if (trail != null)
			trail.update(elapsed);

		if (input.backslotJustPressed)
		{
			var backslotWeapon = holsteredWeapon;
			holsteredWeapon = handWeapon;
			handWeapon = backslotWeapon;
			switchingAnimation = 0.5;
		}

		if (handWeapon != null)
		{
			handWeapon.equipped = true;
			if (input.attackPressed)
			{
				if (timeUntilAttack <= 0)
				{
					timeUntilAttack = handWeapon.weaponSpeed * attributes.get(Attribute.ATTACK_SPEED).getValue();
					handWeapon.attack(this);
				}
			}
			if (input.altFirePressed)
			{
				handWeapon.alt_fire(this);
			}
			if (switchingAnimation > 0)
			{
				handWeapon.angle = FlxMath.lerp(input.getLookAngle(getPosition()) - 90, handWeapon.flipX ? 45 : -45, switchingAnimation * 2);
			}
			else
			{
				handWeapon.angle = input.getLookAngle(getPosition()) - 90;
			}
		}

		if (holsteredWeapon != null)
		{
			holsteredWeapon.equipped = false;
			if (switchingAnimation > 0)
			{
				holsteredWeapon.angle = FlxMath.lerp(holsteredWeapon.flipX ? 45 : -45, input.getLookAngle(getPosition()) - 90, switchingAnimation * 2);
			}
		}
		var newWidth = (HITBOX_X * attributes.get(Attribute.SIZE_X).getValue());
		var newHeight = (HITBOX_Y * attributes.get(Attribute.SIZE_Y).getValue());



		if (crouching)
		{
			newHeight -= ((1 - attributes.get(Attribute.CROUCH_SCALE).getValue()) * HITBOX_X) * 1.2;
		}
		y += height - newHeight;
		x += (width - newWidth) / 2;
		setSize(newWidth, newHeight);
		centerOrigin();
		squash(isTouching(FLOOR), elapsed);
		offset.set(-0.5 * (newWidth - frameWidth), (-0.5 * (newHeight - frameHeight)) - 1);
		if (!crouching)
		{
			offset.y -= (newHeight) - getGraphicBounds().height;
		}

		var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
		var JUMP_HEIGHT = attributes.get(Attribute.JUMP_HEIGHT).getValue();
        var inputVelocity = input.getMovementVector();
        acceleration.x = inputVelocity.x*(SPEED*6);
        maxVelocity.x = SPEED*Math.abs(inputVelocity.x);

        if (!inputVelocity.isZero()) {
			animation.play("walk" + ((handWeapon != null && !handWeapon.changePlayerAnimation) ? "" : "_no_weapon"));
			animation.timeScale = Math.abs(velocity.x) / 80;
			lastNonZeroInput = inputVelocity;
		}
		else
		{
			animation.play("idle" + ((handWeapon != null && !handWeapon.changePlayerAnimation) ? "" : "_no_weapon"));
		}
		flipX = input.getLookAngle(getPosition()) < 90 && input.getLookAngle(getPosition()) > -90;


		var JUMP_COUNT = attributes.get(Attribute.JUMP_COUNT).getValue();
		if (isTouching(FLOOR))
		{
			jumps = Math.floor(JUMP_COUNT);
			canDash = true;
			angle = 0;
		}
		else
		{
			angle = (velocity.x + dashMovement.x + extraVelocity.x) / 350;
		}

		// cro uch :3

		if (isTouching(FLOOR) && inputVelocity.y > 0.1)
		{
			crouching = true;
			attributes.get(Attribute.MOVEMENT_SPEED).addOperation(crouchAttribute_speed);
			attributes.get(Attribute.JUMP_HEIGHT).addOperation(crouchAttribute_speed);
		}
		else if (crouching)
		{
			crouching = false;
			attributes.get(Attribute.MOVEMENT_SPEED).removeOperation(crouchAttribute_speed);
			attributes.get(Attribute.JUMP_HEIGHT).removeOperation(crouchAttribute_speed);
		}

        if (jumps >= 1 && (input.jumpJustPressed || (isTouching(FLOOR) && input.jumpPressed))) {
            jumps--;
            if (!dashMovement.isZero() && inputVelocity.x != 0 && isTouching(FLOOR)) {
                // JumpDash Code
                var scale = Math.max(Math.min(Math.abs(dashMovement.x)/100, 1.5), 0);
				velocity.y = (-JUMP_HEIGHT) / 2;
                if (dashMovement.y > 0) {
                    velocity.y = (-dashMovement.y)*2;
                } else {
                    dashMovement.x *= scale;
                }
            } else {
				MultiSoundManager.playFootstepForEntity(this);
                velocity.y = -JUMP_HEIGHT;
            }
			jumpParticles();
        }

        // Ground Pound

		if (inputVelocity.y > 0.25 && !input.jumpPressed && !(attributes.exists(Attribute.DASH_SPEED) && input.dashPressed))
		{
            velocity.y = maxVelocity.y;
            maxVelocity.y = 1200;
        } else {
            maxVelocity.y = 900;
        }

        // Dash Code

        if (!dashMovement.isZero()) {
            if (isTouching(FLOOR) && dashMovement.y > 0) {
                dashMovement.y = 0;
            }
            if (isTouching(FLOOR) || isTouching(UP)) {
                dashMovement.y *= -1;
            }
            if (isTouching(WALL)) {
                dashMovement.x *= -1;
				jumps = Math.floor(JUMP_COUNT);
				canDash = true;
            }
        }
		if (attributes.exists(Attribute.DASH_SPEED) && canDash)
		{
			var DASH_SPEED = attributes.get(Attribute.DASH_SPEED).getValue();
            if (input.dashJustPressed) {
				canDash = false;
                velocity.x = lastNonZeroInput.x;
                velocity.y  = lastNonZeroInput.y;
                dashMovement.x = lastNonZeroInput.x;
                dashMovement.y = lastNonZeroInput.y;
                dashMovement = dashMovement.normalize()*DASH_SPEED;
				MultiSoundManager.playRandomSound(this, "dash", 0.9, 0.5);
				FlxG.camera.shake(0.0075, 0.075);
            }
        }

        if (dashMovement.x < 0 && velocity.x > 0 || dashMovement.x > 0 && velocity.x < 0) {
            dashMovement.x = FlxMath.lerp(dashMovement.x, 0, elapsed*3);
        }
        if (dashMovement.y < 0 && velocity.y > 0 || dashMovement.y > 0 && velocity.y < 0) {
			dashMovement.y = FlxMath.lerp(dashMovement.y, 0, elapsed * 3);
		}

		healthBar.alpha -= elapsed * 0.35;
		// health bar


        super.update(elapsed);
        if (!dashMovement.isZero()) {
            x += dashMovement.x*(elapsed*8);
            y += dashMovement.y*(elapsed*8);
            dashMovement.x -= dashMovement.x*(elapsed*8);
			dashMovement.y -= dashMovement.y * (elapsed * 8);
		}
    }

	override function kill()
	{
		trail.destroy();
		super.kill();
	}


	public function squash(grounded, elapsed:Float)
	{
		var SCALE_X = attributes.get(Attribute.SIZE_X).getValue();
		var SCALE_Y = attributes.get(Attribute.SIZE_Y).getValue();
		var crouchSquish = 1.0;
		if (crouching)
			crouchSquish = 1 + ((attributes.get(Attribute.CROUCH_SCALE).getValue()) * 0.5);
		if (grounded) {
			if (elapsed == -9) {
				scale.set(SCALE_X, SCALE_Y);
				// reused taglayer code so this is left here until i implement online
			}
			else
			{
				if (scale.x > SCALE_X)
				{
					scale.x = FlxMath.lerp(scale.x, (width / HITBOX_X) * crouchSquish, elapsed * 11);
				}
				if (scale.x < SCALE_X)
				{
					scale.x = FlxMath.lerp(scale.x, (width / HITBOX_X) * crouchSquish, elapsed * 11);
				}
				if (scale.y > SCALE_Y)
				{
					scale.y = FlxMath.lerp(scale.y, height / HITBOX_Y, elapsed * 11);
				}
				if (scale.y < SCALE_Y)
				{
					scale.y = FlxMath.lerp(scale.y, height / HITBOX_Y, elapsed * 11);
				}
			}
		} else {
			if (dashMovement.x > 70 || dashMovement.y > 70)
			{
				scale.set(SCALE_X, SCALE_Y);

			}
			else
			{
				scale.set(
				FlxMath.lerp(scale.x, SCALE_X / 1.15, elapsed * (Math.abs(velocity.y) / 100)),
					FlxMath.lerp(scale.y, SCALE_Y * 1.15, elapsed * (Math.abs(velocity.y) / 100)));
			}
		}
		trail.visible = trailFadeOut.alphaFade.value[0] < 0.0;
		if (Math.abs(dashMovement.x) + Math.abs(dashMovement.y) < 30)
		{
			trailFadeOut.alphaFade.value[0] -= elapsed * 3;
			for (sprite in trail.members)
			{
				sprite.shader = trailFadeOut;
			}
		}
		else
		{
			trailFadeOut.alphaFade.value[0] = 1;
		}
	}

	var trailFadeOut = new FadingOut();

    override function toString():String {
        return super.toString() + "\n   Input:"+ input.toString();
    }

    var playerMarker:FlxSprite = new FlxSprite(0,0,AssetPaths.player_marker__png);

    override function draw() {
		healthBar.x = getMidpoint().x - (healthBar.width / 2);
		healthBar.y = getGraphicBounds().y - 12;

		healthBar.scale.set(0.25, 0.25);
		healthBar.updateHitbox();
        if (showPlayerMarker) {
			playerMarker.x = getMidpoint().x - (14 / 2);
			if (healthBar.alpha > 0)
			{
				playerMarker.y = healthBar.getGraphicBounds().y - 14;
			}
			else
			{
				playerMarker.y = getGraphicBounds().y - 14;
			}
            playerMarker.color = playerMarkerColor;
            playerMarker.draw();
        }
		if (trail != null)
			trail.draw();
		super.draw();
		healthBar.draw();
    }
}