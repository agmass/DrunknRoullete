package entity;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import input.InputSource;
import input.KeyboardSource;
import sound.FootstepManager;
class PlayerEntity extends EquippedEntity
{

    public var input:InputSource = new KeyboardSource();
    public var jumps = 0;
	public var canDash = false;
    public var dashMovement = new FlxPoint();
    public var lastNonZeroInput = new FlxPoint();
    public var showPlayerMarker = false;
	public var playerMarkerColor:FlxColor = FlxColor.TRANSPARENT;

    public var poofParticles = new FlxEmitter();

	public var crouchAttribute_x:AttributeContainer = new AttributeContainer(FIRST_ADD, 0.1);
	public var crouchAttribute_speed:AttributeContainer = new AttributeContainer(MULTIPLY, 0.5);
	public var crouchAttribute_y:AttributeContainer = new AttributeContainer(FIRST_ADD, -0.25);

	override public function new(x, y, username)
	{
        super(x,y);
        makeGraphic(32,32,FlxColor.BLUE);
        acceleration.y = 900;
        maxVelocity.y = 900;
        drag.x = 1200;
        debugTracker.set("Jumps", "jumps");
		debugTracker.set("Can Dash", "canDash");

        poofParticles.makeParticles(13,13);
        poofParticles.angle.set(-360,360);
        poofParticles.alpha.set(1,1,0,0);
        poofParticles.lifespan.set(0.55,0.65);
		manuallyUpdateSize = true;
		typeTranslationKey = "player";
		entityName = username;
    }

    override function createAttributes() {
        super.createAttributes();
		attributes.set(Attribute.SIZE_X, new Attribute(1));
		attributes.set(Attribute.SIZE_Y, new Attribute(1));
		attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(450));
		attributes.set(Attribute.JUMP_HEIGHT, new Attribute(500));
		attributes.set(Attribute.JUMP_COUNT, new Attribute(1));
    }

	var wasGrounded = false;

    override function update(elapsed:Float) {

        // call update() for children here

        input.update();
        poofParticles.update(elapsed);

        //

		var newWidth = (32 * attributes.get(Attribute.SIZE_X).getValue());
		var newHeight = (32 * attributes.get(Attribute.SIZE_Y).getValue());
		y += height - newHeight;
		x += (width - newWidth) / 2;
		setSize(newWidth, newHeight);
		scale.set(attributes.get(Attribute.SIZE_X).getValue(), attributes.get(Attribute.SIZE_Y).getValue());
		offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
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


		var JUMP_COUNT = attributes.get(Attribute.JUMP_COUNT).getValue();
		if (isTouching(FLOOR))
		{
			if (!wasGrounded)
			{
				FootstepManager.playFootstepForEntity(this);
				poofParticles.x = getMidpoint().x;
				poofParticles.y = getGraphicBounds().bottom + 2;
				poofParticles.speed.set(50, 50, 0, 0);
				poofParticles.scale.set(0.8, 0.8, 1.2, 1.2, 0.2, 0.2, 0.2, 0.2);
				poofParticles.launchAngle.set(180, 0);
				poofParticles.start(true, 0.1, FlxG.random.int(3, 6));
			}
			jumps = Math.floor(JUMP_COUNT);
			canDash = true;
			angle = 0;
		}
		else
		{
			angle = (velocity.x + dashMovement.x) / 350;
		}
		wasGrounded = isTouching(FLOOR);

		// cro uch :3

		if (isTouching(FLOOR) && inputVelocity.y > 0.1)
		{
			attributes.get(Attribute.SIZE_X).addOperation(crouchAttribute_x);
			attributes.get(Attribute.SIZE_Y).addOperation(crouchAttribute_y);
			attributes.get(Attribute.MOVEMENT_SPEED).addOperation(crouchAttribute_speed);
			attributes.get(Attribute.JUMP_HEIGHT).addOperation(crouchAttribute_speed);
		}
		else if (attributes.get(Attribute.SIZE_X).containsOperation(crouchAttribute_x))
		{
			attributes.get(Attribute.SIZE_X).removeOperation(crouchAttribute_x);
			attributes.get(Attribute.SIZE_Y).removeOperation(crouchAttribute_y);
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
            poofParticles.x = getMidpoint().x;
            poofParticles.y = getGraphicBounds().bottom-8;
            poofParticles.speed.set(50,50,0,0);
            poofParticles.scale.set(0.8,0.8,1.2,1.2,0.2,0.2,0.2,0.2);
            poofParticles.launchAngle.set(-180, 0);
            poofParticles.start(true, 0.1, FlxG.random.int(3,6));
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
            }
        }

        if (dashMovement.x < 0 && velocity.x > 0 || dashMovement.x > 0 && velocity.x < 0) {
            dashMovement.x = FlxMath.lerp(dashMovement.x, 0, elapsed*3);
        }
        if (dashMovement.y < 0 && velocity.y > 0 || dashMovement.y > 0 && velocity.y < 0) {
            dashMovement.y = FlxMath.lerp(dashMovement.y, 0, elapsed*3);
        }
        
        super.update(elapsed);
        if (!dashMovement.isZero()) {
            x += dashMovement.x*(elapsed*8);
            y += dashMovement.y*(elapsed*8);
            dashMovement.x -= dashMovement.x*(elapsed*8);
            dashMovement.y -= dashMovement.y*(elapsed*8);
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
			} else {
				var newX = Math.min(scale.x + (elapsed * 7), SCALE_X);
				if (scale.x > SCALE_X)
				{
					newX = Math.max(scale.x - (elapsed * 7), SCALE_X);
				}
				var newY = Math.min(scale.y + (elapsed * 7), SCALE_Y);
				if (scale.y > SCALE_Y)
				{
					newY = Math.max(scale.y - (elapsed * 7), SCALE_Y);
				}
				scale.set(newX, newY);
			}
		} else {
			if (dashMovement.x > 70 || dashMovement.y > 70) {
				scale.set(SCALE_X, SCALE_Y);

			} else {
				scale.set(
				Math.min(Math.max(scale.x - (velocity.y / 2000), SCALE_X / 2), SCALE_X),
					Math.min(Math.max(scale.y + (velocity.y / 2000), SCALE_Y), SCALE_Y + (SCALE_Y / 2)));
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
        super.draw();
        poofParticles.draw();
    }
}