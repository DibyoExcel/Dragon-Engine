package dge.shaders;
import flixel.system.FlxAssets.FlxShader;

class PixelSprite {
    public var shader:PixelSpriteShader = new PixelSpriteShader();
    public var pixelSize(default, set):Float = 0;
    public function new() {
        
    }

    private function set_pixelSize(value:Float):Float {
        if (pixelSize != value) {
            value = Math.max(0, Math.min(value, 1));
            pixelSize = value;
            shader.pixelSize.value = [value];
        }
        return value;
    }
}

class PixelSpriteShader extends FlxShader {
    @:glFragmentSource('
        #pragma header

        uniform float pixelSize;

        void main() {
            vec2 uv = openfl_TextureCoordv;
            if (pixelSize > 0.0) {
                vec2 pixelUV = vec2(floor(uv.x / pixelSize) * pixelSize, floor(uv.y / pixelSize) * pixelSize);
                gl_FragColor = flixel_texture2D(bitmap, pixelUV);
            } else {
                gl_FragColor = flixel_texture2D(bitmap, uv);
            }
        }
    ')
    public function new() {
        super();
        pixelSize.value = [0];
    }
}