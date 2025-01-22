package state;

import abilities.attributes.Attribute;
import entity.bosses.BIGEVILREDCUBE;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import objects.Elevator;
import ui.ElevatorButton;
import util.Language;

class MidState extends TransitionableState
{
	var elevator:Elevator = new Elevator(0, 0);
	var bg:FlxSprite = new FlxSprite(0, 0, AssetPaths.elevator_buttons_bg__png);
	public var gambleButton:ElevatorButton = new ElevatorButton(1);
	public var continueButton:ElevatorButton = new ElevatorButton(0);
	var card:FlxSprite = new FlxSprite(0, 0, AssetPaths.attribute_bg__png);
	var text:FlxText = new FlxText(0, 0, 0, "", 24);
	var description:FlxText = new FlxText(0, 0, 240 * 1.5, "", 13);

	override function create()
	{
		elevator.screenCenter();
		add(elevator);
		add(bg);
		add(gambleButton);
		add(continueButton);
		add(card);
		add(text);
		add(description);
		text.color = FlxColor.BLACK;
		description.color = FlxColor.BLACK;
		card.scale.set(1.5, 1.5);
		card.updateHitbox();
		bg.scale.set(2, 2);
		bg.updateHitbox();
		super.create();
	}

	var s = 0.0;
	var targetAngle = 0.0;
	var originalAngle = 0.0;
	var selection = 0;
	var breath = 1.0;


	override function update(elapsed:Float)
	{   
		if (Main.run.nextBoss == null || Main.run.nextBoss.ragdoll != null || !Main.run.nextBoss.alive)
		{
			Main.run.nextBoss = new BIGEVILREDCUBE(FlxG.width / 2, FlxG.height / 2);
		}
		Main.detectConnections();
		var gamepadAccepted = false;
		for (i in Main.activeInputs)
		{
			if (FlxMath.roundDecimal(i.getMovementVector().y, 1) != FlxMath.roundDecimal(i.lastMovement.y, 1))
			{
				if (i.getMovementVector().y == 1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg);
					selection += 1;
				}
				if (i.getMovementVector().y == -1)
				{
					FlxG.sound.play(AssetPaths.menu_select__ogg);
					selection -= 1;
				}
			}
			i.lastMovement.y = i.getMovementVector().y;
			if (i.ui_accept)
			{
				FlxG.sound.play(AssetPaths.menu_accept__ogg);
				gamepadAccepted = true;
			}
		}
		bg.x = elevator.x - (bg.width + 120);
		bg.y = elevator.y - 128;
		card.x = elevator.x + (card.width + 120);
		card.y = elevator.y;
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
		if (FlxG.keys.justPressed.P)
		{
			FlxG.switchState(new PlayState());
		}
		elevator.y += Math.sin(s) * 0.3;
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
			FlxG.sound.play(AssetPaths.menu_select__ogg);
			selection = 0;
		}
		if (FlxG.mouse.overlaps(continueButton) && selection != 1)
		{
			FlxG.sound.play(AssetPaths.menu_select__ogg);
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
				if (gamepadAccepted)
				{
					TransitionableState.screengrab();
					PlayState.forcedBg = AssetPaths._city__png;
					FlxG.switchState(new PlayState());
				}
			case 1:
				continueButton.animation.play("p");
				text.text = Language.get("entity." + Main.run.nextBoss.typeTranslationKey);
				description.text = Language.get("entity." + Main.run.nextBoss.typeTranslationKey + ".description")
					+ "\n\nHealth: "
					+ Main.run.nextBoss.attributes.get(Attribute.MAX_HEALTH).refreshAndGetValue();
				if (gamepadAccepted)
				{
					TransitionableState.screengrab();
					PlayState.forcedBg = null;
					FlxG.switchState(new PlayState());
				}
		}
		super.update(elapsed);
	}
}