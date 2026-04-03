package dge.backend;

import flixel.FlxG;
//WARNING: this more likely heavyly touch mechanic /jk

class TouchUtil {
    //static var lastTouchY:Null<Float> = null;//trace('goodbye old code');
    static var touchMapY:Map<Int, Float> = new Map<Int, Float>();
    static var touchMapX:Map<Int, Float> = new Map<Int, Float>();
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
        //bye bye old code lol
        /*var touch = FlxG.touches.getFirst();
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
        }*/
        var number = 0;
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                if (touchMapY.exists(id)) {
                    var delta = touch.screenY - touchMapY.get(id);
                    if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                        touchMapY.set(id, touch.screenY);
                        number += (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapY.set(id, touch.screenY);
                }
            } else if (touchMapY.exists(touch.touchPointID)) {
                touchMapY.remove(touch.touchPointID);
            }
        }
        return number;
    }
    public static function scrollSwipeX(swipeMult:Float = 1):Int {
        var number = 0;
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                if (touchMapX.exists(id)) {
                    var delta = touch.screenX - touchMapX.get(id);
                    if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                        touchMapX.set(id, touch.screenX);
                        number += (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapX.set(id, touch.screenX);
                }
            } else if (touchMapX.exists(touch.touchPointID)) {
                touchMapX.remove(touch.touchPointID);
            }
        }
        return number;
    }
    //smooth version(smooth scroll mosly for scrolling without snap)
    public static function scrollSwipeSmooth(mult:Float = 1.0):Float {
        //hope it doesn't cause any performance issues lol
        var number:Float = 0;
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                if (touchMapY.exists(id)) {
                    var delta = touch.screenY - touchMapY.get(id);
                    if (delta != 0) {//all scrolls count, no minimum distance
                        touchMapY.set(id, touch.screenY);
                        number += delta * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapY.set(id, touch.screenY);
                }
            } else if (touchMapY.exists(touch.touchPointID)) {
                touchMapY.remove(touch.touchPointID);
            }
        }
        return number * mult;
    }
    public static function scrollSwipeSmoothX(mult:Float = 1.0):Float {
        var number:Float = 0;
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                if (touchMapX.exists(id)) {
                    var delta = touch.screenX - touchMapX.get(id);
                    if (delta != 0) {//all scrolls count, no minimum distance
                        touchMapX.set(id, touch.screenX);
                        number += delta * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapX.set(id, touch.screenX);
                }
            } else if (touchMapX.exists(touch.touchPointID)) {
                touchMapX.remove(touch.touchPointID);
            }
        }
        return number * mult;
    }
    //imagine play fnf but with zoom mechanics, that would be... interesting ngl
    public static function pinchZoom():Float {
        //uhhh i dont even know how this work(not mine code)
        if (FlxG.touches.list.length >= 2) {
            var touch1 = FlxG.touches.list[0];
            var touch2 = FlxG.touches.list[1];
            if (touch1 != null && touch2 != null && touch1.pressed && touch2.pressed) {
                var id1 = touch1.touchPointID;
                var id2 = touch2.touchPointID;
                if (touchMapX.exists(id1) && touchMapY.exists(id1) && touchMapX.exists(id2) && touchMapY.exists(id2)) {
                    var prevDistance = Math.sqrt(Math.pow(touchMapX.get(id2) - touchMapX.get(id1), 2) + Math.pow(touchMapY.get(id2) - touchMapY.get(id1), 2));
                    var newDistance = Math.sqrt(Math.pow(touch2.screenX - touch1.screenX, 2) + Math.pow(touch2.screenY - touch1.screenY, 2));
                    var zoomFactor = newDistance / prevDistance;
                    //update the stored positions for the next frame
                    touchMapX.set(id1, touch1.screenX);
                    touchMapY.set(id1, touch1.screenY);
                    touchMapX.set(id2, touch2.screenX);
                    touchMapY.set(id2, touch2.screenY);
                    return zoomFactor;
                } else {
                    //store initial positions if they don't exist
                    if (!touchMapX.exists(id1)) {
                        touchMapX.set(id1, touch1.screenX);
                        touchMapY.set(id1, touch1.screenY);
                    }
                    if (!touchMapX.exists(id2)) {
                        touchMapX.set(id2, touch2.screenX);
                        touchMapY.set(id2, touch2.screenY);
                    }
                }
            }
        }
        return 1; //no zoom
    }
}