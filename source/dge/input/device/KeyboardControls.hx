package dge.input.device;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import dge.input.InputState;


class KeyboardControls {
    public static var defaultKeys:Map<String, Array<FlxKey>> = new Map<String, Array<FlxKey>>();
    public static var keyBinds:Map<String, Array<FlxKey>> = [
        //4K
        'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
        
        //1K
        'note_1K_space' => [SPACE, NONE],

        //2K
        'note_2K_left'  => [A, LEFT],
        'note_2K_right' => [D, RIGHT],

        //3K
        'note_3K_left'  => [A, LEFT],
        'note_3K_space' => [SPACE, NONE],
        'note_3K_right' => [D, LEFT],

        //4K already exists at very top
        //5K
        'note_5K_left'  => [A, LEFT],
        'note_5K_down'  => [S, DOWN],
        'note_5K_space' => [SPACE, NONE],
        'note_5K_up'    => [W, UP],
        'note_5K_right' => [D, RIGHT],

        //6K
        'note_6K_left'  => [S, NONE],
        'note_6K_down'  => [D, NONE],
        'note_6K_right' => [F, NONE],
        'note_6K_left2' => [J, NONE],
        'note_6K_up'    => [K, NONE],
        'note_6K_right2'=> [L, NONE],

        //7K
        'note_7K_left'  => [S, NONE],
        'note_7K_down'  => [D, NONE],
        'note_7K_right' => [F, NONE],
        'note_7K_space' => [SPACE, NONE],
        'note_7K_left2' => [J, NONE],
        'note_7K_up'    => [K, NONE],
        'note_7K_right2'=> [L, NONE],

        //8K
        'note_8K_left'  => [A, NONE],
        'note_8K_down'  => [S, NONE],
        'note_8K_up'    => [D, NONE],
        'note_8K_right' => [F, NONE],
        'note_8K_left2' => [H, NONE],
        'note_8K_down2' => [J, NONE],
        'note_8K_up2'   => [K, NONE],
        'note_8K_right2'=> [L, NONE],

        //9K
        'note_9K_left'  => [A, NONE],
        'note_9K_down'  => [S, NONE],
        'note_9K_up'    => [D, NONE],
        'note_9K_right' => [F, NONE],
        'note_9K_space' => [SPACE, NONE],
        'note_9K_left2' => [H, NONE],
        'note_9K_down2' => [J, NONE],
        'note_9K_up2'   => [K, NONE],
        'note_9K_right2'=> [L, NONE],

		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
    ];
    public static function init() {
        loadDefaultKeybind();
        var save:FlxSave = new FlxSave();
        save.bind('controls_v2', 'ninjamuffin99');//legacy bind
        if (save != null && save.data.customControls != null) {
            var loadC:Map<String, Array<FlxKey>> = save.data.customControls;
            for (control => key in loadC) {
                keyBinds.set(control, key);
            }
        }
    }
    public static function loadDefaultKeybind() {
        defaultKeys = keyBinds.copy();
    }

    public static function saveKeybind() {
        var save:FlxSave = new FlxSave();
        save.bind('controls_v2', 'ninjamuffin99');//legacy bind
        if (save != null) {
            save.data.customControls = keyBinds;
            save.flush();
        }
    }
    public static function getKeybind(control:String):Array<FlxKey> {
        var copiedArray:Array<FlxKey> = keyBinds.get(control).copy();
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
    public static function reloadControls() {
		TitleState.muteKeys = getKeybind('volume_mute');
		TitleState.volumeDownKeys = getKeybind('volume_down');
		TitleState.volumeUpKeys = getKeybind('volume_up');
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}

    public static function checkKey(control:String, state:InputState = JP):Bool {
        var keys:Array<FlxKey> = getKeybind(control);
        for (key in keys) {
            switch (state) {
                case PRESSED | P:
                    if (FlxG.keys.checkStatus(key, PRESSED)) return true;
                case JUST_RELEASED | JR:
                    if (FlxG.keys.checkStatus(key, JUST_RELEASED)) return true;
                case JUST_PRESSED | JP:
                    if (FlxG.keys.checkStatus(key, JUST_PRESSED)) return true;
            }
        }
        return false;
    }  
}