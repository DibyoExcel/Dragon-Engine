package dge.shaders;

import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;

class ColorSingle
{
    public var shader:ColorSingleShader = new ColorSingleShader();
    public var r(default, set):Float;
    public var g(default, set):Float;
    public var b(default, set):Float;
    public var mult(default, set):Float;

    public function new() {
        r = 1.0;
        g = 1.0;
        b = 1.0;
        mult = 1;
    }
    function set_r(value:Float):Float {
        if (r != value) {
            r = value;
            shader.r.value = [value];
        }
        return value;
    }
    function set_g(value:Float):Float {
        if (g != value) {
            g = value;
            shader.g.value = [value];
        }
        return value;
    }
    function set_b(value:Float):Float {
        if (b != value) {
            b = value;
            shader.b.value = [value];
        }
        return value;
    }
    function set_mult(value:Float):Float {
        mult = FlxMath.bound(value, 0, 1);
        shader.mult.value = [mult];
        return mult;
    }
}

class ColorSingleShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform float r;
    uniform float g;
    uniform float b;
    uniform float mult;
    
    //cuz without this everyhing turn square
    void main() {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        
        gl_FragColor = vec4(mix(color.r, r*color.a, mult), mix(color.g, g*color.a, mult), mix(color.b, b*color.a, mult), color.a);
    }
    ')
    public function new() {
        super();
    }
}