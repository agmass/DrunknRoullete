package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;


// Started out being inspired by mouthwashing but i eventually expanded on it


class MonochromeOut extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float level;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	float monochromed = (color.r+color.g+color.b)/3.0;
	float easedLevel = sin((level * 3.1415926) / 2.0);
	if (openfl_TextureCoordv.x+openfl_TextureCoordv.y <= easedLevel*2.0) {
    	gl_FragColor = vec4(0,0,0,0);
	} else {
		float finalRed = color.r + ((monochromed - color.r) * min(1.0, easedLevel*1.5));
		float finalBlue = color.b + ((monochromed - color.b) * min(1.0, easedLevel*1.5));
		float finalGreen = color.g + ((monochromed - color.g) * min(1.0, easedLevel*1.5));
    	gl_FragColor = vec4(finalRed,finalGreen,finalBlue,color.a);
	}
	
}
'
	)
	
	public function new()
	{
		super();
		this.level.value = [0.0];
	}
	
}
