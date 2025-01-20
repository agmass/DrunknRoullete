package ui;

import abilities.attributes.AttributeOperation;
import abilities.attributes.AttributeType;
import entity.PlayerEntity;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import util.Language;

class Card extends FlxSprite
{
	public var selected = true;
	var timeSelected = 0.0;

	public var icon:FlxSprite = null;
	public var name:FlxText = new FlxText(0, 0, 0, "", 8);
	public var value:FlxText = new FlxText(0, 0, 0, "", 24);
	public var math:FlxText = new FlxText(0, 0, 146, "", 8);

	public var affected:PlayerEntity;
	public var attributeType:AttributeType;

	override public function new(attributeType:AttributeType, affected:PlayerEntity)
	{
		super();
		this.attributeType = attributeType;
		this.affected = affected;
		icon = new FlxSprite(0, 0, "assets/images/attribute_icons/" + attributeType.id + ".png");
		icon.scale.set(2, 2);
		icon.updateHitbox();
		name.text = Language.get("attribute." + attributeType.id);
		loadGraphic(AssetPaths.attribute_bg__png);
		math.color = FlxColor.BLACK;
		value.color = FlxColor.BLACK;
		name.color = FlxColor.BLACK;
	}

	override function update(elapsed:Float)
	{
		if (!selected)
		{
			timeSelected += elapsed * 3;
		}
		else
		{
			timeSelected -= elapsed * 3;
		}
		timeSelected = FlxMath.bound(timeSelected, 0, 1);
		offset.x = (-((easeOutBack(timeSelected) * 256))) + 256; // I DONT UNDDERSTAND ANYTHING HAPPENING RIGHT NOW WHERE I AM ?!??
		super.update(elapsed);
	}
	override function draw()
	{
		name.x = (x - offset.x) + 7;
		name.y = y + 26;
		value.text = FlxMath.roundDecimal(affected.attributes.get(attributeType).getValue(), 2) + "";
		math.text = affected.attributes.get(attributeType).defaultValue + "";
		var finalValue = affected.attributes.get(attributeType).defaultValue;
		var max = affected.attributes.get(attributeType).max;
		var min = affected.attributes.get(attributeType).min;
		for (container in affected.attributes.get(attributeType).modifiers)
		{
			if (container.operation == AttributeOperation.MULTIPLY)
			{
				math.text += " x " + container.amount;
			}
			else
			{
				if (container.amount >= 0)
				{
					math.text += " + " + container.amount;
				}
				else
				{
					math.text += " - " + Math.abs(container.amount);
				}
			}
			if (container.operation == AttributeOperation.ADD)
				finalValue += container.amount;
			else if (container.operation == AttributeOperation.MULTIPLY)
				finalValue *= container.amount;
			if (finalValue >= max)
			{
				finalValue = max;
				math.text += " (capped at " + max + ")";
			}
			if (finalValue <= min)
			{
				finalValue = min;
				math.text += " (capped at " + min + ")";
			}
		}
		value.x = (x - offset.x) + 21;
		value.y = y + 37;
		math.x = (x - offset.x) + 21;
		math.y = y + 64;
		super.draw();
		name.draw();
		math.draw();
		value.draw();
		icon.x = (x - offset.x) + 171;
		icon.y = y + 4;
		icon.draw();
	}

	public function easeOutBack(x:Float)
	{
		return 1 + 1.70158 * Math.pow(x - 1, 3) + 2.70158 * Math.pow(x - 1, 2);
	}

}