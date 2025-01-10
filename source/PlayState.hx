package;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.Entity;
import entity.EquippedEntity;
import entity.PlayerEntity;
import entity.bosses.BIGEVILREDCUBE;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeSprite;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.mappings.SwitchProMapping;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import input.ControllerSource;
import input.KeyboardSource;
import nape.geom.Vec2;
import objects.FootstepChangingSprite;
import objects.ImmovableFootstepChangingSprite;
import objects.hitbox.Hitbox;
import substate.PauseSubState;
import util.EnviornmentsLoader;
import util.Language;
import util.Projectile;
import util.SubtitlesBox;

class PlayState extends FlxState
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

	public var mapLayer:FlxSpriteGroup = new FlxSpriteGroup();
	public var playerLayer:FlxSpriteGroup = new FlxSpriteGroup();
	public var enemyLayer:FlxSpriteGroup = new FlxSpriteGroup();

	var gameCam:FlxCamera = new FlxCamera();
	var HUDCam:FlxCamera = new FlxCamera();

	var whatYouGambled:FlxText = new FlxText(0, 0, 0, "", 32);

	override function destroy()
	{
		Main.napeSpace.clear();
		super.destroy();
	}

	override public function create()
	{
		super.create();
		Main.audioPanner = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		Main.audioPanner.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		FlxG.cameras.reset(gameCam);
		HUDCam.bgColor.alpha = 0;
		FlxG.cameras.add(HUDCam, false);
		var bg = new FlxSprite(0, 0, AssetPaths.test_bg__png);
		bg.alpha = 0.2;
		add(bg);
		var ground = new ImmovableFootstepChangingSprite(FlxG.width / 2, 1080, "concrete");
		ground.makeGraphic(1920, 250, FlxColor.TRANSPARENT);
		ground.immovable = true;
		mapLayer.add(ground);
		var roof = new ImmovableFootstepChangingSprite(FlxG.width / 2, 0, "concrete");
		roof.makeGraphic(1920, 250, FlxColor.TRANSPARENT);
		roof.immovable = true;
		mapLayer.add(roof);
		var wall = new ImmovableFootstepChangingSprite(0, 537, "concrete");
		wall.makeGraphic(378, 1080, FlxColor.TRANSPARENT);
		wall.immovable = true;
		mapLayer.add(wall);
		var wall2 = new ImmovableFootstepChangingSprite(FlxG.width, 537, "concrete");
		wall2.makeGraphic(378, 1080, FlxColor.TRANSPARENT);
		wall2.immovable = true;
		mapLayer.add(wall2);
		var enviornment = new FlxSprite(0, 0);
		var bgName = EnviornmentsLoader.enviornments[FlxG.random.int(0, EnviornmentsLoader.enviornments.length - 1)];
		enviornment.loadGraphic(bgName, true, 1280, 720);
		enviornment.setGraphicSize(1920, 1080);
		enviornment.updateHitbox();
		var frames = [];
		for (i in 0...Math.floor(enviornment.width / 1280) + 1)
		{
			frames.push(i);
		}
		enviornment.animation.add("idle", frames, 2);
		enviornment.animation.play("idle");
		var enviornmentbg = new FlxSprite(0, 0);
		enviornmentbg.loadGraphic(StringTools.replace(StringTools.replace(bgName, "enviorments", "backgrounds"), ".png", "_back.png"), true, 1280, 720);
		enviornmentbg.setGraphicSize(1920, 1080);
		enviornmentbg.updateHitbox();
		enviornmentbg.animation.add("idle", frames, 2);
		enviornmentbg.animation.play("idle");
		add(subtitles);
		subtitles.visible = false;
		subtitles.camera = HUDCam;
		// playerLayer.add(new PlayerEntity(900, 20, "Player 1"));
		add(whatYouGambled);
		whatYouGambled.camera = HUDCam;
		if (bgName == AssetPaths.winbig__png)
		{
			ground.footstepSoundName = "carpet";
			var table = new FootstepChangingSprite(FlxG.random.int(300, 1200), 300, "wood");
			table.loadGraphic(AssetPaths.table__png);
			table.createRectangularBody();
			table.body.space = Main.napeSpace;
			table.setBodyMaterial(-1, 4, 4, 2, 0);
			table.immovable = true;
			mapLayer.add(table);
		}

		playerDebugText.size = 12;
		playerDebugText.visible = false;
		add(enviornmentbg);
		add(enemyLayer);
		add(playerLayer);
		add(mapLayer);
		add(enviornment);
		playerDebugText.camera = HUDCam;
		add(playerDebugText);
	}
	var subtitles = new SubtitlesBox();
	var takenGamepads = [];
	var kmbConnected = false;

	override public function update(elapsed:Float)
	{
		if (Main.napeSpace != null && elapsed > 0)
		{
			Main.napeSpace.step(elapsed);
		}
		Main.detectConnections();
		if (Main.connectionsDirty)
		{
			for (i in Main.activeGamepads)
			{
				if (!takenGamepads.contains(i))
				{
					var player = new PlayerEntity(900, 20, "Player " + (playerLayer.length + 1));
					player.input = new ControllerSource(i);
					playerLayer.add(player);
					takenGamepads.push(i);
				}
			}
			if (Main.kbmConnected && !kmbConnected)
			{
				kmbConnected = true;
				var player = new PlayerEntity(900, 20, "Player " + (playerLayer.length + 1));
				player.input = new KeyboardSource();
				playerLayer.add(player);
			}
		}

		#if FLX_DEBUG
			if (FlxG.keys.justPressed.G)
			{
				FlxG.vcr.startRecording(false);
			}
				if (FlxG.keys.justPressed.H)
				{
					var recording = FlxG.vcr.stopRecording();
					FlxG.vcr.loadReplay(recording);
				}
		#end
		if (FlxG.keys.justPressed.I)
		{
			enemyLayer.add(new BIGEVILREDCUBE(FlxG.width / 2, FlxG.height / 2));
		}
		if (FlxG.keys.justPressed.THREE)
		{
			playerDebugText.visible = !playerDebugText.visible;
		}
		if (FlxG.keys.justPressed.K)
		{
			subtitles.visible = !subtitles.visible;
		}
		FlxG.fixedTimestep = false;
		FlxG.autoPause = false;
		var showPlayerMarker = playerLayer.length > 1;
		gameCam.pixelPerfectRender = true;
		playerDebugText.text = "\n" + "FPS: " + Main.FPS.currentFPS + "\n";
		var currentBarHeight = 0.0;
		var currentBarIndex = 0;
		enemyLayer.forEachOfType(Entity, (p) ->
		{
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
		var gambaText = "";
		playerLayer.forEachOfType(PlayerEntity, (p) ->
		{
			FlxG.overlap(p.collideables, enemyLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithEntity(e);
			});
			FlxG.overlap(p.collideables, playerLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithEntity(e);
			});
			FlxG.overlap(p.collideables, mapLayer, (c:Projectile, e:Entity) ->
			{
				c.onOverlapWithMap();
			});
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
			if (FlxG.keys.justPressed.ESCAPE)
			{
				var tempState:PauseSubState = new PauseSubState();
				openSubState(tempState);
			}
			if (FlxG.keys.justPressed.O)
			{
				gambaText += "\n\n" + p.entityName;
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
				gambaText += "\n" + Language.get("attribute." + type.id) + " ";
				if (operation == ADD)
				{
					if (lostOrWon)
					{
						gambaText += "gained +" + amount;
					}
					else
					{
						gambaText += "lost " + amount;
					}
				}
				if (operation == MULTIPLY)
				{
					gambaText += "multiplied x" + amount;
				}
				gambaText += "\n";

				if (!p.attributes.exists(type))
				{
					p.attributes.set(type, new Attribute(0));
					p.attributes.get(type).addOperation(new AttributeContainer(ADD, type.minBound));
				}
				p.attributes.get(type).addOperation(new AttributeContainer(operation, amount));
				if (type == Attribute.SIZE_X)
				{
					p.attributes.get(Attribute.SIZE_Y).addOperation(new AttributeContainer(operation, amount));
				}
				gambaText += Language.get("attribute." + type.id) + " is now at " + p.attributes.get(type).getValue();
			}
			if (p.playerMarkerColor == FlxColor.TRANSPARENT)
			{
				p.playerMarkerColor = playerMarkerColors[0];
				playerMarkerColors.splice(0,1);
			}
			p.showPlayerMarker = showPlayerMarker;
			playerDebugText.text += p.toString() + "\n\n";
		});
		if (gambaText != "")
		{
			whatYouGambled.alpha = 1;
			whatYouGambled.text = gambaText;
		}
		whatYouGambled.screenCenter();
		whatYouGambled.alpha -= elapsed / 6.5;
		super.update(elapsed);
		FlxG.collide(playerLayer, mapLayer, playerWallCollision);
		FlxG.collide(playerLayer, enemyLayer);
		FlxG.collide(enemyLayer, mapLayer, playerWallCollision);
	}


	public function playerWallCollision(player:PlayerEntity, wall:FlxSprite)
	{
		if (wall is FootstepChangingSprite)
		{
			player.steppingOn = cast(wall, FootstepChangingSprite).footstepSoundName;
		}
	}
}
