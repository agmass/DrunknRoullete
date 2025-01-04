package entity;

import abilities.attributes.Attribute;
import flixel.FlxSprite;
import flixel.ui.FlxBar;
import haxe.ds.HashMap;

class Entity extends FlxSprite {

    public var health = 100.0;
    public var attributes:Map<String, Attribute> = new Map();
    public var entityName = "Entity";
    public var debugTracker:Map<String, String> = new Map();
    
    public function new(x,y) {
        super(x,y);
        createAttributes();
        debugTracker.set("Health", "health");
        debugTracker.set("X", "x");
        debugTracker.set("Y", "y");
        debugTracker.set("Velocity X", "velocity.x");
        debugTracker.set("Velocity Y", "velocity.y");
    }

    override function update(elapsed:Float) {
        health = Math.min(health, attributes.get(Attribute.MAX_HEALTH).getValue());
        super.update(elapsed);
    }

    public function createAttributes() {
        attributes.set(Attribute.MAX_HEALTH, new Attribute(100));
    }

    override function draw() {
        super.draw();
    }
    
    override function toString():String {
        var debugString = "";
        for (key => value in debugTracker) {
            var splits = value.split(".");
            var currentParent:Dynamic = this;
            var finalValue:Dynamic = null; 
            for (i in 0...splits.length) {
                finalValue = Reflect.getProperty(currentParent,splits[i]);
                currentParent = finalValue;
            }
            debugString += "\n   " + key + ": " + Std.string(finalValue);
        }
        var attributeString = "";
        for (key => value in attributes) {
            attributeString += "\n        " + key + ": " + value.getValue() + " (" + value.modifiers.length + " modifiers)";
        }
        return entityName + " (FlxID: " + ID + ")\n" + debugString + "\n   Attributes:" + attributeString;
    }
}