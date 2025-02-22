package shader;


import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class WavyShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float elapsed;

void main()
{
	vec4 color = flixel_texture2D(bitmap, vec2(openfl_TextureCoordv.x, openfl_TextureCoordv.y*(1+(sin(elapsed-(openfl_TextureCoordv.x*20.0)))*0.01)));
    gl_FragColor = vec4(color.r,color.g,color.b,color.a);		
}'
	)
	
	public function new()
	{
		super();
		this.elapsed.value = [0.0];
	}
	
}
