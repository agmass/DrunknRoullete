package shader;

import flixel.system.FlxAssets.FlxShader;
import flixel.util.FlxColor;

class FadingOut extends FlxShader
{


	@:glFragmentSource('
		#pragma header

        uniform float alphaFade;

void main()
{
	vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
	if (alphaFade > 0.0) {
    	gl_FragColor = vec4(color.r*(alphaFade),color.g*(alphaFade),color.b*(alphaFade),alphaFade*color.a);
	}
		
}'
	)
	
	public function new()
	{
		super();
		this.alphaFade.value = [0.0];
	}
	
}
