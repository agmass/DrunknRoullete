package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class AttributesSlotTextShader extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float elapsed;
        uniform float modulo;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (color.g >= 1.0) {
    	gl_FragColor = vec4(openfl_TextureCoordv.y+abs(sin(elapsed+mod(openfl_TextureCoordv.x,modulo))),mod(openfl_TextureCoordv.x,modulo)+abs(sin(elapsed+openfl_TextureCoordv.y)),0.0,color.a);
	} else {
        gl_FragColor = vec4(color.r,color.g,color.b,color.a);
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
