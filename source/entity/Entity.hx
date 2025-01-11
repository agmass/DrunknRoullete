package entity;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeType;
import entity.bosses.Rewards;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import haxe.ds.HashMap;
import sound.FootstepManager;
import util.Language;

class Entity extends FlxSprite {

    public var health = 100.0;
	public var attributes:Map<AttributeType, Attribute> = new Map();
	public var entityName = "entity";
	public var typeTranslationKey = "basic";
    public var debugTracker:Map<String, String> = new Map();
	public var manuallyUpdateSize = false;
	public var steppingOn = "concrete";
	public var footstepCount = 0;

	public var pxTillFootstep = 80.0;
	public var blood:FlxEmitter = new FlxEmitter();

	public var healthBar:FlxBar = new FlxBar(20, 20, FlxBarFillDirection.LEFT_TO_RIGHT, 400, 40);
	public var nametag:FlxText = new FlxText(0, 0, 0, "", 24);

	var lastHealth = 100.0;
	public var bossHealthBar = false;
	public var rewards:Rewards = null;
	public var ragdoll:FlxNapeSprite;

	public var naturalRegeneration = 0.0;
    
    public function new(x,y) {
        super(x,y);
        createAttributes();
		health = attributes.get(Attribute.MAX_HEALTH).getValue();
        debugTracker.set("Health", "health");
        debugTracker.set("X", "x");
        debugTracker.set("Y", "y");
        debugTracker.set("Velocity X", "velocity.x");
        debugTracker.set("Velocity Y", "velocity.y");
		debugTracker.set("Stepping On", "steppingOn");
		debugTracker.set("Footstep Sound Step", "footstepCount");
		debugTracker.set("Pixels until Footstep", "pxTillFootstep");
		blood.makeParticles(6, 6, FlxColor.RED);
		blood.launchAngle.set(120, 60);
		blood.lifespan.set(15, 20);
		blood.acceleration.set(0, 900);
		blood.alpha.set(1, 1, 0, 0);
		blood.speed.set(900, 300, 0, 0);
		blood.allowCollisions = ANY;
		healthBar.createColoredEmptyBar(FlxColor.BLACK, true, FlxColor.BLACK, 2);
		healthBar.createColoredFilledBar(FlxColor.RED, true, FlxColor.BLACK, 2);
    }

