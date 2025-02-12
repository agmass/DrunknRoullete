package backgrounds;

import entity.PlayerEntity;
import entity.bosses.TutorialBoss;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import objects.ImmovableFootstepChangingSprite;
import objects.SlopeBox;
import objects.SpriteToInteract;
import openfl.filters.ShaderFilter;
import shader.GlowInTheDarkShader;
import shader.SlopeShader;
import shader.SuperGlowInTheDarkShader;

class PlatformerBackground extends FlxTypedGroup<FlxSprite>
{

	override public function new()
	{
		super();
		var e = 0;
		for (i in [
			{x: 124, y: 248, width: 300, height:387},
			{x: 816, y: 577, width: 244, height:58},
			{x: 842, y: 519, width: 183, height:58},
			{x: 901, y: 461, width: 61, height:58},
			{x: 1125, y: 449, width: 117, height:187},
			{x: 1501, y: 334+34, width: 340, height:16},
			{x: 1882, y: 521+11, width: 8, height: 70},
			{x: 2067, y: 521+11, width: 8, height: 70},
			{x: 1884, y: 583+11, width: 188, height: 8}
		]) {
			var wall = new ImmovableFootstepChangingSprite((i.x+(i.width/2))*1.5,(i.y+(i.height/2))*1.5, "concrete");
			wall.makeGraphic(Math.round(i.width*1.5), Math.round(i.height*1.5), [FlxColor.BLUE.getLightened(0.4),FlxColor.PINK.getDarkened(0.4),FlxColor.WHITE,FlxColor.PINK.getDarkened(0.4)][e % 4]);
			wall.color.alpha = 1;
			wall.immovable = true;
			cast(FlxG.state, PlayState).mapLayerFront.add(wall);
			e++;
		}
		var slope = new SlopeBox((1324)*1.5,(368)*1.5);
		slope.makeGraphic(Math.round(177*1.5), Math.round(60*1.5), FlxColor.RED);
		slope.immovable = true;
		slope.shader = new SlopeShader();
		slope.alpha = 0.4;
		cast(FlxG.state, PlayState).mapLayerFront.add(slope);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
