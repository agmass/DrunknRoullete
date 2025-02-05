package state;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.colyseus.Client;
import ui.MenuTextButton;
import util.Language;
import util.MultiplayerManager;

class MultiplayerState extends TransitionableState
{
	var back:MenuTextButton;
	var hostNewGame:MenuTextButton;
	var texts:FlxSpriteGroup = new FlxSpriteGroup(0, 0);
	var namemap:Map<MenuTextButton, String> = [];
	var menuSelectables:Array<MenuTextButton> = [];

	override public function create()
	{
		Main.multiplayerManager = new MultiplayerManager();
		back = new MenuTextButton(0, 0, 0, Language.get("button.back"), 32);
		back.screenCenter();
		back.y -= 32;
		back.onUsed = () ->
		{
			Main.multiplayerManager = null;
			FlxG.switchState(new MenuState());
		};
		add(back);
		hostNewGame = new MenuTextButton(0, 0, 0, Language.get("button.hostNew"), 32);
		hostNewGame.screenCenter();
		hostNewGame.y -= 32;
		hostNewGame.onUsed = () ->
		{
			Main.run = null;
			Main.multiplayerManager.hostNewGame();
		};
		add(hostNewGame);
		menuSelectables = [back, hostNewGame];

		Main.multiplayerManager.client.getAvailableRooms("my_room", function(err, rooms)
		{
			if (err != null)
			{
				Main.multiplayerManager = null;
				FlxG.switchState(new MenuState());
				return;
			}

			for (room in rooms)
			{
				trace(room.roomId);
				trace(room.clients);
				trace(room.maxClients);
				trace(room.metadata);
				var text:MenuTextButton = new MenuTextButton(0, 0, 0, "Room" + " [" + room.clients + "/" + room.maxClients + "]", 32);
				text.screenCenter();
				text.y += 32 * texts.length;
				texts.add(text);
				text.onUsed = () ->
				{
					Main.run = null;
					Main.multiplayerManager.joinNewGame(room.roomId);
				};
				add(text);
				FlxG.camera.follow(text);
				menuSelectables.push(text);
			}
		});

		super.create();
	}

	override function destroy()
	{
		super.destroy();
	}

	public static var targetRoomId = "";

	var selection = 0;

	override public function update(elapsed:Float)
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
		if (FlxG.mouse.justPressed)
			gamepadAccepted = true;
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
				FlxG.camera.follow(menuText);
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
		i = 0;
		for (button in menuSelectables)
		{
			i++;
			button.screenCenter();
			button.y += 64 * i;
		}
		super.update(elapsed);
	}
}