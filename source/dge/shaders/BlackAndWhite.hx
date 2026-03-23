package dge.shaders;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;

class BlackAndWhite {
    public var shader:BlackAndWhiteShader = new BlackAndWhiteShader();
    public var mult(default, set):Float;
    public var threshold(default, set):Float;
    public function new() {
        mult = 1;
        threshold = 0.5;
    }
    function set_mult(value:Float):Float {
        mult = FlxMath.bound(value, 0, 1);
        shader.mult.value = [mult];
        return mult;
    }
    function set_threshold(value:Float):Float {
        threshold = FlxMath.bound(value, 0, 1);
        shader.threshold.value = [threshold];
        return threshold;
    }
}

class BlackAndWhiteShader extends FlxShader
{
    @:glFragmentSource("
        #pragma header

        uniform float mult;
        uniform float threshold;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            float gray = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
            vec3 grayscale = vec3(gray > threshold ? 1.0 : 0.0);
            vec3 result = mix(color.rgb, grayscale, mult);
            gl_FragColor = vec4(result, color.a);
        }
    ")
    public function new() {
        super();
    }
}