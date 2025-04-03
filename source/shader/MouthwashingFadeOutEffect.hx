package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;


// Started out being inspired by mouthwashing but i eventually expanded on it


class MouthwashingFadeOutEffect extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float level;

		float random(vec2 st) {
			st *= 150.0;
			st = floor(st);
			return fract(sin(dot(st.xy,
								 vec2(12.9898,78.233)))*
				43758.5453123);
		}
void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	bool fadeBright = (color.r+color.g+color.b+random(vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y)))/5.0 >= level;
	bool fadeDark = (color.r+color.g+color.b+random(vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y)))/5.0 <= 1.0-level;
	if (fadeDark || fadeBright) {
    	gl_FragColor = vec4(0.0,0.0,0.0,0.0);
	} else {
        gl_FragColor = vec4(color.r,color.g,color.b,color.a);
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
