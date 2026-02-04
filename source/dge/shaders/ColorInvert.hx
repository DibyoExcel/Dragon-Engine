package dge.shaders;
import flixel.system.FlxAssets.FlxShader;

class ColorInvert {
    public var shader:ColorInvertShader = new ColorInvertShader();
    public var invertR(default, set):Bool;
    public var invertG(default, set):Bool;
    public var invertB(default, set):Bool;

    public function new() {
        invertR = true;
        invertG = true;
        invertB = true;
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
}

class ColorInvertShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform bool invertR;
    uniform bool invertG;
    uniform bool invertB;
    
    void main() {
        vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
        //idk why without this(*= color.a). it turn transparent into white
        if (invertR) {    
            color.r = (1.0 - color.r) * color.a;
        }
        if (invertG) {
            color.g = (1.0 - color.g) * color.a;
        }
        if (invertB) {
            color.b = (1.0 - color.b) * color.a;
        }
        gl_FragColor = vec4(color.r, color.g, color.b, color.a);
    }
    ')
    public function new() {
        super();
    }
}