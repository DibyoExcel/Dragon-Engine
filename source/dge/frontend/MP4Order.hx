package dge.frontend;
import vlc.MP4Handler;
import flixel.FlxCamera;
import flixel.FlxG;
//same like CameraZOrder but for `MP4Handler` object relations with FlxCamera
//great now `MP$Handler` now can be useful

class MP4Order {
    public static function moveVideoOrder(obj:MP4Handler,camera:FlxCamera, behind:Bool = true) {
        if (obj != null && camera != null) {
            var getIndex = FlxG.game.getChildIndex(camera.flashSprite);
            if (!behind) {
                getIndex++;
            }
            removeChild(obj);
            setVideoOrder(obj, getIndex);
        }
    }
    public static function moveVeryBehind(obj:MP4Handler):Void {
        if (obj == null) return;
        var childIdx = -1;
        for (cam in FlxG.cameras.list) {
            if (cam != null) {
                childIdx = FlxG.game.getChildIndex(cam.flashSprite);
                break;
            }
        }
        for (cam in FlxG.cameras.list) {
            if (cam != null) {
                if (childIdx > FlxG.game.getChildIndex(cam.flashSprite) && FlxG.game.getChildIndex(cam.flashSprite) > -1) {
                    childIdx = FlxG.game.getChildIndex(cam.flashSprite);
                }
            }
        }
        if (childIdx > -1) {
            removeChild(obj);
            FlxG.game.addChildAt(obj, childIdx);
        }
    }
    public static function moveVeryTop(obj:MP4Handler):Void {
        if (obj == null) return;
        removeChild(obj);
        FlxG.game.addChildAt(obj, @:privateAccess FlxG.game.getChildIndex(FlxG.game._inputContainer));
    }
    public static function setVideoOrder(obj:MP4Handler, index:Int):Void {
        if (index < 0) {
            return moveVeryBehind(obj);
        } else if (index >= FlxG.cameras.list.length) {
            return moveVeryTop(obj);
        }
        var camObj = FlxG.cameras.list[index];
        if (camObj == null || CameraZOrder.getCameraOrder(camObj) == -1) return;
        var childIdx = FlxG.game.getChildIndex(camObj.flashSprite);
        removeChild(obj);
        FlxG.game.addChildAt(obj, childIdx);
    }
    static function removeChild(obj:MP4Handler) {//very stupid function lol
        if (obj != null) {
            FlxG.game.removeChild(obj);
        }
    }
}