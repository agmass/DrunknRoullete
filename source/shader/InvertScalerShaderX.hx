package shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class InvertScalerShaderX extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float start;
        uniform float end;
		uniform float change;

        uniform float zoom;

		float quarticOut(float t) {
  			return pow(t - 1.0, 3.0) * (1.0 - t) + 1.0;
		}

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (openfl_TextureCoordv.x >= start && openfl_TextureCoordv.x <= end) {
    	gl_FragColor = vec4(mix(color.r,1.0-color.r,quarticOut(change)),mix(color.g,1.0-color.g,quarticOut(change)),mix(color.b,1.0-color.b,quarticOut(change)),color.a);
	} else {
    	gl_FragColor = vec4(color.r,color.g,color.b,color.a);
    }
		
}
	
'
	)
	
	public function new()
	{
		super();
		this.start.value = [-1.0];
		this.end.value = [-1.0];
		this.change.value = [1.0];
		this.zoom.value = [1.0];
	}
	
}
