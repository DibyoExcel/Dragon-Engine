package mobile;

import flixel.FlxG;

class TouchUtil {
    public static function swipeLeft():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > -135 && i.angle < -45 && i.distance > 15) {
                return true;
            }
        }
        return false;
    }
    public static function swipeRight():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > 45 && i.angle < 135 && i.distance > 15) {
                return true;
            }
        }
        return false;
    }
    public static function swipeUp():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > -45 && i.angle < 45 && i.distance > 15) {
                return true;
            }
        }
        return false;
    }
    public static function swipeDown():Bool {
        for (i in FlxG.swipes) {
            if (((i.angle > 135 && i.angle < 180) || (i.angle > -180 && i.angle < -135)) && i.distance > 15) {
                return true;
            }
        }
        return false;
    }
    public static function tap():Bool {
        for (i in FlxG.swipes) {
            if (i.distance < 5) {
                return true;
            }
        }
        return false;
    }
}