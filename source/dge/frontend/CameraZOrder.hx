package dge.frontend;

import flixel.FlxCamera;
import flixel.FlxG;
class CameraZOrder {
    public static function moveBehind(camera:FlxCamera, targetCamera:FlxCamera):Void {
        moveCameraOrder(camera, targetCamera, true);
    }
    public static function moveInFront(camera:FlxCamera, targetCamera:FlxCamera):Void {
        moveCameraOrder(camera, targetCamera, false);
    }
    public static function moveToFront(camera:FlxCamera):Void {
        if (camera == null || FlxG.cameras.list.indexOf(camera) == -1) return;
        FlxG.game.removeChild(camera.flashSprite);
        FlxG.cameras.list.remove(camera);
        FlxG.game.addChildAt(camera.flashSprite, @:privateAccess FlxG.game.getChildIndex(FlxG.game._inputContainer) + 1);
        FlxG.cameras.list.push(camera);
        reloadIDs();
    }
    public static function moveCameraOrder(camera:FlxCamera, targetCamera:FlxCamera, behind:Bool = true) {
        if (camera == null || targetCamera == null || FlxG.cameras.list.indexOf(camera) == -1 || FlxG.cameras.list.indexOf(targetCamera) == -1) return;
        FlxG.game.removeChild(camera.flashSprite);
        FlxG.cameras.list.remove(camera);
        var targetIndex:Int = FlxG.game.getChildIndex(targetCamera.flashSprite);
		var targetList = FlxG.cameras.list.indexOf(targetCamera);
        if (behind) {
            FlxG.game.addChildAt(camera.flashSprite, targetIndex);
            FlxG.cameras.list.insert(targetList, camera);
        } else {
            FlxG.game.addChildAt(camera.flashSprite, targetIndex + 1);
            FlxG.cameras.list.insert(targetList + 1, camera);
        }
        reloadIDs();
    }
    public static function reorderCamera(cameraList:Array<FlxCamera>):Void {
        var camList = FlxG.cameras.list;
        for (camera in camList) {
            if (camera == null || cameraList.indexOf(camera) == -1) continue;
            FlxG.game.removeChild(camera.flashSprite);
            FlxG.cameras.list.remove(camera);
        }
        for (camera in cameraList) {
            if (camera == null || camList.indexOf(camera) == -1) continue;
            FlxG.game.addChildAt(camera.flashSprite, @:privateAccess FlxG.game.getChildIndex(FlxG.game._inputContainer) + 1);
            FlxG.cameras.list.push(camera);
        }
        reloadIDs();
    }
    static function reloadIDs():Void {
        for (i in 0...FlxG.cameras.list.length) {
            if (FlxG.cameras.list[i] != null) {
                FlxG.cameras.list[i].ID = i;
            }
        }
    }
}