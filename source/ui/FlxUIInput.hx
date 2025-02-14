package ui;

import flixel.FlxG;
import flixel.addons.ui.FlxUIInputText;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton;
import flixel.text.FlxText;
import input.ControllerSource;
import input.InputSource;
import input.KeyboardSource;
import input.control.AnalogControllerInput;
import input.control.ButtonControllerInput;
import input.control.Input;
import input.control.KeyOrMouseInput;
import openfl.events.KeyboardEvent;
import util.Language;

class FlxUIInput extends FlxUIInputText
{
	public var source:InputSource;

	var label:FlxText;

	public var target = "";

	override public function new(source, target)
	{
		this.source = source;
		this.target = target;
		label = new FlxText(0, 0, 0, Language.get("key." + target), 16);
		super(0, 0, 0, "");
		fieldWidth = 100;
	}

	override function draw()
	{
		var txt = "";
		var i = Reflect.getProperty(source, target);
		if (i is Input)
		{
			txt += cast(i, Input).name();
		}
		text = txt;
		label.x = x + 100;
		label.y = y;
		label.draw();
		super.draw();
	}

	var hadFocusBefore = false;

	override function update(elapsed:Float)
	{
		if (source is ControllerSource)
		{
			if (hasFocus && hadFocusBefore)
			{
				if (source.ui_menu)
				{
					hasFocus = false;
				}
				else
				{
					if (Reflect.getProperty(source, target) is ButtonControllerInput)
					{
						if (cast(source, ControllerSource).gamepad.anyButton(JUST_PRESSED))
						{
							cast(Reflect.getProperty(source,
								target), ButtonControllerInput).positiveKey.push(cast(source, ControllerSource).gamepad.firstJustPressedID());
						}
					}
					if (Reflect.getProperty(source, target) is AnalogControllerInput)
					{
						if (cast(source, ControllerSource).gamepad.analog.justMoved.LEFT_STICK)
						{
							cast(Reflect.getProperty(source, target), AnalogControllerInput).stick.push(FlxGamepadInputID.LEFT_ANALOG_STICK);
						}
						if (cast(source, ControllerSource).gamepad.analog.justMoved.RIGHT_STICK)
						{
							cast(Reflect.getProperty(source, target), AnalogControllerInput).stick.push(FlxGamepadInputID.RIGHT_ANALOG_STICK);
						}
					}
				}
			}
		}
		if (source is KeyboardSource)
		{
			#if FLX_MOUSE
			// Set focus and caretIndex as a response to mouse press
			if (FlxG.mouse.justPressed)
			{
				var hadFocus:Bool = hasFocus;
				if (FlxG.mouse.overlaps(this, camera))
				{
					caretIndex = getCaretIndex();
					hasFocus = true;
					if (!hadFocus && focusGained != null)
						focusGained();
					if (hadFocus)
					{
						cast(Reflect.getProperty(source, target), KeyOrMouseInput).mouse.push(FlxMouseButton.getByID(FlxMouseButtonID.LEFT));
					}
				}
				else
				{
					hasFocus = false;
					if (hadFocus && focusLost != null)
						focusLost();
				}
			}
			#end
			if (FlxG.mouse.justPressedRight)
			{
				if (FlxG.mouse.overlaps(this, camera))
				{
					if (hasFocus)
					{
						cast(Reflect.getProperty(source, target), KeyOrMouseInput).mouse.push(FlxMouseButton.getByID(FlxMouseButtonID.RIGHT));
					}
					else
					{
						cast(Reflect.getProperty(source, target), KeyOrMouseInput).key.resize(0);
						cast(Reflect.getProperty(source, target), KeyOrMouseInput).mouse.resize(0);
					}
				}
			}
		}
		hadFocusBefore = hasFocus;
	}

	override function onKeyDown(e:KeyboardEvent)
	{
		if (hasFocus)
		{
			if (source is KeyboardSource)
			{
				final key:FlxKey = e.keyCode;
				if (key == FlxKey.ESCAPE)
					return;
				cast(Reflect.getProperty(source, target), KeyOrMouseInput).key.push(key);
				hasFocus = false;
			}
		}
	}
}