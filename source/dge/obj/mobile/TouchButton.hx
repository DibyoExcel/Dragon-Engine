package dge.obj.mobile;

//better input button

import flixel.FlxCamera;
import flixel.input.touch.FlxTouch;
import flixel.FlxSprite;
import flixel.FlxG;

class TouchButton extends FlxSprite{
    private var touch:FlxTouch = null;
    public var justPressed(default, set):Bool = false;
    public var justReleased(default, set):Bool = false;
    public var pressed:Bool = false;
    public var disableInput = false;
    public var stickyInput:Bool = false;//make button persist press even button got moved out from finger or finger move out from button(not released) until finger released

     public function new(x:Float, y:Float) {
         super(x, y);
         scrollFactor.set();
     }

    //can ovveride this senter if want detect
    private function set_justReleased(value:Bool):Bool {
        return value;
    }

    private function set_justPressed(value:Bool):Bool {
        return value;
    }
    override public function update(e:Float):Void {
        //reimplement custom FlxButton because FlxButton so broken when multi touch:v
        super.update(e);
        justPressed = false;
        justReleased = false;
        pressed = false;
        if (disableInput) {
            touch = null;
            return;
        }
        if (touch == null) {
            for (touch in FlxG.touches.list) {
                var cams = cameras;
                if (cams == null) {
                    cams = @:privateAccess {FlxCamera._defaultCameras;};
                }
                for (cam in cams) {
                    if (touch != null &&  overlapsPoint(touch.getWorldPosition(cam), true, cam)) {//WTF?Also copy from FlxButton
                        if (stickyInput ? touch.justPressed : touch.pressed) {
                            this.touch = touch;
                            justPressed = true;
                            justReleased = false;
                            pressed = true;
                        }
                        break;
                    }
                }
            }
        } else {
            if (!stickyInput) {
                for (cam in cameras) {
                    if (touch != null &&  !overlapsPoint(touch.getWorldPosition(cam), true, cam)) {
                        touch = null;
                        justReleased = true;
                        pressed = false;
                        justPressed = false;//just incase
                        break;
                    }
                }
            }
            if (touch != null) {
                if (touch.pressed) {
                    pressed = true;
                }
                if (touch.justReleased) {
                    touch = null;
                    justReleased = true;
                    pressed = false;
                    justPressed = false;//just incase
                }
            }
        }
     }
}