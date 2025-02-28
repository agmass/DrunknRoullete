package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class GrayScaleShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float mixAmount;
void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	float averaged = (color.r+color.g+color.b)/3.0;
    	gl_FragColor = vec4(mix(color.r, averaged, mixAmount),mix(color.g, averaged, mixAmount),mix(color.b, averaged, mixAmount),color.a);
		
}'
	)
	
	public function new()
	{
		super();
		this.mixAmount.value = [0.0];
	}
	
}
