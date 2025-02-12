package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class SlopeShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float elapsed;
        uniform float modulo;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (abs(1.0-openfl_TextureCoordv.x) <= openfl_TextureCoordv.y) {
        gl_FragColor = vec4(color.r,color.g,color.b,color.a);
	} else {
        gl_FragColor = vec4(0,0,0,0);
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
