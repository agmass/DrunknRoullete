package;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import abilities.equipment.items.BasicProjectileShootingItem;
import abilities.equipment.items.BazookaItem;
import abilities.equipment.items.Gamblevolver;
import abilities.equipment.items.HammerItem;
import abilities.equipment.items.RatGun;
import abilities.equipment.items.SwordItem;
import backgrounds.CityBackground;
import backgrounds.LobbyBackground;
import backgrounds.PlatformerBackground;
import backgrounds.TrueCityBackground;
import entity.Entity;
import entity.EquippedEntity;
import entity.HumanoidEntity;
import entity.PlayerEntity;
import entity.bosses.BIGEVILREDCUBE;
import entity.bosses.DrunkDriveDaveBoss;
import entity.bosses.RatKingBoss;
import entity.bosses.RobotBoss;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.mappings.SwitchProMapping;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import input.ControllerSource;
import input.KeyboardSource;
import nape.geom.Vec2;
import objects.DroppedItem;
import objects.Elevator;
import objects.FootstepChangingSprite;
import objects.ImmovableFootstepChangingSprite;
import objects.SlotMachine;
import objects.SpriteToInteract;
import objects.WheelOfFortune;
import objects.hitbox.ExplosionHitbox;
import objects.hitbox.Hitbox;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.filters.ShaderFilter;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import shader.AttributesSlotTextShader;
import shader.ChromaticShader;
import shader.GlowInTheDarkShader;
import sound.FootstepManager.MultiSoundManager;
import state.MenuState;
import state.TransitionableState;
import substate.PauseSubState;
import substate.RoulleteSubState;
import substate.SlotsSubState;
import substate.WheelSubState;
import ui.InGameHUD;
import util.EnviornmentsLoader;
import util.Language;
import util.Projectile;
import util.Run;
import util.SubtitlesBox;
#if cpp
import steamwrap.api.Steam;
#end

class PlayState extends TransitionableState
{

	var playerMarkerColors = [
		FlxColor.BLUE,
		FlxColor.RED,
		FlxColor.GREEN,
		FlxColor.YELLOW,
		FlxColor.PURPLE,
		FlxColor.CYAN,
		FlxColor.LIME,
		FlxColor.ORANGE,
		FlxColor.WHITE,
		FlxColor.BROWN,
		FlxColor.PINK
	];
	var playerDebugText:FlxText = new FlxText(10,10,0);

	public var mapLayerFront:FlxSpriteGroup = new FlxSpriteGroup();
	public var mapLayerMiddle:FlxSpriteGroup = new FlxSpriteGroup();
	public var mapLayerBehind:FlxSpriteGroup = new FlxSpriteGroup();
	public var interactable:FlxSpriteGroup = new FlxSpriteGroup();
	public var mapLayer:FlxSpriteGroup = new FlxSpriteGroup();
	public var playerLayer:FlxSpriteGroup = new FlxSpriteGroup();
	public var enemyLayer:FlxSpriteGroup = new FlxSpriteGroup();
	public var gameCam:FlxCamera = new FlxCamera();
	var HUDCam:FlxCamera = new FlxCamera();
	public var playersSpawned = false;
	public var elevator:Elevator = new Elevator(0, 0);

	public var gameHud:InGameHUD = new InGameHUD();
	public static var forcedBg = null;
	var platformerStage = false;
	public var music_track_gambling:FlxSound = new FlxSound();
	public var music_track_gambling_in_menu:FlxSound = new FlxSound();

	public static var gamblingTrackLastPos = 0.0;

	var slotsShader = new AttributesSlotTextShader();
	var tokensText:FlxText = new FlxText(0, 0, 0, "0 TOKENS", 64);

	override function destroy()
	{
		remove(Main.subtitlesBox);
		saveToRun();
		music_track_gambling_in_menu.fadeOut(0.23);
		music_track_gambling.fadeOut(0.23);
		Main.gameMusic.fadeOut(0.23, 0, (p) ->
		{
			Main.gameMusic.pause();
		});
		Main.napeSpace.clear();
		Main.napeSpaceAmbient.clear();
		super.destroy();
	}
	var bgName = "";

