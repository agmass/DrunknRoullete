package entity;

import abilities.attributes.Attribute;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import input.InputSource;
import input.KeyboardSource;
class PlayerEntity extends Entity {

    public var input:InputSource = new KeyboardSource();
    public var jumps = 0;
    public var dashMovement = new FlxPoint();
    public var lastNonZeroInput = new FlxPoint();
    public var showPlayerMarker = false;
    public var playerMarkerColor:FlxColor = null;

    public var poofParticles = new FlxEmitter();

    override public function new(x,y) {
        super(x,y);
        makeGraphic(32,32,FlxColor.BLUE);
        acceleration.y = 900;
        maxVelocity.y = 900;
        drag.x = 1200;
        debugTracker.set("Jumps", "jumps");

        poofParticles.makeParticles(13,13);
        poofParticles.angle.set(-360,360);
        poofParticles.alpha.set(1,1,0,0);
        poofParticles.lifespan.set(0.55,0.65);
    }

    override function createAttributes() {
        super.createAttributes();
        attributes.set(Attribute.MOVEMENT_SPEED, new Attribute(450));
        attributes.set(Attribute.JUMP_HEIGHT, new Attribute(500));
        attributes.set(Attribute.JUMP_COUNT, new Attribute(1));
    }

    override function update(elapsed:Float) {

        // call update() for children here

        input.update();
        poofParticles.update(elapsed);

        //

        if (FlxG.keys.justPressed.O) {
            attributes.set(Attribute.DASH_SPEED, new Attribute(250));
            attributes.set(Attribute.JUMP_COUNT, new Attribute(10));
        }
        var SPEED = attributes.get(Attribute.MOVEMENT_SPEED).getValue();
        var JUMP_HEIGHT = attributes.get(Attribute.JUMP_HEIGHT).getValue();
        squash(isTouching(FLOOR), elapsed);
        var inputVelocity = input.getMovementVector();
        acceleration.x = inputVelocity.x*(SPEED*6);
        maxVelocity.x = SPEED*Math.abs(inputVelocity.x);

        if (!inputVelocity.isZero()) {
            lastNonZeroInput = inputVelocity;
        }


        var JUMP_COUNT = attributes.get(Attribute.JUMP_COUNT).getValue();
        if (isTouching(FLOOR)) jumps = Math.floor(JUMP_COUNT);

        if (jumps >= 1 && (input.jumpJustPressed || (isTouching(FLOOR) && input.jumpPressed))) {
            jumps--;
            if (!dashMovement.isZero() && inputVelocity.x != 0 && isTouching(FLOOR)) {
                // JumpDash Code
                var scale = Math.max(Math.min(Math.abs(dashMovement.x)/100, 1.5), 0);
                if (scale >= 1) {
                    velocity.y = (-JUMP_HEIGHT)/scale;
                }
                if (dashMovement.y > 0) {
                    velocity.y = (-dashMovement.y)*2;
                } else {
                    dashMovement.x *= scale;
                }
            } else {
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

        if (inputVelocity.y > 0.25 && !input.jumpPressed && !(attributes.exists(Attribute.DASH_SPEED) && input.dashPressed)) {
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
            }
        }
        if (attributes.exists(Attribute.DASH_SPEED)) {
            var DASH_SPEED = attributes.get(Attribute.DASH_SPEED).getValue();
            if (input.dashJustPressed) {
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


	public function squash(grounded,elapsed:Float) {
		if (grounded) {
			if (elapsed == -9) {
				scale.set(1,1);
			} else {
				scale.set(Math.min(scale.x+(elapsed*7),1),1);
			}
		} else {
			if (dashMovement.x > 70 || dashMovement.y > 70) {
				scale.set(1,1);

			} else {
				scale.set(
					Math.min(Math.max(scale.x-(velocity.y/2000),0.5),1)
					,Math.min(Math.max(scale.y+(velocity.y/2000),1),1.5));
			}
		}
	}

    override function toString():String {
        return super.toString() + "\n   Input:"+ input.toString();
    }

    var playerMarker:FlxSprite = new FlxSprite(0,0,AssetPaths.player_marker__png);

    override function draw() {
        if (showPlayerMarker) {
            playerMarker.x = x;
            playerMarker.y = getGraphicBounds().y-14;
            playerMarker.color = playerMarkerColor;
            playerMarker.draw();
        }
        super.draw();
        poofParticles.draw();
    }
}