package dge.backend;

import flixel.FlxG;

class TouchUtil {
    static var lastTouchY:Null<Float> = null;
    public static function swipeLeft():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > -135 && i.angle < -45 && i.distance > ClientPrefs.swipeRange) {
                return true;
            }
        }
        return false;
    }
    public static function swipeRight():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > 45 && i.angle < 135 && i.distance > ClientPrefs.swipeRange) {
                return true;
            }
        }
        return false;
    }
    public static function swipeUp():Bool {
        for (i in FlxG.swipes) {
            if (ClientPrefs.invertYSwipe) {
                if (((i.angle > 135 && i.angle < 180) || (i.angle > -180 && i.angle < -135)) && i.distance > ClientPrefs.swipeRange) {
                    return true;
                }
            } else {
                if (i.angle > -45 && i.angle < 45 && i.distance > ClientPrefs.swipeRange) {
                    return true;
                }
            }
        }
        return false;
    }
    public static function swipeDown():Bool {
        for (i in FlxG.swipes) {
            if (ClientPrefs.invertYSwipe) {
                if (i.angle > -45 && i.angle < 45 && i.distance > ClientPrefs.swipeRange) {
                    return true;
                }
            } else {
                if (((i.angle > 135 && i.angle < 180) || (i.angle > -180 && i.angle < -135)) && i.distance > ClientPrefs.swipeRange) {
                    return true;
                }
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
    public static function scrollSwipe(swipeMult:Float = 1):Int {
        var touch = FlxG.touches.getFirst();
        if (touch != null && touch.pressed) {
            if (lastTouchY != null) {
                var delta = touch.screenY - lastTouchY;
                if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                    lastTouchY = touch.screenY;
                    return (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                }
            } else {
                lastTouchY = touch.screenY;
            }
        } else {
            lastTouchY = null;
        }
        return 0;
    }
}