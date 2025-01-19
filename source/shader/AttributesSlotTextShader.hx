package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class AttributesSlotTextShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float elapsed;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (color.r >= 0.04 && color.g >= 1.0 && color.b == 0.0) {
    	gl_FragColor = vec4(openfl_TextureCoordv.y+abs(sin(elapsed+mod(openfl_TextureCoordv.x,0.166666667))),mod(openfl_TextureCoordv.x,0.166666667)+abs(sin(elapsed+openfl_TextureCoordv.y)),0.0,color.a);
	} else {
        gl_FragColor = vec4(color.r,color.g,color.b,color.a);
    }
		
}'
	)
	
	public function new()
	{
		super();
		this.elapsed.value = [0.0];
	}
	
}
