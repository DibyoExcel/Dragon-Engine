package dge.shaders;

import flixel.system.FlxAssets.FlxShader;

class ColorSingle
{
    public var shader:ColorSingleShader = new ColorSingleShader();
    public var r(default, set):Float;
    public var g(default, set):Float;
    public var b(default, set):Float;

    public function new() {
        r = 1.0;
        g = 1.0;
        b = 1.0;
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
}

class ColorSingleShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform float r;
    uniform float g;
    uniform float b;
    
    //cuz without this everyhing turn square
    void main() {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        
        gl_FragColor = vec4(r*color.a, g*color.a, b*color.a, color.a);
    }
    ')
    public function new() {
        super();
    }
}