package;

import entity.PlayerEntity;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import input.ControllerSource;

class PlayState extends FlxState
{

	var activeGamepads = [];
	var playerMarkerColors = [FlxColor.BLUE,FlxColor.RED,FlxColor.YELLOW,FlxColor.GREEN,FlxColor.PURPLE,FlxColor.CYAN,FlxColor.LIME,FlxColor.ORANGE,FlxColor.WHITE,FlxColor.BROWN,FlxColor.PINK];
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
		var ground = new FlxSprite(0,800);
		ground.makeGraphic(1920,200,FlxColor.GRAY);
		ground.immovable = true;
		mapLayer.add(ground);
		var wall = new FlxSprite((FlxG.width)-100,0);
		wall.makeGraphic(200,1080,FlxColor.GRAY);
		wall.immovable = true;
		mapLayer.add(wall);
		var wall2 = new FlxSprite((FlxG.width)-800,300);
		wall2.makeGraphic(200,1080,FlxColor.GRAY);
		wall2.immovable = true;
		mapLayer.add(wall2);
		gameCam.pixelPerfectRender =  true;
		playerLayer.add(new PlayerEntity(20,20));
		playerDebugText.camera = HUDCam;
		add(playerDebugText);
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
			if (p.playerMarkerColor == null) {
				p.playerMarkerColor = playerMarkerColors[0];
				playerMarkerColors.splice(0,1);
			}
			p.showPlayerMarker = showPlayerMarker;
			playerDebugText.text += p.toString() + "\n";
		});
		super.update(elapsed);
		FlxG.collide(playerLayer, mapLayer);
	}
}
