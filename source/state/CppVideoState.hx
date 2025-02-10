#if cpp
package state;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import hxvlc.flixel.FlxVideoSprite;

class CppVideoState extends TransitionableState
{
	var video = new FlxVideoSprite(0, 0);
	var target = "";
	var onComplete:Void->Void = () -> {};
	var holdToSkip:FlxText = new FlxText(46, FlxG.height - (46 + 24), 0, "Hold [Undefined] To Skip", 24);

	override public function new(video:String, onComplete:Void->Void)
	{
		target = video;
		this.onComplete = onComplete;
		super();
	}

	override function create()
	{
		video.active = false;
		video.antialiasing = true;
		video.load(target);
		holdToSkip.alpha = 0;
		add(video);
		video.play();
		super.create();
		holdToSkip.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2);
		add(holdToSkip);
	}

	var startedPlaying = false;

	override function update(elapsed:Float)
	{
		Main.detectConnections();
		var holding = false;
		for (i in Main.activeInputs)
		{
			if (i.ui_hold_accept)
			{
				holding = true;
				holdToSkip.text = "Hold " + i.uiAcceptName() + " to skip";
			}
		}
		if (holding)
		{
			holdToSkip.alpha += elapsed;
			if (holdToSkip.alpha >= 1)
			{
				TransitionableState.bitmapData = video.bitmap.bitmapData;
				video.bitmap.stop();
			}
		}
		else
		{
			holdToSkip.alpha -= elapsed;
		}
		if (video.bitmap.isPlaying)
		{
			startedPlaying = true;
		}
		if (video.bitmap.isPlaying && video.bitmap.duration > video.bitmap.length - 1000)
		{
			TransitionableState.bitmapData = video.bitmap.bitmapData;
		}
		super.update(elapsed);
		if (video.bitmap.isPlaying)
		{
			startedPlaying = true;
		}
		if (!video.bitmap.isPlaying && startedPlaying)
		{
			onComplete();
		}
	}

	override function startOutro(onOutroComplete:() -> Void)
	{
		onOutroComplete();
	}
}
#end