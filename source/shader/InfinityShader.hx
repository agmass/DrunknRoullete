package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class Infinity extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float elapsed;
void main()
{
	vec4 color = flixel_texture2D(bitmap, vec2(mod((openfl_TextureCoordv.x+elapsed)*2, 1.0), mod((openfl_TextureCoordv.y+elapsed)*2, 1.0)));
    	gl_FragColor = vec4(color.r,color.g,color.b,color.a);
		
}'
	)
	
	public function new()
	{
		super();
		this.elapsed.value = [0.0];
	}
	
}
