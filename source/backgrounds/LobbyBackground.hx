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
		if (LobbyBackground.state == 1 && elapsedTimeInState >= 39 && elapsedTimeInState <= 50)
		{
			if (!FlxG.camera.filters.contains(superglowinthedark))
			{
				FlxG.camera.filters.push(superglowinthedark);
			}
		}
		else
		{
			if (FlxG.camera.filters.contains(superglowinthedark))
			{
				FlxG.camera.filters.remove(superglowinthedark);
			}
		}
		if (state == -1)
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

		super.update(elapsed);
	}
}

class Door extends SpriteToInteract
{
	override public function new(x, y)
	{
		super(x, y);
		makeGraphic(80, 100);
	}

	override function update(elapsed:Float)
	{
		var scrimbloAlive = false;

		cast(FlxG.state, PlayState).enemyLayer.forEachOfType(TutorialBoss, (p) ->
		{
			if (!p.died)
				scrimbloAlive = true;
		});
		if (scrimbloAlive)
		{
			color = FlxColor.GRAY;
		}
		else
		{
			color = FlxColor.BLACK;
		}
		super.update(elapsed);
	}

	override function interact(p:PlayerEntity)
	{
		var scrimbloAlive = false;

		cast(FlxG.state, PlayState).enemyLayer.forEachOfType(TutorialBoss, (p) ->
		{
			if (!p.died)
				scrimbloAlive = true;
		});
		if (scrimbloAlive)
		{
			PlayState.forcedBg = AssetPaths._platformer__png;
		}
		super.interact(p);
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
			FlxG.camera.shake(0.05, 0.5);
			LobbyBackground.state = 1;
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