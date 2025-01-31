package state;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeType;
import entity.PlayerEntity;
import entity.bosses.BIGEVILREDCUBE;
import entity.bosses.DrunkDriveDaveBoss;
import entity.bosses.RatKingBoss;
import entity.bosses.RobotBoss;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.xml.Check.Attrib;
import input.InputSource;
import input.KeyboardSource;
import objects.Elevator;
import shader.AttributesSlotTextShader;
import ui.ElevatorButton;
import util.Language;
import util.Run;

class MidState extends TransitionableState
{
	var elevator:Elevator = new Elevator(0, 0);
	var bg:FlxSprite = new FlxSprite(0, 0, AssetPaths.elevator_buttons_bg__png);
	public var gambleButton:ElevatorButton = new ElevatorButton(1);
	public var continueButton:ElevatorButton = new ElevatorButton(0);
	var card:FlxSprite = new FlxSprite(0, 0, AssetPaths.attribute_bg__png);
	var text:FlxText = new FlxText(0, 0, 0, "", 24);
	var combo:FlxText = new FlxText(0, 0, 0, "COMBO x0", 32);
	var description:FlxText = new FlxText(0, 0, 240 * 1.5, "", 13);

	override function create()
	{
		FlxG.save.bind("brj2025");
		add(elevator);
		elevator.screenCenter();
		elevator.scale.set(2.485436893, 2.485436893);
		elevator.updateHitbox();
		elevator.screenCenter();
		add(bg);
		add(gambleButton);
		add(continueButton);
		add(card);
		add(text);
		add(description);
		add(combo);
		text.color = FlxColor.fromRGB(0, 255, 0);
		description.color = FlxColor.BLACK;
		card.scale.set(1.5, 1.5);
		card.updateHitbox();
		bg.scale.set(2, 2);
		bg.updateHitbox();
		super.create();
		shader.modulo.value[0] = 3;
		if (!FlxG.save.data.shadersDisabled)
		{
			text.shader = shader;
		}
		else
		{
			text.color = FlxColor.BLACK;
		}
		for (source in Main.activeInputs)
		{
			if (!(source is KeyboardSource))
			{
				selection = 0;
			}
		}
		add(autosavingText);
		FlxTween.tween(autosavingText, {alpha: 0}, 1);
		pickNextBoss();
		saveFile();
		FlxG.save.flush();
	}

	public static function saveFile()
	{
		FlxG.save.data.run = Main.saveFileVersion;
		FlxG.save.data.roomsTraveled = Main.run.roomsTraveled;
		FlxG.save.data.cheatedThisRun = Main.run.cheatedThisRun;
		FlxG.save.data.combo = Main.run.combo;
		FlxG.save.data.nextBoss = Type.getClassName(Type.getClass(Main.run.nextBoss));
		var serializedPlayers = "";
		for (entity in Main.run.players)
		{
			var builder = "";
			if (entity.handWeapon != null)
			{
				builder += Type.getClassName(Type.getClass(entity.handWeapon)) + ":";
			}
			else
			{
				builder += "null:";
			}
			if (entity.holsteredWeapon != null)
			{
				builder += Type.getClassName(Type.getClass(entity.holsteredWeapon)) + ":";
			}
			else
			{
				builder += "null:";
			}
			builder += entity.tokens + ":";
			builder += entity.health + ":";
			for (key => attribute in entity.attributes)
			{
				builder += key.id + "*";
				builder += attribute.defaultValue + "*";
				builder += attribute.min + "*";
				builder += attribute.max + "*";
				for (container in attribute.modifiers)
				{
					if (attribute.temporaryModifiers.exists(container))
						continue; // we dont save temporary attributes but dont tell anyone shhh
					builder += container.operation.getName() + "$" + container.amount + "]";
				}
				builder += "}";
			}
			builder += ",";
			serializedPlayers += builder;
		}
		FlxG.save.data.players = serializedPlayers;
	}

