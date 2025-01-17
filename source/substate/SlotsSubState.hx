package substate;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class SlotsSubState extends FlxSubState
{
	public var p:PlayerEntity;
	public var token:FlxSprite = new FlxSprite(0, 0, AssetPaths.token__png);
	public var amountText:FlxText = new FlxText(0, 0, 0, "0", 24);
	public var attributesRollGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var operationRollGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var amountRollGroup:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();

	public var attributeIcons:Array<String> = [];
	public var operationIcons:Array<String> = [];
	public var possibleAddNumbers = [10, 25, 50, 100, 250, 500];
	public var middle = 0.0;

	public var bg1:FlxSprite;
	public var bg2:FlxSprite;
	public var bg3:FlxSprite;

	override public function new(player:PlayerEntity)
	{
		super();
		p = player;
	}

	override function create()
	{
		for (i in AssetPaths.allFiles)
		{
			if (StringTools.startsWith(i, "assets/images/attribute_icons/"))
			{
				attributeIcons.push(i);
			}
		}
		for (i in AssetPaths.allFiles)
		{
			if (StringTools.startsWith(i, "assets/images/operation_icons/"))
			{
				operationIcons.push(i);
			}
		}
		var slotsMachine:FlxSprite = new FlxSprite(0, 0, AssetPaths.slots__png);
		slotsMachine.loadGraphic(AssetPaths.slots__png, true, 256, 256);
		slotsMachine.scale.set(4.21875, 4.21875);
		slotsMachine.updateHitbox();
		slotsMachine.screenCenter();
		var bg:FlxSprite = new FlxSprite(slotsMachine.x, slotsMachine.y).makeGraphic(168, 286);
		bg.x += 62 * 4.218;
		bg.y = 67 * 4.218;
		add(bg);
		bg1 = bg;
		var bg:FlxSprite = new FlxSprite(slotsMachine.x, slotsMachine.y).makeGraphic(168, 286);
		bg.x += 105 * 4.218;
		bg.y = 67 * 4.218;
		add(bg);
		bg2 = bg;
		var bg:FlxSprite = new FlxSprite(slotsMachine.x, slotsMachine.y).makeGraphic(168, 286);
		bg.x += 148 * 4.218;
		bg.y = 67 * 4.218;
		middle = bg.y;
		bg3 = bg;
		add(bg);
		add(token);
		add(amountText);
		for (i in -1...1)
		{
			var attribute:FlxSprite = new FlxSprite().loadGraphic(attributeIcons[FlxG.random.int(0, attributeIcons.length - 1)]);
			attribute.setGraphicSize(168, 286);
			attribute.updateHitbox();
			attribute.scale.set(6.4375, 6.4375);
			attribute.screenCenter();
			attribute.y = bg1.y;
			attribute.x = bg1.x;
			attribute.y += (286 * (i));
			attributesRollGroup.add(attribute);
		}
		add(attributesRollGroup);
		for (i in -1...1)
		{
			var attribute:FlxSprite = new FlxSprite().loadGraphic(operationIcons[FlxG.random.int(0, operationIcons.length - 1)]);
			attribute.setGraphicSize(168, 286);
			attribute.updateHitbox();
			attribute.scale.set(6.4375, 6.4375);
			attribute.y = bg1.y;
			attribute.x = bg2.x;
			attribute.y += (286 * (i));
			operationRollGroup.add(attribute);
		}
		add(operationRollGroup);
		for (i in -1...1)
		{
			var attribute:FlxText = new FlxText(0, 0, 0, possibleAddNumbers[FlxG.random.int(0, possibleAddNumbers.length - 1)] + "", 50);
			attribute.updateHitbox();
			attribute.screenCenter();
			attribute.y = bg1.y;
			attribute.x = bg3.x;
			attribute.y += (286 * (i));
			attribute.color = FlxColor.BLACK;
			amountRollGroup.add(attribute);
		}
		add(amountRollGroup);
		add(slotsMachine);
		super.create();
	}

	public var gambaTime:Float = -1.0;
	public var finalAmount:Float = 10.0;
	public var finalOperation = AttributeOperation.MULTIPLY;
	public var reverseOperation = false;
	public var finalAttribute = Attribute.MOVEMENT_SPEED;
	public var lockedInState = 0;
	public var desiredIconOne = "";
	public var desiredIconTwo = "";
	public var desiredIconThree = "";

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			if (gambaTime >= 0)
			{
				gambaTime = 1.8;
			}
			else
			{
				close();
			}
		}
		var lastY = -9999.0;
		for (text in amountRollGroup)
		{
			if (lockedInState >= 3)
			{
				if (text.y > middle + ((bg1.height - 50) / 2) || text.y < middle - ((bg1.height - 50) / 2))
				{
					text.y = middle + ((bg1.height - 50) / 2) + 286;
				}
				break;
			}
			text.screenCenter(X);
			text.x = (bg3.width - text.width) / 2;
			text.x += bg3.x;
			if (lastY != -9999)
			{
				if (Math.abs(text.y - lastY) < 286)
				{
					text.y = lastY + 286;
				} // re-correct
			}
			lastY = text.y;
			text.y += elapsed * 3050;
			if (text.y >= middle + ((bg1.height - 50) / 2) && text.text == desiredIconThree)
			{
				text.y = middle + ((bg1.height - 50) / 2);
				lockedInState = 3;
			}
			if (text.y >= (middle + 286))
			{
				text.y = middle - 286;
				if (gambaTime >= 1.8)
				{
					text.text = finalAmount + "";
					desiredIconThree = text.text;
				}
				else
				{
					text.text = possibleAddNumbers[FlxG.random.int(0, possibleAddNumbers.length - 1)] + "";
				}
			}
		}
		for (sprite in attributesRollGroup)
		{
			if (lockedInState >= 1)
			{
				if (sprite.y > middle || sprite.y < middle)
				{
					sprite.y = middle + 286;
				}
				break;
			}
			if (lastY != -9999)
			{
				if (Math.abs(sprite.y - lastY) < 286)
				{
					sprite.y = lastY + 286;
				} // re-correct
			}
			lastY = sprite.y;
			sprite.y += elapsed * 3050;
			if (sprite.y >= middle && sprite.graphic.key == desiredIconOne)
			{
				sprite.y = middle;
				lockedInState = 1;
			}
			if (sprite.y >= (middle + 286))
			{
				sprite.y = middle - 286;

				if (gambaTime >= 0.5)
				{
					var iconName = "";
					for (ic in attributeIcons)
					{
						if (StringTools.contains(ic, finalAttribute.id))
						{
							iconName = ic;
							break;
						}
					}
					if (iconName == "")
					{
						iconName = AssetPaths.gamble_missing_texture__png;
					}
					desiredIconOne = iconName;
					sprite.loadGraphic(iconName);
					sprite.setGraphicSize(168, 286);
				}
				else
				{
					sprite.loadGraphic(attributeIcons[FlxG.random.int(0, attributeIcons.length - 1)]);
					sprite.setGraphicSize(168, 286);
				}
			}
		}
		for (sprite in operationRollGroup)
		{
			if (lockedInState >= 2)
			{
				if (sprite.y > middle || sprite.y < middle)
				{
					sprite.y = middle + 286;
				}
				break;
			}
			if (lastY != -9999)
			{
				if (Math.abs(sprite.y - lastY) < 286)
				{
					sprite.y = lastY + 286;
				} // re-correct
			}
			lastY = sprite.y;
			sprite.y += elapsed * 3050;
			if (sprite.y >= middle && sprite.graphic.key == desiredIconTwo)
			{
				sprite.y = middle;
				lockedInState = 2;
			}
			if (sprite.y >= (middle + 286))
			{
				sprite.y = middle - 286;

				if (gambaTime >= 1.2)
				{
					var iconName = "";
					if (finalOperation == MULTIPLY)
					{
						iconName = "assets/images/operation_icons/multiply.png";
					}
					else
					{
						iconName = "assets/images/operation_icons/add" + (reverseOperation ? "_lost" : "") + ".png";
					}
					desiredIconTwo = iconName;
					sprite.loadGraphic(iconName);
					sprite.setGraphicSize(168, 286);
				}
				else
				{
					sprite.loadGraphic(operationIcons[FlxG.random.int(0, operationIcons.length - 1)]);
					sprite.setGraphicSize(168, 286);
				}
			}
		}
		token.x = 20;
		token.y = 20;
		token.scale.set(2, 2);
		amountText.x = 45;
		amountText.y = 15;
		if (gambaTime >= 0.0)
		{
			if (gambaTime >= 2.0)
			{
				gambaTime = -1;
			}
			gambaTime += elapsed;
		}
		else
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				desiredIconOne = "";
				desiredIconTwo = "";
				desiredIconThree = "";
				lockedInState = 0;
				roll();
			}
		}
		super.update(elapsed);
	}

	public function roll()
	{
		gambaTime = 0.0;
		var lostOrWon = FlxG.random.bool(50);
		var amount = 0.0;

		var operation:AttributeOperation = [AttributeOperation.ADD, AttributeOperation.MULTIPLY][FlxG.random.int(0, 1)];
		var listForBet = Attribute.attributesList;
		var type = listForBet[FlxG.random.int(0, listForBet.length - 1)];
		if (!p.attributes.exists(type))
		{
			lostOrWon = true;
		}
		else
		{
			if (type.maxBound <= p.attributes.get(type).getValue())
			{
				lostOrWon = false;
			}
			if (type.minBound >= p.attributes.get(type).getValue())
			{
				lostOrWon = true;
			}
		}
		if (type.mustBeAddition)
		{
			operation = ADD;
		}
		if (operation.equals(MULTIPLY))
		{
			if (lostOrWon)
			{
				amount = FlxG.random.float(1.1, 1.5);
			}
			else
			{
				amount = FlxG.random.float(0.5, 0.9);
			}
			amount = FlxMath.roundDecimal(amount, 1);
		}
		else
		{
			amount = [
				10.0, 10.0, 10.0, 10.0, 10.0, 10.0, 25.0, 25.0, 25.0, 25.0, 25.0, 50.0, 50.0, 50.0, 50.0, 100.0, 100.0, 100.0, 250.0, 250.0, 500.0
			][FlxG.random.int(0, 20)];
			amount *= type.additionMultiplier;
			if (type == Attribute.JUMP_COUNT)
			{
				amount = [1.0, 1.0, 1.0, 1.0, 1.0, 2.0, 2.0, 2.0, 2.0, 3.0, 3.0, 3.0, 4.0, 4.0][FlxG.random.int(0, 13)] *= type.additionMultiplier;
			}
			if (!lostOrWon)
				amount = -amount;
		}
		trace(type.id);
		trace(lostOrWon ? "won" : "lost");
		trace("amount that was " + operation.getName() + "ed: " + amount);

		if (!p.attributes.exists(type))
		{
			p.attributes.set(type, new Attribute(0));
			p.attributes.get(type).addOperation(new AttributeContainer(ADD, type.minBound));
			p.attributes.get(type).min = type.minBound;
		}
		p.attributes.get(type).addOperation(new AttributeContainer(operation, amount));
		if (type == Attribute.SIZE_X)
		{
			p.attributes.get(Attribute.SIZE_Y).addOperation(new AttributeContainer(operation, amount));
		}
		if (type == Attribute.MAX_HEALTH)
		{
			p.health = p.attributes.get(type).refreshAndGetValue();
		}
		finalAmount = amount;
		finalOperation = operation;
		reverseOperation = !lostOrWon;
		finalAttribute = type;
	}
}