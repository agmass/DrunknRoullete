package entity.bosses;

import backgrounds.LobbyBackground;
import flixel.FlxG;
import flixel.addons.text.FlxTypeText;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class TutorialBoss extends Entity
{
	var dialouge:FlxTypeText = new FlxTypeText(0, 0, 0, "", 48);
	var face:FlxText = new FlxText(0, 0, 0, "z_z", 100);

	var lastState = 0;

	override public function new(x, y)
	{
		super(x, y);
		makeGraphic(750, 500, FlxColor.BLACK);
	}
	var breathing:Float = 0.0;
	var timeDialougeMap:Map<Int, String> = new Map();

	override function update(elapsed:Float)
	{
		if (lastState == -1 && LobbyBackground.state == 1)
		{
			LobbyBackground.elapsedTimeInState = 0;
			dialouge.size = 96;
			dialouge.resetText("HUH?");
			dialouge.start(0.015);
			timeDialougeMap.set(1500, "ahem.");
			timeDialougeMap.set(2000, "Well, hello, uh, whoever you are.");
			timeDialougeMap.set(6500, "This casino is closed now. Please go away.");
			timeDialougeMap.set(9500, "Come back tommorow.");
			timeDialougeMap.set(11500, "Or something.");
			timeDialougeMap.set(17000, "I notice you haven't left yet.");
			timeDialougeMap.set(20000, "...");
			timeDialougeMap.set(25000, "Look, i'm bored as hell.");
			timeDialougeMap.set(27500, "I've been stuck in this shitty casino,");
			timeDialougeMap.set(29000, "I haven't seen anybody new come in for the past 4 years,");
			timeDialougeMap.set(34000, "Something happened inside those floors.");
			timeDialougeMap.set(36000, "I'm not entirely sure why, but I've seen some people come in");
			timeDialougeMap.set(38000, "And never come back out.");
		}
		if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 1.5)
		{
			dialouge.size = 48;
			dialouge.delay = 0.05;
		}
		for (i => s in timeDialougeMap)
		{
			if (Math.round(LobbyBackground.elapsedTimeInState * 1000) >= i)
			{
				dialouge.resetText(timeDialougeMap.get(i));
				dialouge.start(0.05);
				timeDialougeMap.remove(i);
			}
		}
		lastState = LobbyBackground.state;
		y = 200;
		face.x = x + ((width - face.width) / 2);
		face.y = y + 100 + (((height - face.height) / 2));
		breathing += elapsed / 4;
		face.y += (Math.sin(breathing) * 15);
		dialouge.update(elapsed);
		screenCenter(X);
		super.update(elapsed);
		facialExpressions();
	}

	override function draw()
	{
		super.draw();
		dialouge.screenCenter();
		dialouge.draw();
		if (face.visible)
			face.draw();
	}

	function facialExpressions()
	{
		// Look.. performance doesn't matter in this scene... just.. sorry...
		if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 38)
		{
			face.text = "-.-";
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 36)
		{
			face.text = "o_o";
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 34)
		{
			face.text = "O_O";
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 29)
		{
			face.text = "#_#";
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 27.5)
		{
			face.text = ">:(";
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 25)
		{
			face.text = ";-;";
			face.visible = true;
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 20)
		{
			face.text = ". . .";
			face.visible = Math.floor(Math.round(LobbyBackground.elapsedTimeInState * 1000) / 500) % 2 == 0;
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 17)
		{
			face.text = "> >";
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 11.5)
		{
			face.text = "._.";
			face.visible = true;
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 6.5)
		{
			face.text = ":(";
			face.visible = Math.floor(Math.round(LobbyBackground.elapsedTimeInState * 1000) / 500) % 2 == 0;
		}
		else if (LobbyBackground.state == 1 && LobbyBackground.elapsedTimeInState >= 2)
		{
			face.text = "@_@";
		}
		else if (LobbyBackground.state == 1)
		{
			face.text = "O_O";
		}
		else if (LobbyBackground.state == -1)
		{
			face.text = "z_z";
		}
	}
}