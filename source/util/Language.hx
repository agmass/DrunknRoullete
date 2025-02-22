package util;

/*

	Re-used code
	File originally from "Taglayer Rewritten", 2024 by agmas (me! :3)

 */
import flixel.FlxG;
import flixel.system.FlxAssets;
import haxe.DynamicAccess;
import haxe.Json;
import input.ControllerSource;
import input.InputSource;
import input.KeyboardSource;
import lime.utils.Assets;

class Language
{
	public static var language:Map<String, String> = new Map();
	public static var languagesAndNames:Map<String, String> = new Map();

	public static function getForInputs(key:String, input:InputSource):String
	{
		if (!language.exists(key))
		{
			return key;
		}
		key = language.get(key);
		if (input is KeyboardSource)
		{
			var kbs:KeyboardSource = cast(input);
			key = StringTools.replace(key, "%(altFire)", kbs.alt_fire.nameWithOr());
			key = StringTools.replace(key, "%(attack)", kbs.shoot.nameWithOr());
			key = StringTools.replace(key, "%(backslot)", kbs.backslot.nameWithOr());
			key = StringTools.replace(key, "%(dash)", kbs.dash.nameWithOr());
			key = StringTools.replace(key, "%(jump)", kbs.W.nameWithOr());
			key = StringTools.replace(key, "%(interact)", kbs.interact.nameWithOr());
		}
		if (input is ControllerSource)
		{
			var cs:ControllerSource = cast(input);
			key = StringTools.replace(key, "%(altFire)", cs.alt_fire.nameWithOr());
			key = StringTools.replace(key, "%(attack)", cs.shoot.nameWithOr());
			key = StringTools.replace(key, "%(backslot)", cs.backslot.nameWithOr());
			key = StringTools.replace(key, "%(dash)", cs.dash.nameWithOr());
			key = StringTools.replace(key, "%(jump)", cs.jump.nameWithOr());
			key = StringTools.replace(key, "%(interact)", cs.interact.nameWithOr());
		}
		key = StringTools.replace(key, "MOUSE-1", "LMB");
		key = StringTools.replace(key, "MOUSE-3", "RMB");
		return key;
	}
	public static function get(key:String):String
	{
		if (!language.exists(key))
		{
			return key;
		}
		return language.get(key);
	}

	public static function refreshLanguages()
	{
		for (i in AssetPaths.allFiles)
		{
			if (StringTools.startsWith(i, "assets/lang/"))
			{
				var lang:DynamicAccess<String> = Json.parse(Assets.getText(i));
				languagesAndNames.set(i.split("/")[2], lang.get("name"));
			}
		}
	}

	public static function changeLanguage(locale:String)
	{
		var lang:DynamicAccess<String> = Json.parse(Assets.getText("assets/lang/" + locale + ".json"));
		var i = 0;
		for (key => value in lang)
		{
			i++;
			language.set(key, value);
		}
		/*var keys = [];
			var wordBank = [];
			var wordCounts = [];
			for (key => value in language)
			{
				keys.push(key);
				for (s in value.split(" "))
				{
					wordBank.push(s);
				}
				wordCounts.push(value.split(" ").length);
			}
			FlxG.random.shuffle(wordBank);
			var i = 0;
			var i2 = 0;
			for (s in keys)
			{
				var finalValue = "";
				for (e in 0...wordCounts[i])
				{
					finalValue += wordBank[i2] + " ";
					i2++;
				}
				finalValue.substr(0, finalValue.length - 1);
				language.set(s, finalValue);
				i++;
		}*/
		trace("Loaded " + i + " language keys.");
	}
}