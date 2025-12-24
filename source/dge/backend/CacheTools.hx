package dge.backend;
import openfl.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

///CACHE OF COURSE
class CacheTools {
    //cache stuff
    //lmao everthing being cache even txt too.
    public static var jsonParse:Map<String, Dynamic> = new Map();
    public static var cacheSound:Map<String, Sound> = new Map();
    public static var cacheImage:Map<String, FlxGraphic> = new Map();
    public static var cacheAtlas:Map<String, FlxAtlasFrames> = new Map();
    public static var cacheText:Map<String, String> = new Map();

    public static function clearCache():Void {
        jsonParse = new Map();
        cacheSound = new Map();
        cacheImage = new Map();
        cacheAtlas = new Map();
        cacheText = new Map();
    }
}