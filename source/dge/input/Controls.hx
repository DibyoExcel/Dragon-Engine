package dge.input;

import dge.input.device.KeyboardControls;
import dge.input.device.GamepadControls;
import dge.input.InputState;

class Controls {
    public static var instance:Controls;
    //hmm i try fake it from legacy Controls.hx
    public function new() {
    }
    public static function init():Void {
        instance = new Controls();
    }
    //left
    public var UI_LEFT(get, never):Bool;
    inline public function get_UI_LEFT():Bool {
        return checkKey('ui_left', P);
    }
    public var UI_LEFT_P(get, never):Bool;
    inline public function get_UI_LEFT_P():Bool {
        return checkKey('ui_left', JP);
    }
    public var UI_LEFT_R(get, never):Bool;
    inline public function get_UI_LEFT_R():Bool {
        return checkKey('ui_left', JR);
    }
    //down
    public var UI_DOWN(get, never):Bool;
    inline public function get_UI_DOWN():Bool {
        return checkKey('ui_down', P);
    }
    public var UI_DOWN_P(get, never):Bool;
    inline public function get_UI_DOWN_P():Bool {
        return checkKey('ui_down', JP);
    }
    public var UI_DOWN_R(get, never):Bool;
    inline public function get_UI_DOWN_R():Bool {
        return checkKey('ui_down', JR);
    }
    //up
    public var UI_UP(get, never):Bool;
    inline public function get_UI_UP():Bool {
        return checkKey('ui_up', P);
    }
    public var UI_UP_P(get, never):Bool;
    inline public function get_UI_UP_P():Bool {
        return checkKey('ui_up', JP);
    }
    public var UI_UP_R(get, never):Bool;
    inline public function get_UI_UP_R():Bool {
        return checkKey('ui_up', JR);
    }
    //right
    public var UI_RIGHT(get, never):Bool;
    inline public function get_UI_RIGHT():Bool {
        return checkKey('ui_right', P);
    }
    public var UI_RIGHT_P(get, never):Bool;
    inline public function get_UI_RIGHT_P():Bool {
        return checkKey('ui_right', JP);
    }
    public var UI_RIGHT_R(get, never):Bool;
    inline public function get_UI_RIGHT_R():Bool {
        return checkKey('ui_right', JR);
    }
    public var BACK(get, never):Bool;
    inline public function get_BACK():Bool {
        return checkKey('back', JP);
    }
    public var ACCEPT(get, never):Bool;
    inline public function get_ACCEPT():Bool {
        return checkKey('accept', JP);
    }
    public var RESET(get, never):Bool;
    inline public function get_RESET():Bool {
        return checkKey('reset', JP);
    }
    public var PAUSE(get, never):Bool;
    inline public function get_PAUSE():Bool {
        return checkKey('pause', JP);
    }
    inline public function checkKey(control:String, state:InputState):Bool {
        return KeyboardControls.checkKey(control, state) || GamepadControls.checkButton(control, state);
    }
}