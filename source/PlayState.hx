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
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.mappings.SwitchProMapping;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import input.ControllerSource;
import objects.FootstepChangingSprite;
import objects.hitbox.Hitbox;
import util.Language;
import util.Projectile;
import util.SubtitlesBox;

class PlayState extends FlxState
{

	var activeGamepads = [];
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


	override public function create()
	{
		super.create();
		Main.audioPanner = new FlxSprite(FlxG.width / 2, FlxG.height / 2);
		Main.audioPanner.makeGraphic(1, 1, FlxColor.TRANSPARENT);
		if (FlxNapeSpace.space == null)
			FlxNapeSpace.init();
		FlxNapeSpace.space.gravity.setxy(0, 1200);
		FlxG.cameras.reset(gameCam);
		HUDCam.bgColor.alpha = 0;
		FlxG.cameras.add(HUDCam, false);
		var bg = new FlxSprite(0, 0, AssetPaths.test_bg__png);
		bg.alpha = 0.2;
		add(bg);
		var ground = new FootstepChangingSprite(FlxG.width / 2, 1300, "concrete");
		ground.makeGraphic(1920, 900, FlxColor.GRAY);
		ground.immovable = true;
		mapLayer.add(ground);
		var wall = new FootstepChangingSprite(0, 400, "concrete");
		wall.makeGraphic(500, 900, FlxColor.GRAY);
		wall.immovable = true;
		mapLayer.add(wall);
		var wall = new FootstepChangingSprite((FlxG.width - 100), 400, "concrete");
		wall.makeGraphic(500, 900, FlxColor.GRAY);
		wall.immovable = true;
		mapLayer.add(wall); 
		var subtitles = new SubtitlesBox();
		add(subtitles);
		subtitles.camera = HUDCam;
		playerLayer.add(new PlayerEntity(900, 20, "Player 1"));
		add(whatYouGambled);
		whatYouGambled.camera = HUDCam;

		playerDebugText.size = 12;
		playerDebugText.visible = false;
		add(enemyLayer);
		add(playerLayer);
		add(mapLayer);
		playerDebugText.camera = HUDCam;
		add(playerDebugText);
	}

	override public function update(elapsed:Float)
	{
		for (gamepad in FlxG.gamepads.getActiveGamepads()) {
			if (!activeGamepads.contains(gamepad)) {
				var player = new PlayerEntity(900, 20, "Player " + (playerLayer.length + 1));
				player.input = new ControllerSource(gamepad);
				playerLayer.add(player);
				activeGamepads.push(gamepad);
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
		FlxG.fixedTimestep = false;
		FlxG.autoPause = false;
		var showPlayerMarker = playerLayer.length > 1;
		gameCam.pixelPerfectRender = true;
		playerDebugText.text = "\n" + "FPS: " + Main.FPS.currentFPS + "\n";
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
		var currentBarHeight = 0.0;
		var currentBarIndex = 0;
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
			currentBarIndex++;
			p.healthBar.x = 20;
			p.healthBar.y = (20 * currentBarIndex) + currentBarHeight;
			currentBarHeight += p.healthBar.height;
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
					][FlxG.random.int(0, 20)] *= type.additionMultiplier;
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