	public static function readSaveFile()
	{
		Main.run = new Run();
		if (Main.activeInputs.length == 0)
		{
			Main.kbmConnected = true;
			Main.connectionsDirty = true;
			Main.activeInputs.push(new KeyboardSource());
		}
		Main.run.roomsTraveled = FlxG.save.data.roomsTraveled;
		Main.run.combo = FlxG.save.data.combo;
		Main.run.cheatedThisRun = FlxG.save.data.cheatedThisRun;
		Main.run.brokeWindow = true;
		Main.run.nextBoss = Type.createInstance(Type.resolveClass(FlxG.save.data.nextBoss), [0, 0]);
		var pArrayString:String = FlxG.save.data.players;
		var i = 0;
		for (e in pArrayString.split(","))
		{
			if (e == "")
				continue;
			var input = new InputSource();
			if (i < Main.activeInputs.length)
			{
				input = Main.activeInputs[i];
			}
			else
			{
				continue;
			}
			Main.run.players[i] = new PlayerEntity(0, 0, "Player " + i);
			Main.run.players[i].input = input;
			var handWeaponData = e.split(":")[0];
			trace(handWeaponData);
			if (handWeaponData != "null")
			{
				Main.run.players[i].handWeapon = Type.createInstance(Type.resolveClass(handWeaponData), [Main.run.players[i]]);
			}
			var holsteredWeaponData = e.split(":")[1];
			trace(holsteredWeaponData);
			if (holsteredWeaponData != "null")
			{
				Main.run.players[i].holsteredWeapon = Type.createInstance(Type.resolveClass(holsteredWeaponData), [Main.run.players[i]]);
			}
			Main.run.players[i].tokens = Std.parseInt(e.split(":")[2]);
			Main.run.players[i].health = Std.parseFloat(e.split(":")[3]);
			for (attributeString in e.split(":")[4].split("}"))
			{
				trace(attributeString);
				if (attributeString == "")
					continue;
				for (type in [
					Attribute.ATTACK_DAMAGE,
					Attribute.ATTACK_KNOCKBACK,
					Attribute.ATTACK_SPEED,
					Attribute.CRIT_CHANCE,
					Attribute.CROUCH_SCALE,
					Attribute.DASH_SPEED,
					Attribute.JUMP_COUNT,
					Attribute.JUMP_HEIGHT,
					Attribute.MAX_HEALTH,
					Attribute.MOVEMENT_SPEED,
					Attribute.REGENERATION,
					Attribute.SIZE_X,
					Attribute.SIZE_Y
				])
				{
					if (type.id == attributeString.split("*")[0])
					{
						Main.run.players[i].attributes.set(type, new Attribute(Std.parseFloat(attributeString.split("*")[1])));
						Main.run.players[i].attributes.get(type).min = Std.parseFloat(attributeString.split("*")[2]);
						Main.run.players[i].attributes.get(type).max = Std.parseFloat(attributeString.split("*")[3]);
						for (attributeString2 in attributeString.split("*")[4].split("]"))
						{
							if (attributeString2 != "")
							{
								var attributeContainer:AttributeContainer = new AttributeContainer(Attribute.parseOperation(attributeString2.split("$")[0]),
									Std.parseFloat(attributeString2.split("$")[1]));
								Main.run.players[i].attributes.get(type).addOperation(attributeContainer);
							}
						}
					}
				}
			}
			i++;
		}
	}

	var s = 0.0;
	var targetAngle = 0.0;
	var originalAngle = 0.0;
	var selection = null;
	var breath = 1.0;
	var makeSureMusicFadesOut = 0.0;
	var autosavingText:FlxText = new FlxText(FlxG.width - 400, FlxG.height - 150, 0, "Autosaving...", 32);
	var shader = new AttributesSlotTextShader();

	function pickNextBoss()
	{

		if (Main.run.nextBoss == null || Main.run.nextBoss.ragdoll != null || !Main.run.nextBoss.alive)
		{
			Main.run.nextBoss = [
				new RobotBoss(FlxG.width / 2, FlxG.height / 2),
				new BIGEVILREDCUBE(FlxG.width / 2, FlxG.height / 2),
				new RatKingBoss(0, 0)
			][FlxG.random.int(0, 2)];
			if (FlxG.random.bool(5) && FlxG.save.data.hasPlayedOneNormalMatch)
			{
				Main.run.nextBoss = new DrunkDriveDaveBoss(0, 0);
			}
			FlxG.save.data.hasPlayedOneNormalMatch = true;
			FlxG.save.flush();
		}
	}


