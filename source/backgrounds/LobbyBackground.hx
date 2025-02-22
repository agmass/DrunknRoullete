package backgrounds;

import entity.PlayerEntity;
import entity.bosses.TutorialBoss;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import objects.SpriteToInteract;
import openfl.filters.ShaderFilter;
import shader.GlowInTheDarkShader;
import shader.SuperGlowInTheDarkShader;

class LobbyBackground extends FlxTypedGroup<FlxSprite>
{
	var window:FlxSprite;
	var glowinthedark:ShaderFilter = new ShaderFilter(new GlowInTheDarkShader());
	var superglowinthedark:ShaderFilter = new ShaderFilter(new SuperGlowInTheDarkShader());

	public static var state = -1;
	var lobbyDoor:LobbyDoor = new LobbyDoor(930 * 1.5, 482 * 1.5);
	public static var elapsedTimeInState = 0.0;
	public static var goalToContinue:Void->Bool = () ->
	{
		return false;
	};

	override public function new()
	{
		super();
		state = -1;
		elapsedTimeInState = 0.0;
		var button = new BigRedButton(0, 0, AssetPaths.bigRedButton__png);
		button.screenCenter();
		button.y += 350;
		cast(FlxG.state, PlayState).interactable.add(button);
		cast(FlxG.state, PlayState).elevator.x -= 800;
		window = new FlxSprite(184 * 1.5, 10 * 1.5);
		window.loadGraphic(AssetPaths.window_lobby__png, true, 145, 63);
		window.animation.add("fixed", [0]);
		window.animation.add("broken", [1]);
		if (!PlayState.storyMode)
		{
			window.loadGraphic(AssetPaths.window_hidden__png, true, 149, 69);
			window.animation.add("fixed", [0]);
			window.animation.add("broken", [0]);
		}
		window.scale.set(1.5, 1.5);
		window.animation.play("fixed");
		window.updateHitbox();
		add(window);
		lobbyDoor.scale.set(1.5, 1.5);
		lobbyDoor.updateHitbox();
		cast(FlxG.state, PlayState).interactable.add(lobbyDoor);
	}

	override function update(elapsed:Float)
	{
		if (Main.run.brokeWindow)
		{
			window.animation.play("broken");
		}
		if (LobbyBackground.state == 2)
		{
			if (goalToContinue())
			{
				LobbyBackground.state = 1;
			}
		}
		else
		{
			elapsedTimeInState += elapsed;
		}
		if (state == -1 || state == -2)
		{
			if (!FlxG.camera.filters.contains(glowinthedark))
			{
				FlxG.camera.filters.push(glowinthedark);
			}

		}
		else
		{

			if (FlxG.camera.filters.contains(glowinthedark))
			{
				FlxG.camera.filters.remove(glowinthedark);
			}
		}

		if (FlxG.state is PlayState)
		{
			var ps:PlayState = cast(FlxG.state);
			ps.enemyLayer.forEachOfType(TutorialBoss, (p) ->
			{
				scrimbloDead = p.died;
			});
		}
		super.update(elapsed);
	}
	public static var scrimbloDead = false;
}

class LobbyDoor extends SpriteToInteract
{
	override public function new(x, y)
	{
		super(x, y);
		loadGraphic(AssetPaths.lobby_door__png, true, 207, 152);
		animation.add("0", [0]);
		animation.add("1", [1]);
		animation.play("0");
	}

	override function update(elapsed:Float)
	{
		if (LobbyBackground.scrimbloDead)
		{
			animation.play("1");
			tooltipSprite.visible = true;
		}
		else
		{
			animation.play("0");
			tooltipSprite.visible = false;
		}
		super.update(elapsed);
	}
	override function interact(p:PlayerEntity)
	{
		super.interact(p);
		if (LobbyBackground.scrimbloDead)
		{
			Main.run.nextBoss = null;
			PlayState.forcedBg = AssetPaths._platformer__png;
			FlxG.switchState(new PlayState());
		}
	}
}
class BigRedButton extends SpriteToInteract
{
	override function update(elapsed:Float)
	{
		if (LobbyBackground.state != -1)
		{
			tooltipSprite.alpha = 0;
		}
		super.update(elapsed);
	}
	override function interact(p:PlayerEntity)
	{
		if (LobbyBackground.state == -1)
		{
			LobbyBackground.state = -2;
		}
		super.interact(p);
	}
	override function draw()
	{
		if (LobbyBackground.state != -1)
		{
			tooltipSprite.visible = false;
		}
		super.draw();
	}
}