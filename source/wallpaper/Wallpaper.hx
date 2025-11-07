package wallpaper;

import sys.*;

@:cppInclude('windows.h')

class Wallpaper {
    /**
     * Changes wallpaper which is in `path`. Do a warning for players in your mod if you want use this function!!!!
     * @param path Path to image
     * @param absolute If false, `path` => mods/images/`path`.png
     * @return Bool - If false, wallpaper wasnt changed / target isnt Windows
     */
    public static function changeWallpaper(path:String, ?absolute:Bool):Bool {
        return #if windows untyped __cpp__('SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, (void*){0}.c_str(), SPIF_UPDATEINIFILE)', FileSystem.absolutePath(path)) #else false #end;
    }
}