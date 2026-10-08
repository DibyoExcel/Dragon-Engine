package dge.input.device;

import flixel.util.FlxSave;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import dge.input.InputState;

class GamepadControls {
    public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = new Map<String, Array<FlxGamepadInputID>>();
    public static var buttonBinds:Map<String, Array<FlxGamepadInputID>> = [
        //4K
        'note_left'     => [DPAD_LEFT, X],
        'note_down'     => [DPAD_DOWN, A],
        'note_up'       => [DPAD_UP, Y],
        'note_right'    => [DPAD_RIGHT, B],

        //1K
        'note_1K_space' => [RIGHT_SHOULDER, NONE],

        //2K
        'note_2K_left'  => [DPAD_LEFT, X],
        'note_2K_right' => [DPAD_RIGHT, B],
        
        //3K
        'note_3K_left'  => [DPAD_LEFT, X],
        'note_3K_space' => [RIGHT_SHOULDER, NONE],
        'note_3K_right' => [DPAD_RIGHT, B],
        
        //5K
        'note_5K_left'  => [DPAD_LEFT, X],
        'note_5K_down'  => [DPAD_DOWN, A],
        'note_5K_space' => [RIGHT_SHOULDER, NONE],
        'note_5K_up'    => [DPAD_UP, Y],
        'note_5K_right' => [DPAD_RIGHT, B],

        //6K
        'note_6K_left'  => [DPAD_LEFT, NONE],
        'note_6K_down'  => [DPAD_DOWN, NONE],
        'note_6K_right' => [DPAD_RIGHT, NONE],
        'note_6K_left2' => [X, NONE],
        'note_6K_up'    => [A, NONE],
        'note_6K_right2'=> [B, NONE],

        //7K
        'note_7K_left'  => [DPAD_LEFT, NONE],
        'note_7K_down'  => [DPAD_DOWN, NONE],
        'note_7K_right' => [DPAD_RIGHT, NONE],
        'note_7K_space' => [RIGHT_SHOULDER, NONE],
        'note_7K_left2' => [X, NONE],
        'note_7K_up'    => [A, NONE],
        'note_7K_right2'=> [B, NONE],

        //8K
        'note_8K_left'  => [DPAD_LEFT, NONE],
        'note_8K_down'  => [DPAD_DOWN, NONE],
        'note_8K_up'    => [DPAD_UP, NONE],
        'note_8K_right' => [DPAD_RIGHT, NONE],
        'note_8K_left2' => [X, NONE],
        'note_8K_down2' => [A, NONE],
        'note_8K_up2'   => [Y, NONE],
        'note_8K_right2'=> [B, NONE],

        //9K
        'note_9K_left'  => [DPAD_LEFT, NONE],
        'note_9K_down'  => [DPAD_DOWN, NONE],
        'note_9K_up'    => [DPAD_UP, NONE],
        'note_9K_right' => [DPAD_RIGHT, NONE],
        'note_9K_space' => [RIGHT_SHOULDER, NONE],
        'note_9K_left2' => [X, NONE],
        'note_9K_down2' => [A, NONE],
        'note_9K_up2'   => [Y, NONE],
        'note_9K_right2'=> [B, NONE],

        'ui_left'       => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
        'ui_down'       => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
        'ui_up'         => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
        'ui_right'      => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
        
        'accept'        => [A, START],
        'back'          => [B, BACK],
        'pause'         => [START, NONE],
        'reset'         => [RIGHT_STICK_CLICK, NONE],
        
        'debug_1'       => [LEFT_TRIGGER, NONE],
        'debug_2'       => [RIGHT_TRIGGER, NONE]
    ];

    public static function init() {
        loadDefaultButtonbind();
        var save:FlxSave = new FlxSave();
        save.bind('gamepad_controls_v2', 'ninjamuffin99'); // legacy gamepad bind
        if (save != null && save.data.customGamepadControls != null) {
            var loadC:Map<String, Array<FlxGamepadInputID>> = save.data.customGamepadControls;
            for (control => button in loadC) {
                buttonBinds.set(control, button);
            }
        }
    }

    public static function loadDefaultButtonbind() {
        defaultButtons = buttonBinds.copy();
    }

    public static function saveButtonbind() {
        var save:FlxSave = new FlxSave();
        save.bind('gamepad_controls_v2', 'ninjamuffin99');
        if (save != null) {
            save.data.customGamepadControls = buttonBinds;
            save.flush();
        }
    }

    public static function getButtonbind(control:String):Array<FlxGamepadInputID> {
        var buttons:Array<FlxGamepadInputID> = buttonBinds.get(control);
        if (buttons == null) return [];

        var copiedArray:Array<FlxGamepadInputID> = buttons.copy();
        var i:Int = 0;
        var len:Int = copiedArray.length;
        while (i < len) {
            if (copiedArray[i] == NONE) {
                copiedArray.remove(NONE);
                --i;
            }
            i++;
            len = copiedArray.length;
        }
        return copiedArray;
    }

    public static function checkButton(control:String, state:InputState = JP):Bool {
        var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
        if (gamepad == null) return false;

        var buttons:Array<FlxGamepadInputID> = getButtonbind(control);
        for (button in buttons) {
            switch (state) {
                case PRESSED | P:
                    if (gamepad.checkStatus(button, PRESSED)) return true;
                case JUST_RELEASED | JR:
                    if (gamepad.checkStatus(button, JUST_RELEASED)) return true;
                case JUST_PRESSED | JP:
                    if (gamepad.checkStatus(button, JUST_PRESSED)) return true;
            }
        }
        return false;
    }
}