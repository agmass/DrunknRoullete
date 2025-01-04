package;

import abilities.attributes.Attribute;
import abilities.attributes.AttributeContainer;
import abilities.attributes.AttributeOperation;
import entity.PlayerEntity;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.mappings.SwitchProMapping;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import input.ControllerSource;
import lime.ui.Haptic;
import objects.FootstepChangingSprite;

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

	var mapLayer:FlxSpriteGroup = new FlxSpriteGroup();
	var playerLayer:FlxSpriteGroup = new FlxSpriteGroup();

	var gameCam:FlxCamera = new FlxCamera();
	var HUDCam:FlxCamera = new FlxCamera();

	override public function create()
	{
		super.create();
		FlxG.cameras.add(gameCam, true);
		HUDCam.bgColor.alpha = 0;
		FlxG.cameras.add(HUDCam, false);
		var ground = new FootstepChangingSprite(0, 800, "concrete");
		ground.makeGraphic(Math.round(1920 / 2), 800, FlxColor.GRAY);
		ground.immovable = true;
		mapLayer.add(ground);
		var ground = new FootstepChangingSprite(Math.round(1920 / 2), 800, "carpet");
		ground.makeGraphic(Math.round(1920 / 2), 800, FlxColor.RED);
		ground.immovable = true;
		mapLayer.add(ground);
		playerLayer.add(new PlayerEntity(20,20));
		playerDebugText.camera = HUDCam;
		add(playerDebugText);
		playerDebugText.size = 12;
		add(playerLayer);
		add(mapLayer);
	}

	override public function update(elapsed:Float)
	{
		for (gamepad in FlxG.gamepads.getActiveGamepads()) {
			if (!activeGamepads.contains(gamepad)) {
				var player = new PlayerEntity(20,20);
				player.input = new ControllerSource(gamepad);
				playerLayer.add(player);
				activeGamepads.push(gamepad);
			}
		}
		var showPlayerMarker = playerLayer.length > 1;
		playerDebugText.text = "";
		playerLayer.forEachOfType(PlayerEntity, (p)->{
			if (FlxG.keys.justPressed.O)
			{
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
				}
				else
				{
					amount = FlxG.random.int(20, 500);
					if (!lostOrWon)
						amount = -FlxG.random.int(20, 500);
				}
				if (operation.equals(ADD))
				{
					amount *= type.additionMultiplier;
				}
				trace(type.id);
				trace(lostOrWon ? "won" : "lost");
				trace("amount that was " + operation.getName() + "ed: " + amount);
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
			}
			if (p.playerMarkerColor == FlxColor.TRANSPARENT)
			{
				p.playerMarkerColor = playerMarkerColors[0];
				playerMarkerColors.splice(0,1);
			}
			p.showPlayerMarker = showPlayerMarker;
			playerDebugText.text += p.toString() + "\n";
		});
		super.update(elapsed);
		FlxG.collide(playerLayer, mapLayer, playerWallCollision);
	}

	public function playerWallCollision(player:PlayerEntity, wall:FlxSprite)
	{
		if (wall is FootstepChangingSprite)
		{
			player.steppingOn = cast(wall, FootstepChangingSprite).footstepSoundName;
		}
	}
}
