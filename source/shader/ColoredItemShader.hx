package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class ColoredItemShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform vec4 replacementColor;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (color.a > 0.0) {
        gl_FragColor = vec4(replacementColor.r*color.a,replacementColor.g*color.a,replacementColor.b*color.a,color.a);
	}
		
}'
	)
	
	public function new(color:FlxColor = FlxColor.BLUE)
	{
		super();
		this.replacementColor.value = [color.redFloat, color.greenFloat, color.blueFloat, color.alpha];
	}
}
