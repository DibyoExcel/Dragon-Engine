import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;
import RGBPalette;

using StringTools;

class NoteSprite extends FlxSprite
{
    public var RGBPalette:RGBPalette;
    private var arrowCor:Array<String> = [ "purple", "blue", "green", "red" ];
    public function new(x:Float, y:Float, texture:String, noteData:Int) {
        super(x, y);
        frames = Paths.getSparrowAtlas(texture);
        RGBPalette = new RGBPalette();
        shader = RGBPalette.shader;
        for (i in 0...arrowCor.length) {
            animation.addByPrefix(Std.string(i), arrowCor[i] + 0, 24, true);
        }
        animation.play(Std.string(noteData));
        setGraphicSize(112, 112);
        updateHitbox();
    }
}