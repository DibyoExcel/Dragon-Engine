package dge.shaders;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;

class GrayScale {
    public var shader:GrayScaleShader = new GrayScaleShader();
    public var mult(default, set):Float;
    public function new() {
        mult = 1;
    }
    function set_mult(value:Float):Float {
        mult = FlxMath.bound(value, 0, 1);
        shader.mult.value = [mult];
        return mult;
    }
}

class GrayScaleShader extends FlxShader
{
    @:glFragmentSource("
        #pragma header

        uniform float mult;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            float gray = dot(color.rgb, vec3(0.3, 0.59, 0.11));
            vec3 grayscale = vec3(gray);
            vec3 result = mix(color.rgb, grayscale, mult);
            gl_FragColor = vec4(result, color.a);
        }
    ")
    public function new() {
        super();
    }
}