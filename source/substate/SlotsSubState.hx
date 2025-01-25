package substate;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.PlayerEntity;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import input.KeyboardSource;
import openfl.filters.ShaderFilter;
import shader.AttributesSlotTextShader;
import sound.FootstepManager.MultiSoundManager;
import ui.Card;
import util.Language;

class SlotsSubState extends FlxSubState
{
	public var p:PlayerEntity;
	public var token:FlxSprite = new FlxSprite(0, 0, AssetPaths.token__png);
	public var amountText:FlxText = new FlxText(0, 0, 0, "0", 24 * 3);
	public var attributesRollGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var operationRollGroup:FlxSpriteGroup = new FlxSpriteGroup();
	public var cards:FlxTypedSpriteGroup<Card> = new FlxTypedSpriteGroup<Card>();
	public var amountRollGroup:FlxTypedSpriteGroup<FlxText> = new FlxTypedSpriteGroup<FlxText>();

	public var attributeIcons:Array<String> = [];
	public var operationIcons:Array<String> = [];
	public var possibleAddNumbers = [10, 25, 50, 100, 250, 500];
	public var middle = 0.0;
	public var playerReminder:FlxText = new FlxText(0, 0, 0, "Player: Player 0\nPress [A] to use!", 32);

	public var bg1:FlxSprite;
	public var bg2:FlxSprite;
	public var bg3:FlxSprite;
	public var gamblingCamera = new FlxCamera(0, 67 * 4.218, Math.round((43 * 4.218) * 3), 287);
	public var foregroundgamblingCamera = new FlxCamera(0, 0, 0, 0);
	var rumblingSound:FlxSound = new FlxSound();

	var slotsMachine:FlxSprite = new FlxSprite(0, 0, AssetPaths.slots__png);
	override public function new(player:PlayerEntity)
	{
		super();
		p = player;
	}