	override function openSubState(SubState:FlxSubState)
	{
		if (SubState is SlotsSubState || SubState is WheelSubState)
		{
			if (music_track_gambling.playing)
			{
				music_track_gambling.fadeOut(0.25);
				music_track_gambling_in_menu.fadeIn(0.25, FlxG.sound.volume);
			}
		}
		super.openSubState(SubState);
	}
	var customBackgroundItems:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	public static var storyMode = false;

	public var storyModeSaveFile:FlxSave = new FlxSave();

	override public function create()
	{
		storyModeSaveFile.bind("dnr_story");
		bgName = EnviornmentsLoader.enviornments[FlxG.random.int(0, EnviornmentsLoader.enviornments.length - 1)];
		if (forcedBg != null)
		{
			bgName = forcedBg;
			forcedBg = null;
		}
		music_track_gambling.loadEmbedded(AssetPaths.about_to_gamble__ogg, true);
		music_track_gambling_in_menu.loadEmbedded(AssetPaths.gambling__ogg, true);
		music_track_gambling_in_menu.volume = 0;
		if (Main.activeInputs.length == 0)
		{
			Main.kbmConnected = true;
			Main.connectionsDirty = true;
			Main.activeInputs.push(new KeyboardSource());
		}
		FlxG.save.bind("brj2025");
		elevator.screenCenter();
		elevator.x -= 512;
		elevator.y = 535 * 1.5;
		elevator.scale.set(1.5, 1.5);
		elevator.updateHitbox();
		interactable.add(elevator);
		if (Main.run == null)
		{
			Main.run = new Run();
			if (!storyMode)
				bgName = AssetPaths._city__png;
			playersSpawned = true;
		}
		else
		{
			if (Main.run.nextBoss != null && bgName != AssetPaths._city__png)
			{
				Main.run.nextBoss.x = elevator.x + 1024;
				Main.run.nextBoss.y = 400;
				enemyLayer.add(Main.run.nextBoss);
				Main.run.roomsTraveled++;
				#if cpp
				Steam.setRichPresence("boss", Language.get("entity." + Main.run.nextBoss.typeTranslationKey));
				Steam.setRichPresence("combo", Main.run.combo + "");
				if (storyMode)
				{
					Steam.setRichPresence("steam_display", "#Status_Story");
				}
				else
				{
					Steam.setRichPresence("steam_display", "#Status_FightingBoss");
				}
				#end
			}
			if (Main.run.players.length > 0)
			{
				for (player in Main.run.players)
				{
					if (player.input != null)
					{
						playerLayer.add(player);
						player.screenCenter();
						takenInputs.push(player.input);
						player.kill();
					}
				}
				var transitionTime = 1.5;
				if (bgName == AssetPaths.backrooms__png)
				{
					transitionTime = 2.5;
					elevator.x -= 512;
					var forklift:FlxSprite = new FlxSprite(elevator.x, (635 * 1.5) - 256, AssetPaths.forklift__png);
					forklift.allowCollisions = NONE;
					mapLayerMiddle.add(forklift);
					elevator.x += 201;
					elevator.y -= 36;
					FlxTween.tween(forklift, {x: forklift.x + 512}, 2);
					FlxTween.tween(elevator, {x: elevator.x + 512}, 2);
				}
				new FlxTimer().start(transitionTime, (t) ->
				{
					new FlxTimer().start(2, (t) ->
					{
						elevator.animation.play("closed");
					});
					elevator.animation.play("open");
					playerLayer.forEachOfType(PlayerEntity, (p) ->
					{
						if (p.alive)
							return;
						p.revive();
						if (bgName == AssetPaths._city__png)
						{
							Main.run.combo = 0;
							p.health = p.attributes.get(Attribute.MAX_HEALTH).getValue();
						}
						p.y = (elevator.y + elevator.height) - p.height;
						p.x = elevator.getMidpoint().x - (p.width / 2);
						playersSpawned = true;
					});
				});
			}
		}
		Main.audioPanner = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		Main.audioPanner.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		FlxG.cameras.reset(gameCam);
		HUDCam.bgColor.alpha = 0;
		FlxG.cameras.add(HUDCam, false);
		var bg = new FlxSprite(0, 0, AssetPaths.test_bg__png);
		bg.alpha = 0.2;
		bg.scrollFactor.set(0, 0);
		add(bg);
		var ground = new ImmovableFootstepChangingSprite(FlxG.width / 2, 1080, "concrete");
		ground.makeGraphic(1920, 250, FlxColor.TRANSPARENT);
		ground.immovable = true;
		mapLayerFront.add(ground);
		var roof = new ImmovableFootstepChangingSprite(FlxG.width / 2, 0, "concrete");
		roof.makeGraphic(1920, 250, FlxColor.TRANSPARENT);
		roof.immovable = true;
		mapLayerFront.add(roof);
		var wall = new ImmovableFootstepChangingSprite(0, 537, "concrete");
		wall.makeGraphic(378, 1080, FlxColor.TRANSPARENT);
		wall.immovable = true;
		mapLayerFront.add(wall);
		var wall2 = new ImmovableFootstepChangingSprite(FlxG.width, 537, "concrete");
		wall2.makeGraphic(378, 1080, FlxColor.TRANSPARENT);
		wall2.immovable = true;
		mapLayerFront.add(wall2);
		var enviornment = new FlxSprite(0, 0);
		enviornment.loadGraphic(bgName);
		var frames = [];
		for (i in 0...Math.ceil(enviornment.width / 1280))
		{
			frames.push(i);
		}
		if (bgName == AssetPaths._platformer__png)
		{
			wall2.body.position.setxy(6000, wall2.body.position.y);

			mapLayerFront.remove(ground);
			mapLayerFront.remove(roof);

			ground = new ImmovableFootstepChangingSprite(3000, 1080, "concrete");
			ground.makeGraphic(6000, 250, FlxColor.TRANSPARENT);
			ground.immovable = true;
			mapLayerFront.add(ground);
			roof = new ImmovableFootstepChangingSprite(3000, 0, "concrete");
			roof.makeGraphic(6000, 250, FlxColor.TRANSPARENT);
			roof.immovable = true;
			mapLayerFront.add(roof);
			platformerStage = true;

			FlxG.camera.setScrollBounds(0, 6000, 0, 1080);
			HUDCam.setScrollBounds(0, 6000, 0, 1080);
			customBackgroundItems = new PlatformerBackground();
		}

		if (platformerStage)
		{
			frames = [];
			for (i in 0...Math.ceil(enviornment.width / 4000))
			{
				frames.push(i);
			}
		}
		enviornment.loadGraphic(bgName, true, platformerStage ? 4000 : 1280, 720);
		enviornment.scale.set(1.5, 1.5);
		enviornment.updateHitbox();
		enviornment.animation.add("idle", frames, 2);
		enviornment.animation.play("idle");
		var enviornmentbg = new FlxSprite(0, 0);
		enviornmentbg.loadGraphic(StringTools.replace(StringTools.replace(bgName, "enviorments", "backgrounds"), ".png", "_back.png"), true,
			platformerStage ? 4000 : 1280, 720);
		enviornmentbg.scale.set(1.5, 1.5);
		enviornmentbg.updateHitbox();
		enviornmentbg.animation.add("idle", frames, 2);
		enviornmentbg.animation.play("idle");
		add(Main.subtitlesBox);
		Main.subtitlesBox.visible = false;
		Main.subtitlesBox.camera = HUDCam;
		// playerLayer.add(new PlayerEntity(900, 20, "Player 1"));
		slotsShader.modulo.value = [9999.99];
		if (bgName == AssetPaths._city__png)
		{
			#if cpp
			Steam.setRichPresence("steam_display", "#Status_Gambling");
			#end
			ground.footstepSoundName = "wood";
			elevator.x = 939 * 1.5;
			var slotMachine = new FlxSprite(160 * 1.5, 546 * 1.5);
			slotMachine.loadGraphic(AssetPaths.broken_slot_machine__png);
			slotMachine.immovable = true;
			slotMachine.allowCollisions = NONE;
			mapLayerBehind.add(slotMachine);
			var slotMachine = new SlotMachine(255 * 1.5, 546 * 1.5);
			slotMachine.loadGraphic(AssetPaths.slot_machine__png);
			slotMachine.immovable = true;
			interactable.add(slotMachine);
			if (!FlxG.save.data.shadersDisabled)
				slotMachine.shader = slotsShader;
			var slotMachine = new SlotMachine(352 * 1.5, 546 * 1.5);
			slotMachine.loadGraphic(AssetPaths.broken_slot_machine__png);
			slotMachine.immovable = true;
			slotMachine.allowCollisions = NONE;
			mapLayerBehind.add(slotMachine);
			var wheel = new WheelOfFortune(583 * 1.5, ground.y - (246 * 1.5));
			wheel.loadGraphic(AssetPaths.weapon_wheel__png);
			wheel.scale.set(2, 2);
			wheel.updateHitbox();
			wheel.immovable = true;
			if (!FlxG.save.data.shadersDisabled)
				wheel.shader = slotsShader;
			interactable.add(wheel);
			music_track_gambling.play(false);
			music_track_gambling_in_menu.play(false);
			customBackgroundItems = new CityBackground();
		}
		else
		{
			Main.gameMusic.play();
			Main.gameMusic.fadeIn(0.23);
		}
		if (!FlxG.save.data.shadersDisabled)
			gameCam.filters = [new ShaderFilter(chrome)];
		if (bgName == AssetPaths._lobby__png)
		{
			customBackgroundItems = new LobbyBackground();
		}
		if (bgName == AssetPaths.winbig__png)
		{
			ground.footstepSoundName = "carpet";
			/*var table = new FootstepChangingSprite(FlxG.random.int(300, 1200), ground.y - 16, "wood");
			table.loadGraphic(AssetPaths.table__png);
			table.createRectangularBody();
			table.body.space = Main.napeSpace;
			table.setBodyMaterial(-1, 4, 4, 2, 0);
			table.immovable = true;
					mapLayerBehind.add(table); */
		}
		if (bgName == AssetPaths.backrooms__png)
		{
			mapLayerFront.remove(wall);
			mapLayerFront.remove(wall2);
			wall.body.space = null;
			wall.ambientEdition.body.space = null;
			wall2.body.space = null;
			wall2.ambientEdition.body.space = null;
			for (i in 0...FlxG.random.int(32, 64))
			{
				var crate = new FootstepChangingSprite(FlxG.random.int(0, 1920 - 61), ground.y - 800, "wood");
				crate.loadGraphic(AssetPaths.crate__png);
				crate.allowCollisions = NONE;
				crate.createRectangularBody();
				crate.body.space = Main.napeSpaceAmbient;
				crate.setBodyMaterial(-1, 4, 4, 2, 0);
				crate.immovable = true;
				mapLayerBehind.add(crate);
			}
		}
		if (bgName == AssetPaths.truecity__png)
		{
			ground.footstepSoundName = "carpet";
			FlxG.camera.color = FlxColor.BLUE.getLightened(0.4);
			customBackgroundItems = new TrueCityBackground();
		}
		mapLayer.add(mapLayerBehind);
		mapLayer.add(mapLayerMiddle);
		mapLayer.add(mapLayerFront);

		playerDebugText.size = 12;
		playerDebugText.visible = false;
		add(customBackgroundItems);
		add(enviornmentbg);
		add(mapLayerBehind);
		add(mapLayerMiddle);
		add(interactable);
		add(enemyLayer);
		add(playerLayer);
		add(mapLayerFront);
		add(enviornment);
		playerDebugText.camera = HUDCam;
		add(playerDebugText);
		gameHud.camera = HUDCam;
		add(gameHud);
		tokensText.camera = HUDCam;
		add(tokensText);
		super.create();
	}
	public var takenInputs = [];
	var oldChrome = 0.00001;
	var kmbConnected = false;

