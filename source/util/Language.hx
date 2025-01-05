package util;

/*

	Re-used code
	File originally from "Taglayer Rewritten", 2024 by agmas (me! :3)

 */
import flixel.system.FlxAssets;
import haxe.DynamicAccess;
import haxe.Json;
import lime.utils.Assets;

class Language
{
	public static var language:Map<String, String> = new Map();
	public static var languagesAndNames:Map<String, String> = new Map();

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
		trace("Loaded " + i + " language keys.");
	}
}