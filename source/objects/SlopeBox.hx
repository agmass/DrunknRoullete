package objects;

import abilities.attributes.Attribute;
import entity.Entity;
import entity.PlayerEntity;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.filters.ShaderFilter;
import shader.SlopeShader;

class SlopeBox extends FlxSprite
{
	var slopeGoesLeft = false;

	/*
		slopes are pretty weird dont use this too often
	 */
	override function update(elapsed:Float)
	{
		allowCollisions = ANY;
		var ps:PlayState = cast(FlxG.state);
		ps.enemyLayer.forEachOfType(Entity, riser);
		ps.playerLayer.forEachOfType(Entity, riser);
		allowCollisions = NONE;
		super.update(elapsed);
	}

	function riser(e:Entity)
	{
		if (FlxG.overlap(e, this))
		{
			if (e is PlayerEntity)
			{
				var p:PlayerEntity = cast(e);
				if (slopeGoesLeft)
				{
					if (p.crouching)
						p.extraVelocity.x += 700 * FlxG.elapsed;
				}
				else
				{
					if (p.crouching)
						p.extraVelocity.x += -700 * FlxG.elapsed;
				}
			}
			var bottomY = ((e.x - x) / (width - e.width)) * (height);
			if (!slopeGoesLeft)
			{
				bottomY = (getGraphicMidpoint().y - (e.height / 2)) - bottomY;
			}
			else
			{
				bottomY = y + bottomY;
			}

			bottomY = Math.max(bottomY, (y - e.height));
			if (e.y > bottomY)
			{
				e.y = bottomY;
				e.touching = e.touching.with(FLOOR);
			}
		}
	}
}