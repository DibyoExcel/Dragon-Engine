import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

///CACHE OF COURSE
class CacheTools {
    //PLEASE REMOVE AFTER USING(UNLESS IS IMPORTANT TO STAY)
    public static var jsonParse:Map<String, Dynamic> = new Map();
    //cache note splash(remove after quick from PlayState, EditorPlayState)
    public static var cacheNoteSplash:Map<String, FlxAtlasFrames> = new Map();
    public static var cacheNoteAtlas:Map<String, FlxAtlasFrames> = new Map();
    public static var cacheNote:Map<String, FlxGraphic> = new Map();
}