	override function update(elapsed:Float)
	{
		makeSureMusicFadesOut += elapsed;
		pickNextBoss();
		shader.elapsed.value[0] += elapsed;
		Main.detectConnections();
		var gamepadAccepted = false;
		for (i in Main.activeInputs)
		{
			if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1))
			{
				if (i.getMovementVector().y == 1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
					selection += 1;
				}
				if (i.getMovementVector().y == -1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
					selection -= 1;
				}
			}
			i.lastMovement.y = i.getMovementVector().y;
			if (i.ui_accept)
			{
				FlxG.sound.play(AssetPaths.menu_accept__ogg, Main.UI_VOLUME);
				gamepadAccepted = true;
			}
		}
		elevator.screenCenter();
		elevator.y += Math.sin(s) * 30;
		bg.x = elevator.x - (bg.width + 120);
		bg.y = elevator.y - 128;
		card.x = elevator.x + (card.width + 120);
		card.y = elevator.y;
		combo.y = elevator.getGraphicBounds().bottom + 20;
		combo.screenCenter(X);
		combo.text = "COMBO x" + Main.run.combo; 
		gambleButton.x = bg.getGraphicMidpoint().x - (gambleButton.width / 2);
		gambleButton.y = (bg.getGraphicMidpoint().y - (gambleButton.height / 2)) - 100;
		continueButton.x = bg.getGraphicMidpoint().x - (continueButton.width / 2);
		continueButton.y = (bg.getGraphicMidpoint().y - (continueButton.height / 2)) + 100;
		s += elapsed;
		breath += elapsed * 0.3;
		elevator.angle = FlxMath.lerp(originalAngle, targetAngle, breath);

		if (breath >= 1)
		{
			breath = 0;
			targetAngle = FlxG.random.float(-8, 8);
			originalAngle = elevator.angle;

		}
		card.visible = selection != null;
		if (selection <= -1)
		{
			selection = 50;
		}
		if (selection >= 2)
		{
			selection = 0;
		}
		gambleButton.animation.play("i");
		continueButton.animation.play("i");
		if (FlxG.mouse.overlaps(gambleButton) && selection != 0)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
			selection = 0;
		}
		if (FlxG.mouse.overlaps(continueButton) && selection != 1)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
			selection = 1;
		}

		text.y = card.y + (7 * 1.5);
		text.x = card.x + (7 * 1.5);
		description.y = text.y + (text.height + 12);
		description.x = text.x;

		switch (selection)
		{
			case 0:
				gambleButton.animation.play("p");
				text.text = Language.get("area.gamblezone");
				description.text = Language.get("area.gamblezone.description");
				description.applyMarkup(description.text, [
					new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GRAY, false, true), "|"),
					new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, false, false, FlxColor.RED.getDarkened(0.5), false), "`"),
					new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLUE, false, false, FlxColor.YELLOW.getDarkened(0.5), false), "@")
				]);
				if (gamepadAccepted && makeSureMusicFadesOut > 0.25)
				{
					TransitionableState.screengrab();
					PlayState.forcedBg = AssetPaths._city__png;
					FlxG.switchState(new PlayState());
				}
			case 1:
				continueButton.animation.play("p");
				text.text = Language.get("entity." + Main.run.nextBoss.typeTranslationKey);
				description.text = Language.get("entity." + Main.run.nextBoss.typeTranslationKey + ".description")
					+ "\n\n`Health: "
					+ Main.run.nextBoss.attributes.get(Attribute.MAX_HEALTH).refreshAndGetValue()
					+ "`\n@Level "
					+ (Main.run.roomsTraveled + 1)
					+ " boss@";
				if (antiEpilepsy < 0)
				{
					antiEpilepsy = 0.25;
					randomColor = FlxG.random.color();
					randomColor2 = FlxG.random.color();
				}
				description.applyMarkup(description.text, [
					new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.GRAY, false, true), "|"),
					new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.RED, false, false, FlxColor.RED.getDarkened(0.5), false), "`"),
					new FlxTextFormatMarkerPair(new FlxTextFormat(FlxColor.BLUE, false, false, FlxColor.YELLOW.getDarkened(0.5), false), "@"),
					new FlxTextFormatMarkerPair(new FlxTextFormat(randomColor, FlxG.random.bool(50), FlxG.random.bool(50), randomColor2,
						FlxG.random.bool(50)), "#")
				]);
				if (gamepadAccepted && makeSureMusicFadesOut > 0.25)
				{
					TransitionableState.screengrab();
					PlayState.forcedBg = null;
					FlxG.switchState(new PlayState());
				}
		}
		antiEpilepsy -= elapsed;
		super.update(elapsed);
	}
	var antiEpilepsy = 0.25;
	var randomColor = FlxColor.BLACK;
	var randomColor2 = FlxColor.BLACK;
}