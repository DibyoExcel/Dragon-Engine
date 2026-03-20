package dge.backend;

import flixel.util.FlxSave;
using StringTools;

class ModSetting {
    static var save:FlxSave;
    public static function init(folder:String) {
        folder = folder.replace(' ', "_");
        folder = ~/[^A-Za-z0-9_]/g.replace(folder, "");
        trace('init the ' + folder);
        save = new FlxSave();
        save.bind("setting", folder);//just prevemt from duplicate
    }

    public static function set(setting:String, value:Dynamic) {
        if (save != null) {
            Reflect.setField(save.data, setting, value);
        }
    }
    public static function get(setting:String):Dynamic {
        if (save != null) {
            return Reflect.field(save.data, setting);
        }
        return null;
    }
    public static function saveSettings() {
        save.flush();
        save = null;//just to clean
    }
}