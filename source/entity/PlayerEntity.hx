package entity;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import input.InputSource;
import input.KeyboardSource;
import objects.hitbox.Hitbox;
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

	public var ghostParticles = new FlxEmitter();

	public var crouching = false;

	public var crouchAttribute_speed:AttributeContainer = new AttributeContainer(MULTIPLY, 0.5);

	override public function new(x, y, username)
	{
        super(x,y);
		makeGraphic(32, 32, FlxColor.WHITE);
        debugTracker.set("Jumps", "jumps");
		debugTracker.set("Can Dash", "canDash");

		ghostParticles.makeParticles(1, 1, FlxColor.WHITE, 500);
		ghostParticles.alpha.set(1, 1, 0);
		ghostParticles.lifespan.set(0.35);

		ghostParticles.start(false, 0.1, 500);
		ghostParticles.emitting = false;

		color = FlxColor.BLUE;

		manuallyUpdateSize = true;
		typeTranslationKey = "player";
		entityName = username;
    }

    override function createAttributes() {
		super.createAttributes();
		attributes.set(Attribute.DASH_SPEED, new Attribute(250));
		attributes.set(Attribute.JUMP_HEIGHT, new Attribute(500));
		attributes.set(Attribute.CROUCH_SCALE, new Attribute(0.2));
		attributes.set(Attribute.JUMP_COUNT, new Attribute(1));
    }

    override function update(elapsed:Float) {

        // call update() for children here
		// my ex-wife still wont let me see the kids -adi

		input.update();
		ghostParticles.update(elapsed);

		// Weapons

		if (input.backslotJustPressed)
		{
			var backslotWeapon = holsteredWeapon;
			holsteredWeapon = handWeapon;
			handWeapon = backslotWeapon;
			switchingAnimation = 0.5;
		}

		if (handWeapon != null)
		{
			if (input.attackPressed)
			{
				if (timeUntilAttack <= 0)
				{
					timeUntilAttack = handWeapon.weaponSpeed * attributes.get(Attribute.ATTACK_SPEED).getValue();
					handWeapon.attack(this);
				}
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
			if (switchingAnimation > 0)
			{
				holsteredWeapon.angle = FlxMath.lerp(holsteredWeapon.flipX ? 45 : -45, input.getLookAngle(getPosition()) - 90, switchingAnimation * 2);
			}
		}
		var newWidth = (32 * attributes.get(Attribute.SIZE_X).getValue());
		var newHeight = (32 * attributes.get(Attribute.SIZE_Y).getValue());
		if (crouching)
		{
			newHeight -= (1 - attributes.get(Attribute.CROUCH_SCALE).getValue()) * 32;
			newWidth += (1.15 - attributes.get(Attribute.CROUCH_SCALE).getValue()) * 32;
		}
		y += height - newHeight;
		x += (width - newWidth) / 2;
		setSize(newWidth, newHeight);
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
		if (!crouching)
			offset.y -= (newHeight) - getGraphicBounds().height;
		centerOrigin();
		squash(isTouching(FLOOR), elapsed);

		var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
		var JUMP_HEIGHT = attributes.get(Attribute.JUMP_HEIGHT).getValue();
        var inputVelocity = input.getMovementVector();
        acceleration.x = inputVelocity.x*(SPEED*6);
        maxVelocity.x = SPEED*Math.abs(inputVelocity.x);

        if (!inputVelocity.isZero()) {
			lastNonZeroInput = inputVelocity;
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
			angle = (velocity.x + dashMovement.x) / 350;
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
				FootstepManager.playFootstepForEntity(this);
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

		ghostParticles.x = getMidpoint().x;
		ghostParticles.y = getMidpoint().y;

		ghostParticles.color.set(color);
		ghostParticles.scale.set(getGraphicBounds().width, getGraphicBounds().height);
		ghostParticles.angle.set(angle);
		ghostParticles.speed.set(0);
		ghostParticles.emitting = Math.abs(dashMovement.x) + Math.abs(dashMovement.y) > 5;

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
				FlxG.camera.shake(0.0075, 0.075);
            }
        }

        if (dashMovement.x < 0 && velocity.x > 0 || dashMovement.x > 0 && velocity.x < 0) {
            dashMovement.x = FlxMath.lerp(dashMovement.x, 0, elapsed*3);
        }
        if (dashMovement.y < 0 && velocity.y > 0 || dashMovement.y > 0 && velocity.y < 0) {
			dashMovement.y = FlxMath.lerp(dashMovement.y, 0, elapsed * 3);
		}

        super.update(elapsed);
        if (!dashMovement.isZero()) {
            x += dashMovement.x*(elapsed*8);
            y += dashMovement.y*(elapsed*8);
            dashMovement.x -= dashMovement.x*(elapsed*8);
			dashMovement.y -= dashMovement.y * (elapsed * 8);
		}
    }


	public function squash(grounded, elapsed:Float)
	{
		var SCALE_X = attributes.get(Attribute.SIZE_X).getValue();
		var SCALE_Y = attributes.get(Attribute.SIZE_Y).getValue();
		if (grounded) {
			if (elapsed == -9) {
				scale.set(SCALE_X, SCALE_Y);
				// reused taglayer code so this is left here until i implement online
			}
			else
			{
				if (scale.x > SCALE_X)
				{
					scale.x = FlxMath.lerp(scale.x, width / 32, elapsed * 11);
				}
				if (scale.x < SCALE_X)
				{
					scale.x = FlxMath.lerp(scale.x, width / 32, elapsed * 11);
				}
				if (scale.y > SCALE_Y)
				{
					scale.y = FlxMath.lerp(scale.y, height / 32, elapsed * 11);
				}
				if (scale.y < SCALE_Y)
				{
					scale.y = FlxMath.lerp(scale.y, height / 32, elapsed * 11);
				}
			}
		} else {
			if (dashMovement.x > 70 || dashMovement.y > 70 || velocity.y < 0)
			{
				scale.set(SCALE_X, SCALE_Y);

			} else {
				if (velocity.y > 0)
				{
					scale.set(
					FlxMath.lerp(scale.x, SCALE_X / 1.5, elapsed * (velocity.y / 100)),
						FlxMath.lerp(scale.y, SCALE_Y * 1.5, elapsed * (velocity.y / 100)));
				}
			}
		}
	}

    override function toString():String {
        return super.toString() + "\n   Input:"+ input.toString();
    }

    var playerMarker:FlxSprite = new FlxSprite(0,0,AssetPaths.player_marker__png);

    override function draw() {
        if (showPlayerMarker) {
			playerMarker.x = getMidpoint().x - (14 / 2);
            playerMarker.y = getGraphicBounds().y-14;
            playerMarker.color = playerMarkerColor;
            playerMarker.draw();
        }
		ghostParticles.draw();
		super.draw();
    }
}