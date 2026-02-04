package dge.shaders;

import flixel.system.FlxAssets.FlxShader;

class Posterize {
    public var shader:PosterizeShader = new PosterizeShader();
    public var posterizeRange(default, set):Float = 0;
    public function new() {
        
    }

    private function set_posterizeRange(value:Float):Float {
        if (posterizeRange != value) {
            value = Math.max(0, value);
            posterizeRange = value;
            shader.posterizeRange.value = [value];
        }
        return value;
    }
}

class PosterizeShader extends FlxShader {
    @:glFragmentSource('
        #pragma header

        uniform float posterizeRange;

        void main() {
            vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);
            if (posterizeRange > 0.0) {
                float r = floor(color.r * posterizeRange) / posterizeRange;
                float g = floor(color.g * posterizeRange) / posterizeRange;
                float b = floor(color.b * posterizeRange) / posterizeRange;
                gl_FragColor = vec4(r, g, b, color.a);
            } else {
                //nothing change
                gl_FragColor = vec4(color);
            }
        }
    ')
    public function new() {
        super();
        posterizeRange.value = [4.0];
    }
}