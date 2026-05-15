
package dge.backend.instance;

import flixel.FlxG;

class TouchUtil {
    //var touchMapY:Map<Int, Float> = new Map<Int, Float>();
    //var touchMapX:Map<Int, Float> = new Map<Int, Float>();
    //advanced
    var touchMapXTag:Map<String, Map<Int, Float>> = new Map<String, Map<Int, Float>>();
    var touchMapYTag:Map<String, Map<Int, Float>> = new Map<String, Map<Int, Float>>();

    public function new() {}

    public function swipeLeft():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > -135 && i.angle < -45 && i.distance > ClientPrefs.swipeRange) {
                return true;
            }
        }
        return false;
    }

    public function swipeRight():Bool {
        for (i in FlxG.swipes) {
            if (i.angle > 45 && i.angle < 135 && i.distance > ClientPrefs.swipeRange) {
                return true;
            }
        }
        return false;
    }

    public function swipeUp():Bool {
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

    public function swipeDown():Bool {
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

    public function tap():Bool {
        for (i in FlxG.swipes) {
            if (i.distance < 5) {
                return true;
            }
        }
        return false;
    }

    public function scrollSwipe(swipeMult:Float = 1, ?tag = 'default'):Int {
        if (tag == null || tag.length < 1) {
            tag = "default";
        }
        var number = 0;
        var touchMap:Map<Int, Float> = [];
        if(!touchMapYTag.exists(tag)) {
            touchMapYTag.set(tag, new Map<Int, Float>());
        } else {
            touchMap = touchMapYTag.get(tag);
        }
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                /*if (touchMapY.exists(id)) {
                    var delta = touch.screenY - touchMapY.get(id);
                    if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                        touchMapY.set(id, touch.screenY);
                        number += (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapY.set(id, touch.screenY);
                }*/
                if (touchMap.exists(id)) {
                    var delta = touch.screenY - touchMap.get(id);
                    if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                        touchMap.set(id, touch.screenY);
                        number += (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMap.set(id, touch.screenY);
                }
            } else if (touchMap.exists(touch.touchPointID)) {
                touchMap.remove(touch.touchPointID);
            }
        }
        return number;
    }

    public function scrollSwipeX(swipeMult:Float = 1, ?tag:String = 'default'):Int {
        if (tag == null || tag.length < 1) {
            tag = "default";
        }
        var number = 0;
        var touchMap:Map<Int, Float> = [];
        if(!touchMapXTag.exists(tag)) {
            touchMapXTag.set(tag, new Map<Int, Float>());
        } else {
            touchMap = touchMapXTag.get(tag);
        }
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                /*if (touchMapX.exists(id)) {
                    var delta = touch.screenX - touchMapX.get(id);
                    if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                        touchMapX.set(id, touch.screenX);
                        number += (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapX.set(id, touch.screenX);
                }*/
                if (touchMap.exists(id)) {
                    var delta = touch.screenX - touchMap.get(id);
                    if (delta != 0 && Math.abs(delta) > (ClientPrefs.swipeRange * swipeMult)) {
                        touchMap.set(id, touch.screenX);
                        number += (delta > 0 ? 1 : -1) * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMap.set(id, touch.screenX);
                }
            } else if (touchMap.exists(touch.touchPointID)) {
                touchMap.remove(touch.touchPointID);
            }
        }
        return number;
    }

    public function scrollSwipeSmooth(mult:Float = 1.0, ?tag:String = 'default'):Float {
        if (tag == null || tag.length < 1) {
            tag = "default";
        }
        var number:Float = 0;
        var touchMap:Map<Int, Float> = [];
        if(!touchMapYTag.exists(tag)) {
            touchMapYTag.set(tag, new Map<Int, Float>());
        } else {
            touchMap = touchMapYTag.get(tag);
        }
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                /*if (touchMapY.exists(id)) {
                    var delta = touch.screenY - touchMapY.get(id);
                    if (delta != 0) {
                        touchMapY.set(id, touch.screenY);
                        number += delta * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapY.set(id, touch.screenY);
                }*/
                if (touchMap.exists(id)) {
                    var delta = touch.screenY - touchMap.get(id);
                    if (delta != 0) {
                        touchMap.set(id, touch.screenY);
                        number += delta * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMap.set(id, touch.screenY);
                }
            } else if (touchMap.exists(touch.touchPointID)) {
                touchMap.remove(touch.touchPointID);
            }
        }
        return number * mult;
    }

    public function scrollSwipeSmoothX(mult:Float = 1.0, ?tag:String = 'default'):Float {
        if (tag == null || tag.length < 1) {
            tag = "default";
        }
        var number:Float = 0;
        var touchMap:Map<Int, Float> = [];
        if(!touchMapXTag.exists(tag)) {
            touchMapXTag.set(tag, new Map<Int, Float>());
        } else {
            touchMap = touchMapXTag.get(tag);
        }
        for (touch in FlxG.touches.list) {
            if (touch != null && touch.pressed) {
                var id = touch.touchPointID;
                /*if (touchMapX.exists(id)) {
                    var delta = touch.screenX - touchMapX.get(id);
                    if (delta != 0) {
                        touchMapX.set(id, touch.screenX);
                        number += delta * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMapX.set(id, touch.screenX);
                }*/
                if (touchMap.exists(id)) {
                    var delta = touch.screenX - touchMap.get(id);
                    if (delta != 0) {
                        touchMap.set(id, touch.screenX);
                        number += delta * (ClientPrefs.invertScroll ? -1 : 1);
                    }
                } else {
                    touchMap.set(id, touch.screenX);
                }
            } else if (touchMap.exists(touch.touchPointID)) {
                touchMap.remove(touch.touchPointID);
            }
        }
        return number * mult;
    }

    public function pinchZoom(mult:Float = 1, ?tag="default"):Float {
        if (tag == null || tag.length < 1) {
            tag = "default";
        }
        var touchMap:Map<Int, Float> = [];
        var touchMapY:Map<Int, Float> = [];
        if (!touchMapXTag.exists(tag)) {
            touchMapXTag.set(tag, new Map<Int, Float>());
        } else {
            touchMap = touchMapXTag.get(tag);
        }
        if (!touchMapYTag.exists(tag)) {
            touchMapYTag.set(tag, new Map<Int, Float>());
        } else {
            touchMapY = touchMapYTag.get(tag);
        }
        if (FlxG.touches.list.length >= 2) {
            var touch1 = FlxG.touches.list[0];
            var touch2 = FlxG.touches.list[1];
            if (touch1 != null && touch2 != null && touch1.pressed && touch2.pressed) {
                var id1 = touch1.touchPointID;
                var id2 = touch2.touchPointID;
                /*if (touchMapX.exists(id1) && touchMapY.exists(id1) && touchMapX.exists(id2) && touchMapY.exists(id2)) {
                    var prevDistance = Math.sqrt(Math.pow(touchMapX.get(id2) - touchMapX.get(id1), 2) + Math.pow(touchMapY.get(id2) - touchMapY.get(id1), 2));
                    var newDistance = Math.sqrt(Math.pow(touch2.screenX - touch1.screenX, 2) + Math.pow(touch2.screenY - touch1.screenY, 2));
                    var zoomFactor = newDistance / prevDistance;
                    touchMapX.set(id1, touch1.screenX);
                    touchMapY.set(id1, touch1.screenY);
                    touchMapX.set(id2, touch2.screenX);
                    touchMapY.set(id2, touch2.screenY);
                    return zoomFactor;
                } else {
                    if (!touchMapX.exists(id1)) {
                        touchMapX.set(id1, touch1.screenX);
                        touchMapY.set(id1, touch1.screenY);
                    }
                    if (!touchMapX.exists(id2)) {
                        touchMapX.set(id2, touch2.screenX);
                        touchMapY.set(id2, touch2.screenY);
                    }
                }*/
                if (touchMap.exists(id1) && touchMapY.exists(id1) && touchMap.exists(id2) && touchMapY.exists(id2)) {
                    var prevDistance = Math.sqrt(Math.pow(touchMap.get(id2) - touchMap.get(id1), 2) + Math.pow(touchMapY.get(id2) - touchMapY.get(id1), 2));
                    var newDistance = Math.sqrt(Math.pow(touch2.screenX - touch1.screenX, 2) + Math.pow(touch2.screenY - touch1.screenY, 2));
                    var zoomFactor = newDistance / prevDistance;
                    touchMap.set(id1, touch1.screenX);
                    touchMapY.set(id1, touch1.screenY);
                    touchMap.set(id2, touch2.screenX);
                    touchMapY.set(id2, touch2.screenY);
                    return zoomFactor;
                } else {
                    if (!touchMap.exists(id1) && !touchMapY.exists(id1)) {
                        touchMap.set(id1, touch1.screenX);
                        touchMapY.set(id1, touch1.screenY);
                    }
                    if (!touchMap.exists(id2) && !touchMapY.exists(id1)) {
                        touchMap.set(id2, touch2.screenX);
                        touchMapY.set(id2, touch2.screenY);
                    }
                }
            } else if (touch1 != null && !touch1.pressed && touchMap.exists(touch1.touchPointID)) {
                touchMap.remove(touch1.touchPointID);
                touchMapY.remove(touch1.touchPointID);
            } else if (touch2 != null && !touch2.pressed && touchMap.exists(touch2.touchPointID)) {
                touchMap.remove(touch2.touchPointID);
                touchMapY.remove(touch2.touchPointID);
            }
        }
        return 1;
    }
}
