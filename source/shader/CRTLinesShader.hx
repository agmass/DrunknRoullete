package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class CRTLinesShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header


void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (mod(floor(openfl_TextureCoordv.y*60.0), 2.0) == 0.0) {
        gl_FragColor = vec4(color.r,color.g,color.b,color.a);
	} else {
        gl_FragColor = vec4(0,0,0,color.a);
        }
		
}'
	)
	
	public function new()
	{
		super();
	}
	
}