    override function update(elapsed:Float) {
		naturalRegeneration -= elapsed;
		if (health <= 0 && ragdoll == null)
		{
			if (FlxG.state is PlayState)
			{
				if (rewards != null)
				{
					var ps:PlayState = cast(FlxG.state);
					if (rewards.tokens > 0)
					{
						var b = rewards.tokens;
						ps.tokens += b;
						ps.whatYouGambled.text = "+" + b + " tokens!";
						ps.whatYouGambled.alpha = 1;
					}
					if (rewards.healPlayers)
					{
						ps.playerLayer.forEachOfType(PlayerEntity, (pe) ->
						{
							pe.health = pe.attributes.get(Attribute.MAX_HEALTH).getValue();
						});
					}
				}
			}
			ragdoll = new FlxNapeSprite(x, y, null, false, true);
			ragdoll.loadGraphicFromSprite(this);
			ragdoll.scale.set(scale.x, scale.y);
			ragdoll.createRectangularBody();
			allowCollisions = NONE;
			ragdoll.body.space = Main.napeSpace;
			ragdoll.body.rotate(ragdoll.body.position, FlxG.random.float(-180, 180) * FlxAngle.TO_RAD);
			ragdoll.body.velocity.setxy(FlxG.random.int(-400, 400), FlxG.random.int(-400, 400));
			ragdoll.setBodyMaterial(0.05, 0.9, 1.6, 20, 1);
			if (this is PlayerEntity)
			{
				FlxG.camera.fade(FlxColor.BLACK, 5, false);
			}
			FlxTween.tween(ragdoll, {alpha: 0}, 6);
		}
		if (ragdoll != null)
		{
			ragdoll.update(elapsed);
			if (ragdoll.alpha == 0)
			{
				if (this is PlayerEntity)
				{
					FlxG.resetState();
				}
				kill();
			}
			return;
		}
		blood.x = getGraphicMidpoint().x;
		blood.y = getGraphicMidpoint().y;
		blood.scale.set(scale.x, scale.y);
		if (lastHealth > health)
		{
			blood.start(true, 0, Math.ceil(lastHealth - health));
			MultiSoundManager.playRandomSound(this, "hit");
			naturalRegeneration = 5;
		}
		lastHealth = health;
		if (attributes.exists(Attribute.REGENERATION))
		{
			if (naturalRegeneration < 0)
			{
				health += elapsed * attributes.get(Attribute.REGENERATION).getValue();
			}
		}
		blood.update(elapsed);
		nametag.text = entityName;
		healthBar.value = health;
		healthBar.setRange(0, attributes.get(Attribute.MAX_HEALTH).getValue());

		for (key => value in attributes)
		{
			value.max = key.maxBound;
			value.min = key.minBound;

			if (value.getValue() >= value.max || value.getValue() <= value.min)
			{
				value.refreshAndGetValue();
			}
		}
		var newWidth = (32 * attributes.get(Attribute.SIZE_X).getValue());
		var newHeight = (32 * attributes.get(Attribute.SIZE_Y).getValue());
		if (!manuallyUpdateSize && (newWidth != width || newHeight != height))
		{
			y += height - newHeight;
			x += (width - newWidth) / 2;
			setSize(newWidth, newHeight);
			offset.set(-0.5 * (width - frameWidth), -0.5 * (height - frameHeight));
			centerOrigin();
			scale.set(attributes.get(Attribute.SIZE_X).getValue(), attributes.get(Attribute.SIZE_Y).getValue());
		}

		pxTillFootstep -= last.distanceTo(getPosition());
		if (pxTillFootstep <= 0)
		{
			pxTillFootstep = 80;
			MultiSoundManager.playFootstepForEntity(this);
		}

		health = Math.min(health, attributes.get(Attribute.MAX_HEALTH).getValue());
        super.update(elapsed);
    }

    public function createAttributes() {
		attributes.set(Attribute.MAX_HEALTH, new Attribute(100));
    }

    override function draw() {
		if (ragdoll != null)
		{
			ragdoll.draw();
			return;
		}
        super.draw();
		blood.draw();
		if (bossHealthBar)
		{
			healthBar.draw();
			nametag.draw();
		}
    }
    
	var translatedTypeName = "";

    override function toString():String {
        var debugString = "";
        for (key => value in debugTracker) {
            var splits = value.split(".");
            var currentParent:Dynamic = this;
            var finalValue:Dynamic = null; 
            for (i in 0...splits.length) {
                finalValue = Reflect.getProperty(currentParent,splits[i]);
				if (Reflect.getProperty(currentParent, splits[i]) is Float)
				{
					finalValue = FlxMath.roundDecimal(Reflect.getProperty(currentParent, splits[i]), 2);
				}
                currentParent = finalValue;
            }
            debugString += "\n   " + key + ": " + Std.string(finalValue);
        }
		if (translatedTypeName == "")
		{
			translatedTypeName = Language.get("entity." + typeTranslationKey);
		}
        var attributeString = "";
        for (key => value in attributes) {
			attributeString += "\n        "
				+ Language.get("attribute." + key.id)
				+ ": "
				+ value.getValue()
				+ " ("
				+ value.modifiers.length
				+ " modifiers)";
        }
		return entityName
			+ " (Type: "
			+ translatedTypeName
			+ " FlxID: "
			+ ID
			+ ")\n"
			+ debugString
			+ "\n   Attributes:"
			+ attributeString;
    }
}