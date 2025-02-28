package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class InvertScalerShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float start;
        uniform float end;

        uniform float zoom;
void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (openfl_TextureCoordv.y >= start && openfl_TextureCoordv.y <= end) {
    	gl_FragColor = vec4(1.0-color.r,1.0-color.g,1.0-color.b,color.a);
	} else {
    	gl_FragColor = vec4(color.r,color.g,color.b,color.a);
    }
		
}'
	)
	
	public function new()
	{
		super();
		this.start.value = [-1.0];
		this.end.value = [-1.0];
		this.zoom.value = [1.0];
	}
	
}
