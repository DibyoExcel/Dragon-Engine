package dge.obj.mobile;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxPoint;

class TouchButton extends FlxSprite {
    //button state
    public var justPressed(default, set):Bool = false;
    public var justReleased(default, set):Bool = false;
    public var pressed:Bool = false;
    
    public var disableInput:Bool = false;
    public var stickyInput:Bool = false; //prevent button from releasing when the touch moves off the button
    
    private var touch:FlxTouch = null;
    private static var _touchPoint:FlxPoint = new FlxPoint();//prevent GC stress

    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        scrollFactor.set();
        ignoreCameraAngle = true;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Reset button state
        justPressed = false;
        justReleased = false;
        pressed = false;

        if (disableInput) {
            touch = null;
            return;
        }

        if (touch == null) {
            for (t in FlxG.touches.list) {
                if (t != null && checkTouchOverlap(t)) {
                    var isValidPress = stickyInput ? t.justPressed : t.pressed;
                    if (isValidPress) {
                        touch = t;
                        justPressed = true;
                        pressed = true;
                        break;
                    }
                }
            }
        } else {
            if (!stickyInput && !checkTouchOverlap(touch)) {
                touch = null;
                justReleased = true;
                return;
            }
            if (touch != null) {
                if (touch.justReleased) {
                    touch = null;
                    justReleased = true;
                } else if (touch.pressed) {
                    pressed = true;
                }
            }
        }
    }
    private function checkTouchOverlap(t:FlxTouch):Bool {
        var cams = (cameras != null) ? cameras : @:privateAccess FlxCamera._defaultCameras;
        if (cams == null) return false;

        for (cam in cams) {
            if (cam != null) {
                t.getWorldPosition(cam, _touchPoint);
                if (overlapsPoint(_touchPoint, true, cam)) {
                    return true;
                }
            }
        }
        return false;
    }

    override public function destroy():Void {
        touch = null;
        super.destroy();
    }

    private function set_justReleased(value:Bool):Bool {
        return justReleased = value;
    }

    private function set_justPressed(value:Bool):Bool {
        return justPressed = value;
    }
}