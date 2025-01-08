import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flash.display.BitmapData;

using StringTools;

class NoteSprite extends FlxSprite
{
    public var colorSwap:ColorSwap;
    private var arrowCor:Array<String> = [ "purple", "blue", "green", "red" ];
    public function new(x, y, texture, noteData) {
        super(x, y);
        frames = Paths.getSparrowAtlas(texture);
        colorSwap = new ColorSwap();
        shader = colorSwap.shader;
        animation.addByPrefix("color", arrowCor[noteData] + 0, 24, true);
        animation.play("color");
        setGraphicSize(Std.int(width*0.7), Std.int(height*0.7));
    }
}