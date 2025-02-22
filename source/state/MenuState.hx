package state;

import entity.bosses.TutorialBoss;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import openfl.display.BitmapData;
import shader.AttributesSlotTextShader;
import shader.MouthwashingFadeOutEffect;
import substate.CreditsSubState;
import substate.PotentialCrashSubState;
import substate.SettingsSubState;
import ui.MenuTextButton;
import util.Language;
import util.Run;
#if cpp
import hxvlc.flixel.FlxVideoSprite;
import steamwrap.api.Steam;
#end

class MenuState extends TransitionableState
{
	var title:FlxText = new FlxText(0, 0, 0, "Drunk'n'Roullete", 64);
	var play:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.start"), 32);
	var newGame:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.newGame"), 32);
	var storyMode:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.storyMode"), 32);
	var back:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.back"), 32);
	var continueButton:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.continue"), 32);
	var options:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.options"), 32);
	var credits:MenuTextButton = new MenuTextButton(0, 0, 0, Language.get("button.credits"), 32);
	var connectedPlayers:FlxText = new FlxText(20, 20, 0, "No Players Connected", 16);
	var itchIsBroken:FlxText = new FlxText(0, 0, 0, Language.get("button.start"), 32);
	var menuSelectables:Array<MenuTextButton> = [];
	var wasPlayingVideo = false;
	var highScore:FlxText = new FlxText(0, FlxG.height - 48, "HIGHEST TOKENS: 0", 32);
	var basicSelectables = [];

	override function create()
	{
		Main.gameMusic.loadEmbedded(AssetPaths.gamemusic__ogg, true);
		credits.onUsed = () ->
		{
			var tempState:CreditsSubState = new CreditsSubState();
			openSubState(tempState);
		};
		options.onUsed = () ->
		{
			var tempState:SettingsSubState = new SettingsSubState();
			openSubState(tempState);
		}
		continueButton.onUsed = () ->
		{
			PlayState.storyMode = false;
			if (FlxG.save.data.run != Main.saveFileVersion)
			{
				openSubState(new PotentialCrashSubState(FlxG.save));
				return;
			}
			MidState.readSaveFile(FlxG.save);
			FlxG.switchState(new MidState());
		};
		storyMode.onUsed = () ->
		{
			if (waitForFadeOut < 0)
			{
				var storyModeSaveFile:FlxSave = new FlxSave();
				storyModeSaveFile.bind("dnr_story");
				PlayState.storyMode = true;
				if (storyModeSaveFile.data.run != null)
				{
					if (storyModeSaveFile.data.run != Main.saveFileVersion)
					{
						openSubState(new PotentialCrashSubState(storyModeSaveFile));
						return;
					}
					MidState.readSaveFile(storyModeSaveFile);
					var state = new MidState();
					state.shaderToApply = new MouthwashingFadeOutEffect();
					FlxG.switchState(state);
				}
				else
				{
					PlayState.forcedBg = AssetPaths._lobby__png;
					PlayState.storyMode = true;
					Main.run = new Run();
					Main.run.progression = 0;
					Main.run.nextBoss = new TutorialBoss(0, 0);
					#if html5
					Main.playVideo(AssetPaths.intro__mp4);
					#end
					#if cpp
					FlxG.switchState(new CppVideoState(AssetPaths.intro__mp4, () ->
					{
						var state = new PlayState();
						state.shaderToApply = new MouthwashingFadeOutEffect();
						FlxG.switchState(state);
					}));
					#end
				}
			}
		};
		newGame.onUsed = () ->
		{
			PlayState.storyMode = false;
			#if cpp
			Steam.setAchievement("ENDLESS_UNLOCK_AND_PLAY");
			#end
			if (waitForFadeOut < 0)
			{
				var state = new PlayState();
				state.shaderToApply = new MouthwashingFadeOutEffect();
				FlxG.switchState(state);
			}
		};
		back.onUsed = () ->
		{
			selection = 0;
			menuSelectables = basicSelectables;
		};
		play.onUsed = () ->
		{
			if (FlxG.save.data.run == null)
			{
				menuSelectables = [storyMode, newGame, back];
			}
			else
			{
				menuSelectables = [storyMode, newGame, continueButton, back];
			}

		};
		FlxG.save.bind("brj2025");
		Main.run = null;
		if (FlxG.save.data.seenIntro)
		{
			var casnio = new FlxSprite(0, 0, AssetPaths.casniobackground__png);
			casnio.alpha = 0.2;
			add(casnio);
		}
		title.screenCenter();
		add(title);
		title.y -= 128;
		add(play);
		add(options);
		add(connectedPlayers);
		add(continueButton);
		add(credits);
		add(newGame);
		add(back);
		add(storyMode);
		menuSelectables = [play, options, credits];
		basicSelectables = menuSelectables;
		highScore.color = FlxColor.LIME;
		if (FlxG.save.data.highestTokens != null)
		{
			add(highScore);
			highScore.text = StringTools.replace(Language.get("menu.highScore"), "%1", FlxG.save.data.highestTokens);
			highScore.screenCenter(X);
			if (!FlxG.save.data.shadersDisabled)
			{
				s.modulo.value[0] = 999;
				highScore.shader = s;
			}
			else
			{
				highScore.color = FlxColor.YELLOW;
			}
		}
		#if cpp
		Steam.setRichPresence("steam_display", "#Status_MainMenu");
		#end
		super.create();
	}

	var s = new AttributesSlotTextShader();
	var selection = 0;
	var waitForFadeOut = 0.3;
	override function update(elapsed:Float)
	{
		s.elapsed.value[0] += elapsed;
		waitForFadeOut -= elapsed;
		if (Main.playingVideo)
		{
			wasPlayingVideo = true;
			return;
		}
		if (wasPlayingVideo)
		{
			var state = new PlayState();
			state.shaderToApply = new MouthwashingFadeOutEffect();
			FlxG.switchState(state);
			return;
		}
		Main.detectConnections();
		var gamepadAccepted = FlxG.mouse.justPressed;
		connectedPlayers.text = Language.get("menu.controllerWarning");
		var e = 0;
		for (i in Main.activeInputs)
		{
			e++;
			connectedPlayers.text += "\n\nPlayer " + e + " (" + Language.get(i.translationKey) + ")";
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
			if (i.ui_deny)
			{
				selection = 0;
				menuSelectables = basicSelectables;
			}
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
		if (FlxG.save.data.run != null) 
		{
			continueButton.visible = true;
		}
		else
		{
			continueButton.visible = true;
		}

		play.screenCenter();
		continueButton.visible = FlxG.save.data.run != null;
		var i = 0;
		forEachOfType(MenuTextButton, (mtb) ->
		{
			mtb.visible = false;
		});
		for (button in menuSelectables)
		{
			i++;
			button.visible = true;
			button.screenCenter();
			button.y += 64 * i;
		}
		super.update(elapsed);
	}
}