	public var tokensTime = 0.0;
	public var originalTokens = 0.0;

	var chrome = new ChromaticShader();
	var chromeLerp = 0.0;

	override function startOutro(onOutroComplete:() -> Void)
	{
		Main.gameMusic.pitch = 1;
		super.startOutro(onOutroComplete);
	}
	override function onFocusLost()
	{
		if (subState == null)
		{
			var tempState:PauseSubState = new PauseSubState();
			openSubState(tempState);
		}
		super.onFocusLost();
	}

	override function closeSubState()
	{
		if (music_track_gambling.playing)
		{
			music_track_gambling_in_menu.fadeOut(0.25);
			music_track_gambling.fadeIn(0.25, FlxG.sound.volume);
		}
		if (FlxG.save.data.shadersDisabled)
		{
			gameCam.filters = [];
			forEachOfType(FlxSprite, (b) ->
			{
				b.shader = null;
			}, true);
		}

		super.closeSubState();
	}

	var tokensState = 0;
	var musicChanger = 0.0;

	override public function update(elapsed:Float)
	{
		if (platformerStage)
		{
			FlxG.worldBounds.set(FlxG.camera.scroll.x, FlxG.camera.scroll.y, FlxG.width, FlxG.height);
		}
		if (FlxG.timeScale == 0.2)
		{
			musicChanger += elapsed;
			if (musicChanger > 1)
			{
				musicChanger = 1;
			}
			Main.gameMusic.pitch = FlxMath.lerp(Main.gameMusic.pitch, 0.85, musicChanger);
		}
		if (FlxG.timeScale == 1 && musicChanger > 0)
		{
			musicChanger -= elapsed;
			if (musicChanger < 0)
			{
				musicChanger = 0;
			}
			Main.gameMusic.pitch = FlxMath.lerp(1, Main.gameMusic.pitch, musicChanger);
		}
		if (music_track_gambling.fadeTween == null && music_track_gambling.volume != 0)
		{
			music_track_gambling.volume = FlxG.sound.volume;
		}
		if (music_track_gambling_in_menu.fadeTween == null && music_track_gambling_in_menu.volume != 0)
		{
			music_track_gambling_in_menu.volume = FlxG.sound.volume;
		}
		Main.gameMusic.volume = FlxG.sound.volume;
		if (DrunkDriveDaveBoss.quietDownFurEliseIsPlaying)
		{
			music_track_gambling_in_menu.volume = 0;
			music_track_gambling.volume = 0;
			Main.gameMusic.volume = 0;
		}
		else
		{
			Main.gameMusic.volume = Main.MUSIC_VOLUME;
		}
		if (tokensTime > 0)
		{
			FlxG.timeScale = 0.2;
			tokensText.visible = true;
			tokensText.color = FlxColor.CYAN;
			tokensText.screenCenter();
			if (tokensTime == 0.75)
			{
				tokensState = 0;
				tokensText.text = originalTokens + " TOKENS";
				HUDCam.shake(0.0015, 0.1);
				MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "coin", 0.8, Main.OTHER_VOLUME);
			}
			if (tokensTime <= 0.5 && tokensState == 0)
			{
				if (Main.run.combo == 0)
				{
					tokensTime = -0.1;
				}
				else
				{
					tokensText.text = "COMBO x" + Main.run.combo;
					tokensState = 1;
					HUDCam.shake(0.0015, 0.1);
					MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "coin", 1, Main.OTHER_VOLUME);
				}
			}
			if (tokensTime <= 0.25 && tokensState == 1)
			{
				tokensText.text = (originalTokens * Main.run.combo) + " TOKENS";
				tokensState = 2;
				HUDCam.shake(0.0015, 0.1);
				MultiSoundManager.playRandomSoundByItself(Main.audioPanner.x, Main.audioPanner.y, "coin", 1.2, Main.OTHER_VOLUME);
			}
			tokensTime -= elapsed;
			if (tokensTime <= 0)
			{
				FlxG.timeScale = 1;
			}
		}
		else
		{
			tokensText.visible = false;
		}
		slotsShader.elapsed.value[0] += elapsed;
		for (sprite in interactable)
		{
			if (sprite is SpriteToInteract)
			{
				cast(sprite, SpriteToInteract).showTip = false;
			}
		}
		if (Main.napeSpaceAmbient != null && elapsed > 0)
		{
			Main.napeSpaceAmbient.step(elapsed);
		}
		if (Main.napeSpace != null && elapsed > 0)
		{
			Main.napeSpace.step(elapsed);
		}
		Main.detectConnections();
		if (Main.connectionsDirty)
		{
			for (i in Main.activeInputs)
			{
				if (!takenInputs.contains(i))
				{
					var player = new PlayerEntity(900, 20, "Player " + (playerLayer.length + 1));
					player.input = i;
					playerLayer.add(player);
					player.screenCenter();
					takenInputs.push(i);
					if (!Main.run.brokeWindow)
					{
						player.x = 236 * 1.5;
						player.y = -player.height;
						player.noclip = true;
						player.attributes.get(Attribute.MOVEMENT_SPEED).addTemporaryOperation(new AttributeContainer(AttributeOperation.MULTIPLY, 0.05), 0.15);
					}
				}
			}
		}
		var pressedDebugSpawn = false;

		for (i in Main.activeGamepads)
		{
			if (i.justPressed.RIGHT_STICK_CLICK)
			{
				pressedDebugSpawn = true;
			}
		}

		/*#if FLX_DEBUG
			if (FlxG.keys.justPressed.G)
			{
				FlxG.vcr.startRecording(false);
			}
				if (FlxG.keys.justPressed.H)
				{
					var recording = FlxG.vcr.stopRecording();
					FlxG.vcr.loadReplay(recording);
				}
			#end */
		playerDebugText.visible = FlxG.save.data.fpsshown || FlxG.save.data.playerInfoShown;
		Main.subtitlesBox.visible = FlxG.save.data.subtitles;
		if (Main.subtitlesBox.visible && !members.contains(Main.subtitlesBox))
			add(Main.subtitlesBox);
			
		FlxG.fixedTimestep = false;
		var showPlayerMarker = playerLayer.length > 1;
		gameCam.pixelPerfectRender = true;
		playerDebugText.text = "";
		if (FlxG.save.data.fpsshown)
			playerDebugText.text = "\n" + "FPS: " + Main.FPS.currentFPS + "\n";
		var currentBarHeight = 0.0;
		var currentBarIndex = 0;
		if (enemyLayer.getFirstAlive() == null)
		{
			if (Main.gameMusic.playing && Main.gameMusic.fadeTween == null)
			{
				Main.gameMusic.fadeOut(0.23, 0, (p) ->
				{
					Main.gameMusic.pause();
				});
			}
		}
		enemyLayer.forEachOfType(Entity, (p) ->
		{
			if (!p.alive)
			{
				enemyLayer.remove(p, true);
				if (p.ragdoll != null)
				{
					p.ragdoll.body.position.setxy(-1000, -1000);
					p.ragdoll.destroy();
				}
				p.destroy();
				return;
			}
			if (p.bossHealthBar)
			{
				currentBarIndex++;
				p.healthBar.screenCenter(X);
				p.healthBar.y = (80 * currentBarIndex) + currentBarHeight;
				p.nametag.screenCenter(X);
				p.nametag.y = p.healthBar.y - 40;
				currentBarHeight += p.healthBar.height;
				p.healthBar.camera = HUDCam;
				p.nametag.camera = HUDCam;
			}
		});
		enemyLayer.forEachOfType(EquippedEntity, (p) ->
		{
			if (bgName == AssetPaths.backrooms__png)
			{
				if (p.x < -p.width)
				{
					p.x = 1920 - p.width;
				}
				if (p.x > 1920)
				{
					p.x = 0;
				}
				p.collideables.forEachOfType(Projectile, (pr) ->
				{
					if (!pr.returnToShooter)
					{
						if (pr.body != null)
						{
							if (pr.body.position.x < -pr.width)
							{
								pr.body.position.x = 1920 - pr.width;
							}
							if (pr.body.position.x > 1920)
							{
								pr.body.position.x = 0;
							}
						}
					}
				});
			}
			FlxG.collide(p.hitboxes, mapLayer, (c:Hitbox, e) ->
			{
				c.onHitWall();
			});
			FlxG.overlap(p.collideables, enemyLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithEntity(e);
			});
			FlxG.overlap(p.collideables, playerLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithEntity(e);
			});
			FlxG.overlap(p, playerLayer, (c:Entity, e:Entity) ->
			{
				c.onCollideWithEntity(e);
			});
			FlxG.overlap(p.collideables, mapLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithMap();
			});
			FlxG.collide(mapLayer, p.blood, (m, p2) ->
			{
				if (p2 is FlxParticle)
				{
					var part:FlxParticle = cast(p2);
					part.velocity.set(0, 0);
				}
			});
			for (hitbox in p.hitboxes)
			{
				FlxG.overlap(hitbox, this, (h, e) ->
				{
					if (e is Entity)
					{
						if (h is Hitbox)
						{
							var e2:Entity = cast(e);
							var hitbox:Hitbox = cast(h);
							if (!hitbox.hitEntities.contains(e2))
							{
								h.onHit(e2);
							}
						}
					}
				});
			}
		});
		var alivePlayers = 0;
		var playerHealth = 0.0;
		playerLayer.forEachOfType(PlayerEntity, (p) ->
		{
			if (FlxG.save.data.cheats)
			{
				if (FlxG.keys.justPressed.ONE)
				{
					interactable.add(new DroppedItem(p.x, p.y, new SwordItem(p)));
				}
				if (FlxG.keys.justPressed.TWO)
				{
					interactable.add(new DroppedItem(p.x, p.y, new BasicProjectileShootingItem(p)));
				}
				if (FlxG.keys.justPressed.THREE)
				{
					interactable.add(new DroppedItem(p.x, p.y, new Gamblevolver(p)));
				}
				if (FlxG.keys.justPressed.FOUR)
				{
					interactable.add(new DroppedItem(p.x, p.y, new HammerItem(p)));
				}
				if (FlxG.keys.justPressed.FIVE)
				{
					interactable.add(new DroppedItem(p.x, p.y, new RatGun(p)));
				}
				if (FlxG.keys.justPressed.SIX)
				{
					interactable.add(new DroppedItem(p.x, p.y, new BazookaItem(p)));
				}
			}
			if (bgName == AssetPaths.backrooms__png)
			{
				if (p.x < -p.width)
				{
					p.x = 1920 - p.width;
				}
				if (p.x > 1920)
				{
					p.x = 0;
				}
				p.collideables.forEachOfType(Projectile, (pr) ->
				{
					if (!pr.returnToShooter)
					{
						if (pr.body != null)
						{
							if (pr.body.position.x < -pr.width)
							{
								pr.body.position.x = 1920 - pr.width;
							}
							if (pr.body.position.x > 1920)
							{
								pr.body.position.x = 0;
							}
						}
					}
				});
			}
			if (!Main.run.brokeWindow)
			{
				if (p.y > 18 * 1.5)
				{
					playerLayer.forEachOfType(PlayerEntity, (p2) ->
					{
						p2.visible = true;
						p2.noclip = false;
					});
					Main.run.brokeWindow = true;
					MultiSoundManager.playRandomSound(p, "glass_break");
				}
				else
				{
					p.visible = false;
				}
			}
			if (p.alive)
				playerHealth = p.health;
			FlxG.collide(p.hitboxes, mapLayer, (c:Hitbox, e) ->
			{
				c.onHitWall();
			});
			FlxG.overlap(p.collideables, enemyLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithEntity(e);
			});
			FlxG.overlap(p.collideables, playerLayer, (c:Projectile, e:Entity) ->
			{
				if (!FlxG.save.data.friendlyFire && e != p)
					return;
				c.onOverlapWithEntity(e);
			});
			FlxG.overlap(p.collideables, mapLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithMap();
			});
			p.doNotUncrouch = FlxG.overlap(p.crouchChecker, mapLayer);
			if (bgName == AssetPaths._city__png && p.alive)
			{
				if (p.handWeapon != null || p.holsteredWeapon != null)
				{
					elevator.interactable = true;
				}
				else
				{
					elevator.errorTip.text = Language.get("hint.weaponRequired");
				}
			}

			if (p.alive)
				alivePlayers++;
			p.healthBar.camera = HUDCam;
			FlxG.collide(mapLayer, p.blood, (m, p2) ->
			{
				if (p2 is FlxParticle)
				{
					var part:FlxParticle = cast(p2);
					part.velocity.set(0, 0);
				}
			});
			for (hitbox in p.hitboxes)
			{
				FlxG.overlap(hitbox, this, (h, e) ->
				{
					if (e is Entity)
					{
						if (h is Hitbox)
						{
							if (!FlxG.save.data.friendlyFire && e.ID != p.ID && playerLayer.members.contains(e))
								return;
							var e2:Entity = cast(e);
							var hitbox:Hitbox = cast(h);
							if (!hitbox.hitEntities.contains(e2))
							{
								h.onHit(e2);
							}
						}
					}
				});
			}
			if (p.input.ui_menu)
			{
				var tempState:PauseSubState = new PauseSubState();
				openSubState(tempState);
			}
			FlxG.overlap(p, interactable, (a, b) ->
			{
				if (b is SpriteToInteract)
				{
					var sti = cast(b, SpriteToInteract);
					sti.showTip = true;
					if (p.input.interactJustPressed)
					{
						sti.interact(p);
					}
				}
			});
			if (p.playerMarkerColor == FlxColor.TRANSPARENT)
			{
				p.playerMarkerColor = playerMarkerColors[0];
				playerMarkerColors.splice(0,1);
			}
			p.showPlayerMarker = showPlayerMarker;
			if (FlxG.save.data.playerInfoShown)
				playerDebugText.text += p.toString() + "\n\n";
		});
		if (FlxG.save.data.cheats && FlxG.keys.pressed.U || platformerStage)
		{
			FlxG.camera.follow(playerLayer.getFirstAlive());
			HUDCam.follow(playerLayer.getFirstAlive());
		}
		else
		{
			FlxG.camera.target = null;
			HUDCam.target = null;
			FlxG.camera.scroll.x = 0;
			FlxG.camera.scroll.y = 0;
			HUDCam.scroll.x = 0;
			HUDCam.scroll.y = 0;
		}
		if (alivePlayers == 1 && playerHealth <= 50 && !FlxG.save.data.disableChroma)
		{
			chromeLerp += elapsed;
			if (chromeLerp > 1)
			{
				chromeLerp = 0;
			}
			var newChrome = FlxMath.lerp(oldChrome, 0.05 / FlxMath.bound(playerHealth, 10, 100), chromeLerp);
			chrome.setChrome(newChrome);
			oldChrome = newChrome;
		}
		else
		{
			chrome.setChrome(0);
		}
		if (alivePlayers <= 0 && playersSpawned)
		{
			Main.run = new Run();
			if (!storyMode)
			{
				FlxG.save.data.run = null;
				FlxG.save.flush();
			}
			FlxG.switchState(new MenuState());
		}
		noEpilepsy -= elapsed;
		if (gambaTime != -1)
			gambaTime += elapsed;
		super.update(elapsed);
		FlxG.autoPause = false;
		playerLayer.forEachOfType(Entity, (e) ->
		{
			if (!e.noclip)
			{
				FlxG.collide(e, mapLayer, playerWallCollision);
			}
		});
		// FlxG.collide(playerLayer, enemyLayer);
		enemyLayer.forEachOfType(Entity, (e) ->
		{
			if (!e.noclip)
			{
				FlxG.collide(e, mapLayer, playerWallCollision);
			}
		});
	}
	var gambaText1 = "";
	var gambaText2 = "";
	var gambaText3 = "";
	var gambaTime = -1.0;
	var noEpilepsy = 0.0;


	public function playerWallCollision(player:Entity, wall:FlxSprite)
	{
		if (wall is FootstepChangingSprite)
		{
			player.steppingOn = cast(wall, FootstepChangingSprite).footstepSoundName;
		}
	}
	public function saveToRun()
	{
		var newPlayerList = [];
		playerLayer.forEachOfType(PlayerEntity, (p) ->
		{
			p.crouching = false;
			p.attributes.get(Attribute.MOVEMENT_SPEED).removeOperation(p.crouchAttribute_speed);
			p.attributes.get(Attribute.JUMP_HEIGHT).removeOperation(p.crouchAttribute_speed);
			if (!Main.activeInputs.contains(p.input))
			{
				return;
			}
			var copiedPlayer:PlayerEntity = new PlayerEntity(0, 0, p.entityName);
			copiedPlayer.attributes = p.attributes;
			copiedPlayer.health = p.health;
			copiedPlayer.input = p.input;
			copiedPlayer.tokens = p.tokens;
			if (FlxG.save.data.highestTokens == null)
			{
				FlxG.save.data.highestTokens = p.tokens;
				FlxG.save.flush();
			}
			else
			{
				if (p.tokens > FlxG.save.data.highestTokens)
				{
					FlxG.save.data.highestTokens = p.tokens;
					FlxG.save.flush();
				}
			}
			if (p.handWeapon != null)
				copiedPlayer.handWeapon = Type.createInstance(Type.getClass(p.handWeapon), [copiedPlayer]);
			if (p.holsteredWeapon != null)
				copiedPlayer.holsteredWeapon = Type.createInstance(Type.getClass(p.holsteredWeapon), [copiedPlayer]);
			newPlayerList.push(copiedPlayer);
		});
		Main.run.players = newPlayerList;
	}
}
