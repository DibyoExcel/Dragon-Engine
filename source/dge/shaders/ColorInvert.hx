package dge.shaders;
import flixel.system.FlxAssets.FlxShader;
import flixel.math.FlxMath;

class ColorInvert {
    public var shader:ColorInvertShader = new ColorInvertShader();
    public var invertR(default, set):Bool;
    public var invertG(default, set):Bool;
    public var invertB(default, set):Bool;
    public var mult(default, set):Float;

    public function new() {
        invertR = true;
        invertG = true;
        invertB = true;
        mult = 1;
    }

    function set_invertR(value:Bool):Bool {
        if (invertR != value) {
            invertR = value;
            shader.invertR.value = [value];
        } 
        return value;
    }
    function set_invertG(value:Bool):Bool {
        if (invertG != value) {
            invertG = value;
            shader.invertG.value = [value];
        } 
        return value;
    }
    function set_invertB(value:Bool):Bool {
        if (invertB != value) {
            invertB = value;
            shader.invertB.value = [value];
        } 
        return value;
    }
    function set_mult(value:Float):Float {
        mult = FlxMath.bound(value, 0, 1);
        shader.mult.value = [mult];
        return mult;
    }
}

class ColorInvertShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform bool invertR;
    uniform bool invertG;
    uniform bool invertB;
    uniform float mult;
    
    void main() {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        //idk why without this(*= color.a). it turn transparent into white
        vec4 realColor = color;
        vec4 invertColor = color;
        if (invertR) {    
            invertColor.r = (1.0 - color.r) * color.a;
        }
        if (invertG) {
            invertColor.g = (1.0 - color.g) * color.a;
        }
        if (invertB) {
            invertColor.b = (1.0 - color.b) * color.a;
        }
        vec4 result = mix(realColor, invertColor, mult);
        gl_FragColor = result;
    }
    ')
    public function new() {
        super();
    }
}