	public function createCards()
	{
		cards.forEach((c) ->
		{
			c.destroy();
		});
		cards.clear();
		for (key => value in p.attributes)
		{
			if (Attribute.attributesList.contains(key)) // only add attributes that we can actually change in-game, eg; dont add unused attributes or size_y
				cards.add(new Card(key, p));
		}
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
		FlxG.cameras.add(gamblingCamera, false);
		FlxG.cameras.add(foregroundgamblingCamera, false);
		foregroundgamblingCamera.bgColor.alpha = 0;
		gamblingCamera.bgColor.alpha = 0;
		slotsMachine.loadGraphic(AssetPaths.slots__png, true, 256, 256);
		slotsMachine.scale.set(4.21875, 4.21875);
		slotsMachine.updateHitbox();
		slotsMachine.screenCenter();
		slotsMachine.camera = foregroundgamblingCamera;
		FlxG.save.bind("brj2025");
		if (!FlxG.save.data.shadersDisabled)
			slotsMachine.shader = slotShader;
		slotsMachine.animation.add("idle", [0]);
		slotsMachine.animation.add("pull", [0, 1, 2, 3, 4, 5], 12, false);
		slotsMachine.animation.add("pullBack", [5, 4, 3, 2, 1, 0], 12, false);
		gamblingCamera.x = slotsMachine.x;
		gamblingCamera.x += 62 * 4.218;
		var bg:FlxSprite = new FlxSprite().makeGraphic(170, 296);
		add(bg);
		bg.color = FlxColor.fromRGB(221, 221, 221);
		bg.camera = gamblingCamera;
		bg1 = bg;
		var bg:FlxSprite = new FlxSprite().makeGraphic(170, 296);
		bg.x += 43 * 4.218;
		bg.color = FlxColor.fromRGB(221, 221, 221);
		bg.camera = gamblingCamera;
		add(bg);
		bg2 = bg;
		var bg:FlxSprite = new FlxSprite().makeGraphic(170, 296);
		bg.x += (43 * 4.218) * 2;
		bg.color = FlxColor.fromRGB(221, 221, 221);
		bg.camera = gamblingCamera;
		middle = bg.y;
		bg3 = bg;
		add(bg);
		for (i in -1...1)
		{
			var attribute:FlxSprite = new FlxSprite().loadGraphic(attributeIcons[FlxG.random.int(0, attributeIcons.length - 1)]);
			attribute.setGraphicSize(168, 286);
			attribute.updateHitbox();
			attribute.y += (286 * (i));
			attribute.camera = gamblingCamera;
			attributesRollGroup.add(attribute);
		}
		add(attributesRollGroup);
		attributesRollGroup.camera = gamblingCamera;
		for (i in -1...1)
		{
			var attribute:FlxSprite = new FlxSprite().loadGraphic(operationIcons[FlxG.random.int(0, operationIcons.length - 1)]);
			attribute.setGraphicSize(168, 286);
			attribute.updateHitbox();
			attribute.x = bg2.x;
			attribute.y += (286 * (i));
			attribute.camera = gamblingCamera;
			operationRollGroup.add(attribute);
		}
		add(operationRollGroup);
		operationRollGroup.camera = gamblingCamera;
		for (i in -1...1)
		{
			var attribute:FlxText = new FlxText(0, 0, 0, possibleAddNumbers[FlxG.random.int(0, possibleAddNumbers.length - 1)] + "", 50);
			attribute.updateHitbox();
			attribute.screenCenter();
			attribute.x = bg3.x;
			attribute.y += (286 * (i));
			attribute.color = FlxColor.BLACK;
			attribute.camera = gamblingCamera;
			amountRollGroup.add(attribute);
		}
		add(amountRollGroup);
		amountRollGroup.camera = gamblingCamera;
		add(slotsMachine);
		createCards();
		add(cards);
		playerReminder.camera = foregroundgamblingCamera;
		token.camera = foregroundgamblingCamera;
		amountText.camera = foregroundgamblingCamera;
		playerReminder.x = slotsMachine.x + (4.21875 * 34);
		playerReminder.y = slotsMachine.y + (4.21875 * 173);
		playerReminder.color = FlxColor.BLACK;
		amountText.color = FlxColor.BLACK;
		add(playerReminder);
		add(Main.subtitlesBox);
		add(token);
		add(amountText);
		var idiotProofing:FlxSprite = new FlxSprite(FlxG.width - 200, FlxG.height - 100, AssetPaths.exittip__png);
		idiotProofing.scale.set(2, 2);
		add(idiotProofing);
		rumblingSound.loadEmbedded(AssetPaths.rumbling__ogg);
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
	public var slotShader = new AttributesSlotTextShader();

	var shaderLag = 0.0;
	public var selectedCard = 0;
	var holdTime = 0.0;

	override function destroy()
	{
		FlxG.timeScale = 1;
		FlxTween.cancelTweensOf(amountText);
		remove(Main.subtitlesBox);
		FlxG.cameras.remove(gamblingCamera);
		FlxG.cameras.remove(foregroundgamblingCamera);
		super.destroy();
	}

	override function update(elapsed:Float)
	{
		gamblingCamera.y = foregroundgamblingCamera.y + 67 * 4.218;
		gamblingCamera.angle = foregroundgamblingCamera.angle;
		Main.detectConnections();
		shaderLag += elapsed;
		if (shaderLag >= 0.1)
		{
			slotShader.elapsed.value = [slotShader.elapsed.value[0] + shaderLag];
			shaderLag = 0;
		}
		var goBack = false;
		var startRoll = false;
		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			ps.playerLayer.forEachOfType(PlayerEntity, (pe) ->
			{
				if (pe.input.ui_hold_accept)
				{
					if (gambaTime < 0 && p != pe)
					{
						p = pe;
						createCards();
					}
					startRoll = true;
				}
			});
			for (source in Main.activeInputs)
			{
				if (source.ui_deny)
					goBack = true;
			}
		}
		else
		{
			// What the fuck?!?!? Shit is going to break!! Whatever

			for (source in Main.activeInputs)
			{
				if (source.ui_hold_accept)
					startRoll = true;
				if (source.ui_deny)
					goBack = true;
			}
		}
		if (goBack)
		{
			if (gambaTime < 0)
			{
				FlxG.timeScale = 1;
				close();
			}
		}
		var finalSelected = null;
		var i = -(cards.length / 2);
		for (card in cards)
		{
			card.screenCenter(Y);
			card.x = -85;
			card.y += (i * 80);
			i++;
			card.selected = false;
			p.attributes.get(card.attributeType).refreshAndGetValue();
			if (FlxG.mouse.overlaps(card))
				finalSelected = card;
		}
		if (!(p.input is KeyboardSource))
		{
			if (selectedCard > cards.length - 1)
			{
				selectedCard = 0;
			}
			if (selectedCard < 0)
			{
				selectedCard = cards.length - 1;
			}
			if (cards.length > 0)
			{
				finalSelected = cards.members[selectedCard];
			}
			if (FlxMath.roundDecimal(p.input.getMovementVector().y, 1) != FlxMath.roundDecimal(p.input.lastMovement.y, 1))
			{
				if (p.input.getMovementVector().y == 1)
				{
					selectedCard += 1;
				}
				if (p.input.getMovementVector().y == -1)
				{
					selectedCard -= 1;
				}
			}
			p.input.lastMovement.y = p.input.getMovementVector().y;
		}
		if (finalSelected != null)
		{
			finalSelected.selected = true;
		}
		var lastY = -9999.0;
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
				MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "slots_hit", FlxG.random.float(0.9, 1.1), 1);
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
				MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "slots_hit", FlxG.random.float(0.9, 1.1), 1);
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
		for (text in amountRollGroup)
		{
			if (lockedInState >= 3)
			{
				if (text.y != (middle + ((bg1.height - 50) / 2)))
				{
					text.y = middle - 286;
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
				MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "slots_hit", FlxG.random.float(0.9, 1.1), 1);
				text.y = middle + ((bg1.height - 50) / 2);
				lockedInState = 3;
			}
			if (text.y >= (middle + 286))
			{
				text.y = middle - 286;
				if (gambaTime >= 1.8)
				{
					text.text = Math.abs(finalAmount) + "";
					desiredIconThree = text.text;
				}
				else
				{
					text.text = possibleAddNumbers[FlxG.random.int(0, possibleAddNumbers.length - 1)] + "";
				}
			}
		}
		token.x = playerReminder.x;
		token.y = playerReminder.getGraphicBounds().bottom + 20;
		token.scale.set(5, 5);
		token.updateHitbox();
		amountText.x = playerReminder.x + token.width + 10;
		amountText.y = token.y;
		amountText.text = p.tokens + "";
		if (startRoll)
		{
			if (p.tokens > 7)
			{
				holdTime += elapsed / 10;
				if (holdTime > 6 - 1.4)
				{
					holdTime = 6 - 1.4;
					rumblingSound.play(false);
					rumblingSound.looped = true;
				}
			}
			else
			{
				rumblingSound.stop();
				holdTime = 0;
			}
			FlxG.timeScale = 1.4 + holdTime;
		}
		else
		{
			rumblingSound.stop();
			FlxG.timeScale = 1;
			holdTime = 0;
		}
		if (gambaTime >= 0.0)
		{
			if (gambaTime >= 2.0)
			{
				MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "lever_pull", FlxG.random.float(0.9, 1.1), 1);
				slotsMachine.animation.play("pullBack");
				gambaTime = -1;
			}
			gambaTime += elapsed;
		}
		else
		{
			if (startRoll)
			{
				if (p.tokens > 0)
				{
					p.tokens--;
					desiredIconOne = "";
					desiredIconTwo = "";
					desiredIconThree = "";
					lockedInState = 0;
					foregroundgamblingCamera.shake(0.015, 0.1);
					FlxTween.tween(foregroundgamblingCamera, {y: -45, angle: -3}, 0.1, {
						ease: FlxEase.quadIn,
						onComplete: (t) ->
						{
							FlxTween.tween(foregroundgamblingCamera, {y: -90, angle: 2}, 0.1, {
								ease: FlxEase.quadOut,
								onComplete: (t) ->
								{
									new FlxTimer().start(0.05, (tt) ->
									{
										FlxTween.tween(foregroundgamblingCamera, {y: 0, angle: 0}, 0.25, {
											ease: FlxEase.quartOut
										});
									});
								}
							});
						}
					});
					MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "lever_pull", FlxG.random.float(0.9, 1.1), 1);
					roll();
				}
				else
				{
					amountText.color = FlxColor.RED;
					FlxTween.color(amountText, 0.65, FlxColor.RED, FlxColor.BLACK, {ease: FlxEase.sineOut});
				}
			}
		}
		playerReminder.text = StringTools.replace(StringTools.replace(Language.get("hint.slotMachine"), "%1", p.entityName), "%2", p.input.uiAcceptName());

		super.update(elapsed);
	}

	public function roll()
	{
		slotsMachine.animation.play("pull");
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
				10.0, 10.0, 10.0, 10.0, 10.0, 25.0, 25.0, 25.0, 25.0, 25.0, 50.0, 50.0, 50.0, 50.0, 100.0, 100.0, 100.0, 250.0, 250.0, 500.0
			][FlxG.random.int(0, 19)];
			if (type.additionMultiplier <= 0.001 && amount <= 50)
			{
				amount = 100.0;
			}
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
			p.attributes.set(type, new Attribute(type.minBound));
			p.attributes.get(type).min = type.minBound;
			p.attributes.get(type).max = type.maxBound;
			createCards();
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