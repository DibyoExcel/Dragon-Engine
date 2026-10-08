package dge.backend;

import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import dge.input.device.KeyboardControls;
import flixel.input.gamepad.FlxGamepadInputID;
import dge.input.device.GamepadControls;

//extra keys
class EKUtil {
    public static var colArray:Array<String>= ['purple', 'blue', 'green', 'red', 'space', 'yellow', 'purplealt', 'redalt', 'bluealt'];
    public static var pixelInt:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8];
    public static var noteAnimIndex:Array<Array<Int>> = [
        [4],
        [0, 3],
        [0, 4, 3],
        [0, 1, 2, 3],
        [0, 1, 4, 2, 3],
        [0, 1, 3, 5, 2, 8],
        [0, 1, 3, 4, 5, 2, 8],
        [0, 1, 2, 3, 5, 6, 7, 8],
        [0, 1, 2, 3, 4, 5, 6, 7, 8]
    ];
    public static var animIndex:Array<Array<String>> = [
        ['singUP'],
        ['singLEFT', 'singRIGHT'],
        ['singLEFT', 'singUP', 'singRIGHT'],
        ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'],
        ['singLEFT', 'singDOWN', 'singUP', 'singUP', 'singRIGHT'],
        ['singLEFT', 'singDOWN', 'singRIGHT', 'singLEFT', 'singUP', 'singRIGHT'],
        ['singLEFT', 'singDOWN', 'singRIGHT', 'singUP', 'singLEFT', 'singUP', 'singRIGHT'],
        ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT'],
        ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singUP', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT']
    ];
    public static var controlMap:Array<Array<String>> = [
        ['note_1K_space'],
        ['note_2K_left', 'note_2K_right'],
        ['note_3K_left', 'note_3K_space', 'note_3K_right'],
        ['note_left', 'note_down', 'note_up', 'note_right'],
        ['note_5K_left', 'note_5K_down', 'note_5K_space', 'note_5K_up', 'note_5K_right'],
        ['note_6K_left', 'note_6K_down', 'note_6K_right', 'note_6K_left2', 'note_6K_up', 'note_6K_right2'],
        ['note_7K_left', 'note_7K_down', 'note_7K_right', 'note_7K_space', 'note_7K_left2', 'note_7K_up', 'note_7K_right2'],
        ['note_8K_left', 'note_8K_down', 'note_8K_up', 'note_8K_right', 'note_8K_left2', 'note_8K_down2', 'note_8K_up2', 'note_8K_right2'],
        ['note_9K_left', 'note_9K_down', 'note_9K_up', 'note_9K_right', 'note_9K_space', 'note_9K_left2', 'note_9K_down2', 'note_9K_up2', 'note_9K_right2']
    ];
    public static var keyPressColor:Array<Array<FlxColor>> = [
        [0xFFCCCCCC],
        [0xFFFF00FF, 0xFFFF0000],
        [0xFFFF00FF, 0xFFCCCCCC, 0xFFFF0000],
        [0xFFFF00FF, 0xFF00FFFF, 0xFF00FF00, 0xFFFF0000],
        [0xFFFF00FF, 0xFF00FFFF, 0xFFCCCCCC, 0xFF00FF00, 0xFFFF0000],
        [0xFFFF00FF, 0xFF00FFFF, 0xFFFF0000, 0xFFFFFF00, 0xFF00FF00, 0xFF0000FF],
        [0xFFFF00FF, 0xFF00FFFF, 0xFFFF0000, 0xFFCCCCCC, 0xFFFFFF00, 0xFF00FF00, 0xFF0000FF],
        [0xFFFF00FF, 0xFF00FFFF, 0xFF00FF00, 0xFFFF0000, 0xFFFFFF00, 0xFF8000FF, 0xFFFF0000, 0xFF0000FF],
        [0xFFFF00FF, 0xFF00FFFF, 0xFF00FF00, 0xFFFF0000, 0xFFCCCCCC, 0xFFFFFF00, 0xFF8000FF, 0xFFFF0000, 0xFF0000FF]
    ];
    public static function getNoteScale(noteKey:Int, ?sizeChange:Int = 5):Float {
        if (noteKey <= sizeChange) return 1;
        var size = sizeChange / noteKey;
        if (size < 0.3) size = 0.3;
        return size;
    }
    public static function getCurrentMania():Int {
        if (PlayState.SONG != null && PlayState.SONG.mania != null) {
            return Std.int(Math.min(noteAnimIndex.length, Math.max(1, PlayState.SONG.mania)));
        }
        return 4;
    }
    public static function getAnimArray():Array<String> {
        return animIndex[getCurrentMania()-1];
    }

    public static function getKeybind():Array<Array<FlxKey>> {
        var copyArray:Array<Array<FlxKey>>=[];
        for (key in controlMap[getCurrentMania()-1]) {
            copyArray.push(KeyboardControls.getKeybind(key));
        }
        return copyArray;
    }
    
    public static function getButtonbind():Array<Array<FlxGamepadInputID>> {
        var copyArray:Array<Array<FlxGamepadInputID>>=[];
        for (key in controlMap[getCurrentMania()-1]) {
            copyArray.push(GamepadControls.getButtonbind(key));
        }
        return copyArray;
    }
    
}