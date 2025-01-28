package ui;

import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class MenuTextButton extends FlxText
{
	public var selected = false;

	public var onUsed:Void->Void;

	public var lerper = 0.0;

	override public function new(x, y, fw, t, s, ?onClick:Void->Void)
	{
		super(x, y, fw, t, s);
		setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 3);
		if (onClick != null)
			onUsed = onClick;
	}

	override function update(elapsed:Float)
	{
		if (selected)
		{
			lerper += elapsed * 6;
			color = FlxColor.YELLOW;
			alpha = 1;
		}
		else
		{
			lerper -= elapsed * 6;
			color = FlxColor.WHITE;
			alpha = 0.75;
		}
		lerper = FlxMath.bound(lerper, 0, 1);

		scale.set(FlxMath.lerp(0.75, 1, easeOutQuint(lerper)), FlxMath.lerp(0.75, 1, easeOutQuint(lerper)));
		super.update(elapsed);
	}

	function easeOutQuint(x:Float):Float
	{
		return 1 - Math.pow(1 - x, 5);
	}
}