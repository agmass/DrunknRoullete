package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;


// Started out being inspired by mouthwashing but i eventually expanded on it


class MouthwashingFadeOutEffect extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float level;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (color.r <= level && color.g <= level && color.b <= level) {
    	gl_FragColor = vec4(color.r*level,color.g*level,color.b*level,color.a*level);
	}
		
}
'
	)
	
	public function new()
	{
		super();
		this.level.value = [1.0];
	}
	
}
