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
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import haxe.ds.HashMap;
import haxe.xml.Check.Attrib;
import nape.geom.Vec2;
import openfl.display.BitmapData;
import shader.FadingOut;
import sound.FootstepManager;
import state.TransitionableState;
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
	public var floatingTexts:FlxSpriteGroup = new FlxSpriteGroup();

	var lastHealth = 100.0;
	public var bossHealthBar = false;
	public var rewards:Rewards = null;
	public var ragdoll:FlxNapeSprite;

	public var naturalRegeneration = 0.0;
	public var noclip = false;
    
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
		blood.lifespan.set(15, 20);
		blood.acceleration.set(-900, 900, 900, 900, 0, 0);
		blood.alpha.set(1, 1, 0, 0);
		blood.speed.set(400, 400, 0, 0);
		blood.allowCollisions = ANY;
		healthBar.createColoredEmptyBar(FlxColor.BLACK, true, FlxColor.BLACK, 2);
		healthBar.createColoredFilledBar(FlxColor.RED, true, FlxColor.BLACK, 2);
    }

	public function damage(amount:Float, attacker:Entity):Bool
	{
		if (attacker == null)
		{
			health -= amount;
			return true;
		}
		health -= amount * attacker.attributes.get(Attribute.ATTACK_DAMAGE).getValue();
		if (attacker.attributes.exists(Attribute.CRIT_CHANCE))
		{
			if (FlxG.random.bool(attacker.attributes.get(Attribute.CRIT_CHANCE).getValue()))
			{
				health -= amount * 2;
				spawnFloatingText("CRITICAL HIT!", FlxColor.GREEN, 24);
			}
		}
		return true;
	}

	public function spawnFloatingText(text:String, color:FlxColor, size:Int = 18)
	{
		var txt = new FlxText(x + FlxG.random.int(0, Math.round(width)), y + FlxG.random.int(0, Math.round(height)), 0, text, size);
		txt.color = color;
		floatingTexts.add(txt);
	}
	public function onCollideWithEntity(e:Entity) {}

	public var usePlayerVolume = false;

    override function update(elapsed:Float) {
		if (lastHealth > health && ragdoll == null)
		{
			spawnFloatingText(Math.round(health - lastHealth) + "", FlxColor.RED);
			blood.start(true, 0, Math.ceil(lastHealth - health));
			MultiSoundManager.playRandomSound(this, "hit");
			naturalRegeneration = 5;
		}
		for (sprite in floatingTexts)
		{
			sprite.y -= elapsed * 100;
			sprite.alpha -= elapsed;
			if (sprite.alpha <= 0)
			{
				sprite.destroy();
				floatingTexts.remove(sprite);
			}
		}
		if (attributes.exists(Attribute.ATTACK_SPEED))
		{
			if (attributes.get(Attribute.ATTACK_SPEED).getValue() <= 0)
			{
				attributes.get(Attribute.ATTACK_SPEED).min = 0.0001;
				attributes.get(Attribute.ATTACK_SPEED).bypassLimits = false;
			}
		}
		if (attributes.exists(Attribute.ATTACK_DAMAGE))
		{
			if (attributes.get(Attribute.ATTACK_DAMAGE).getValue() <= 0)
			{
				attributes.get(Attribute.ATTACK_DAMAGE).min = 0.0001;
				attributes.get(Attribute.ATTACK_DAMAGE).bypassLimits = false;
			}
		}
		naturalRegeneration -= elapsed;
		if (health <= 0 && ragdoll == null)
		{
			if (FlxG.state is PlayState)
			{
				if (rewards != null)
				{
					var ps:PlayState = cast(FlxG.state);
					if (rewards.opensElevator)
					{
						Main.run.combo++;
						ps.elevator.interactable = true;
					}
					if (rewards.tokens > 0)
					{
						var b = rewards.tokens;
						ps.originalTokens = b;
						ps.tokensTime = 0.75;
						ps.playerLayer.forEachOfType(PlayerEntity, (p) ->
						{
							p.tokens += b * Main.run.combo;
						});
					}
				}
			}
			ragdoll = new FlxNapeSprite(x, y, null, false, true);
			ragdoll.loadGraphicFromSprite(this);
			ragdoll.scale.set(scale.x, scale.y);
			ragdoll.createRectangularBody(frameHeight * scale.x, frameHeight * scale.y);
			allowCollisions = NONE;
			ragdoll.color = color;
			ragdoll.body.space = Main.napeSpaceAmbient;
			ragdoll.body.rotate(ragdoll.body.position, FlxG.random.float(-180, 180) * FlxAngle.TO_RAD);
			ragdoll.body.velocity.setxy(FlxG.random.int(-400, 400), FlxG.random.int(-400, 400));
			ragdoll.setBodyMaterial(0.05, 0.9, 1.6, 20, 1);
			FlxTween.tween(ragdoll, {alpha: 0}, 3);
		}
		blood.update(elapsed);
		if (ragdoll != null)
		{
			ragdoll.update(elapsed);
			if (ragdoll.alpha == 0)
			{
				ragdoll.body.position.set(new Vec2(-100, -100));
				kill();
			}
			return;
		}
		blood.x = getGraphicMidpoint().x;
		blood.y = getGraphicMidpoint().y;
		blood.scale.set(scale.x, scale.y);
		lastHealth = health;
		if (attributes.exists(Attribute.REGENERATION))
		{
			if (naturalRegeneration < 0)
			{
				health += elapsed * attributes.get(Attribute.REGENERATION).getValue();
			}
		}
		nametag.text = entityName;
		healthBar.value = health;
		healthBar.setRange(0, attributes.get(Attribute.MAX_HEALTH).getValue());

		for (key => value in attributes)
		{
			value.update(elapsed);
			value.max = key.maxBound;
			value.min = key.minBound;

			if (value.getValue() >= value.max || value.getValue() <= value.min)
			{
				value.refreshAndGetValue();
			}
		}
		var newWidth = (originalSpriteSizeX * attributes.get(Attribute.SIZE_X).getValue());
		var newHeight = (originalSpriteSizeY * attributes.get(Attribute.SIZE_Y).getValue());
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

	public var originalSpriteSizeX = 32;
	public var originalSpriteSizeY = 32;

    public function createAttributes() {
		attributes.set(Attribute.MAX_HEALTH, new Attribute(100));
		attributes.set(Attribute.SIZE_X, new Attribute(1));
		attributes.set(Attribute.SIZE_Y, new Attribute(1));
	}
    override function draw() {
		if (ragdoll != null)
		{
			ragdoll.draw();
			blood.draw();
			floatingTexts.draw();
			return;
		}
        super.draw();
		blood.draw();
		floatingTexts.draw();
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