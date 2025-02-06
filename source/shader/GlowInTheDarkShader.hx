package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class GlowInTheDarkShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float elapsed;
        uniform float modulo;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (color.r >= 1.0 && color.g >= 1.0 && color.b >= 1.0 || (color.r >= 1.0 && openfl_TextureCoordv.y >= 0.5)) {
        gl_FragColor = vec4(color.r,color.g,color.b,color.a);
	} else {
        gl_FragColor = vec4(color.r*0.3,color.g*0.3,color.b*0.3,color.a);
    }
		
}'
	)
	
	public function new()
	{
		super();
		this.elapsed.value = [0.0];
		this.modulo.value = [0.166666667];
	}
	
}
