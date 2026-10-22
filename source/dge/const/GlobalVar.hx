package dge.const;
import StageData;

class GlobalVar {
    public static var defaultStage:StageFile = {
        directory: "",
        defaultZoom: 0.9,
        isPixelStage: false,

        boyfriend: [770, 100],
        girlfriend: [400, 130],
        opponent: [100, 100],
        hide_girlfriend: false,

        camera_boyfriend: [0, 0],
        camera_opponent: [0, 0],
        camera_girlfriend: [0, 0],
        camera_speed: 1
    }
    public static var menuBackground:String = 'menuDesat';//setPropertyFromClass('dge.const.GlobalVar', 'menuBackground', 'your/bg/path')
    public static var menuBackground2:String = 'menuDesat';
    public static var recolorableMenu:Bool = true;//for freeplay menu
}