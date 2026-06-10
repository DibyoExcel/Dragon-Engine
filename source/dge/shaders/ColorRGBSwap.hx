package dge.shaders;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;

class ColorRGBSwap
{
    public var shader:ColorRGBSwapShader = new ColorRGBSwapShader();
    //0 = R, 1 = G, 2 = B
    public var swapR(default, set):Int = -1;
    public var swapG(default, set):Int = -1;
    public var swapB(default, set):Int = -1;
    public var mult(default, set):Float;
    public function new() {
        swapR = 0;
        swapG = 1;
        swapB = 2;
        mult = 1;
    }

    function set_swapR(value:Int):Int {
        if (swapR != value) {
            if (value < 0 || value > 2) {
                value = 0;
            }
            swapR = value;
            shader.swapR.value = [value];
        }
        return value;
    }
    function set_swapG(value:Int):Int {
        if (swapG != value) {
            if (value < 0 || value > 2) {
                value = 1;
            }
            swapG = value;
            shader.swapG.value = [value];
        }
        return value;
    }
    function set_swapB(value:Int):Int {
        if (swapB != value) {
            if (value < 0 || value > 2) {
                value = 2;
            }
            swapB = value;
            shader.swapB.value = [value];
        }
        return value;
    }
    function set_mult(value:Float):Float {
        mult = FlxMath.bound(value, 0, 1);
        shader.mult.value = [mult];
        return mult;
    }
}

class ColorRGBSwapShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform int swapR;
    uniform int swapG;
    uniform int swapB;
    uniform float mult;
    float rgbSwap(int index, vec4 color) {
        float channels[3];
        channels[0] = color.r;
        channels[1] = color.g;
        channels[2] = color.b;
        return channels[index];
    }
    void main() {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        gl_FragColor = vec4(mix(color, rgbSwap(swapR, color), mult), mix(color, rgbSwap(swapG, color), mult), mix(color, rgbSwap(swapB, color), mult), color.a);
    }
    ')
    public function new() {
        super();
    }
}