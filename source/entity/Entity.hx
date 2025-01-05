package entity;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.ui.FlxBar;
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
    
    public function new(x,y) {
        super(x,y);
        createAttributes();
        debugTracker.set("Health", "health");
        debugTracker.set("X", "x");
        debugTracker.set("Y", "y");
        debugTracker.set("Velocity X", "velocity.x");
        debugTracker.set("Velocity Y", "velocity.y");
		debugTracker.set("Stepping On", "steppingOn");
		debugTracker.set("Footstep Sound Step", "footstepCount");
		debugTracker.set("Pixels until Footstep", "pxTillFootstep");
    }

    override function update(elapsed:Float) {
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
			scale.set(attributes.get(Attribute.SIZE_X).getValue(), attributes.get(Attribute.SIZE_Y).getValue());
		}

		pxTillFootstep -= last.distanceTo(getPosition());
		if (pxTillFootstep <= 0)
		{
			pxTillFootstep = 80;
			FootstepManager.playFootstepForEntity(this);
		}

		health = Math.min(health, attributes.get(Attribute.MAX_HEALTH).getValue());
        super.update(elapsed);
    }

    public function createAttributes() {
		attributes.set(Attribute.MAX_HEALTH, new Attribute(100));
    }

    override function draw() {
        super.draw();
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