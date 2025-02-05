package substate;

import entity.PlayerEntity;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.addons.ui.FlxUITabMenu;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import input.ControllerSource;
import input.InputSource;
import input.KeyboardSource;
import ui.MenuTextButton;

class InputManagerSubState extends FlxSubState
{
	var bg:FlxUITabMenu;
	var uicam:FlxCamera = new FlxCamera();

	var input:InputSource;

	var replacePlayerOne:MenuTextButton = new MenuTextButton(0, 0, 0, "Replace Player 1", 32);

	var addNew:MenuTextButton = new MenuTextButton(0, 0, 0, "Add New Player", 32);
	var menuSelectables:Array<MenuTextButton>;

	override public function new(input:InputSource)
	{
		super();
		this.input = input;
	}

	override public function create():Void
	{
		uicam.bgColor.alpha = 0;
		FlxG.cameras.add(uicam, false);
		uicam.zoom = 1.75;
		bg = new FlxUITabMenu(null, []);
		bg.scrollFactor.set();
		FlxG.save.bind("brj2025");
		super.create();
		bg.resize(FlxG.width / 3, FlxG.height / 4);
		bg.screenCenter();
		add(bg);
		bg.camera = uicam;
		bg.add(replacePlayerOne);
		bg.add(addNew);
		add(replacePlayerOne);
		add(addNew);
		replacePlayerOne.camera = uicam;
		addNew.camera = uicam;
		replacePlayerOne.x = bg.getMidpoint().x - (replacePlayerOne.width / 2);
		replacePlayerOne.y = bg.getMidpoint().y - (replacePlayerOne.height / 2);
		replacePlayerOne.y -= 32;
		addNew.x = bg.getMidpoint().x - (addNew.width / 2);
		addNew.y = bg.getMidpoint().y - (addNew.height / 2);
		addNew.y += 32;
		menuSelectables = [replacePlayerOne, addNew];

		addNew.onUsed = () ->
		{
			Main.connectionsDirty = true;
			close();
		};
		replacePlayerOne.onUsed = () ->
		{
			Main.activeInputs = [input];
			if (input is ControllerSource)
			{
				Main.kbmConnected = false;
			}
			if (input is KeyboardSource)
			{
				Main.activeGamepads = [];
			}
			if (FlxG.state is PlayState)
			{
				var ps:PlayState = cast(FlxG.state);
				if (ps.playerLayer.length > 0)
				{
					cast(ps.playerLayer.members[0], PlayerEntity).input = input;
				}
				ps.takenInputs.push(input);
			}
			if (Main.run != null)
			{
				if (Main.run.players.length > 0)
				{
					cast(Main.run.players[0], PlayerEntity).input = input;
				}
			}
			Main.connectionsDirty = true;
			close();
		};
	}

	override function close()
	{
		// FlxG.cameras.remove(uicam);
		// uicam.destroy();
		super.close();
	}

	override function destroy()
	{
		super.destroy();
	}

	var selection = 0;

	override public function update(elapsed:Float):Void
	{
		Main.detectConnections(elapsed);
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
		var i = 0;
		for (menuText in menuSelectables)
		{
			menuText.selected = false;
			if (FlxG.mouse.overlaps(menuText) && selection != i)
			{
				selection = i;
				FlxG.sound.play(AssetPaths.menu_select__ogg, Main.UI_VOLUME);
			}
			if (selection == i)
			{
				menuText.selected = true;
				if (gamepadAccepted)
				{
					menuText.onUsed();
				}
			}
			i++;
		}
		if (selection <= -1)
		{
			selection = i - 1;
		}
		if (selection >= menuSelectables.length)
		{
			selection = 0;
		}
		super.update(elapsed);
	}
}