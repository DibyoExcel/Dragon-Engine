package dge.frontend;

import flixel.FlxCamera;
import flixel.FlxG;
//src: https://github.com/DibyoExcel/camera-z-older
class CameraZOrder {
    public static function moveOrderCamera(camera:FlxCamera, targetCamera:FlxCamera, behind:Bool = true):Void {
        if (camera == null || targetCamera == null || getCameraOrder(camera) == -1 || getCameraOrder(targetCamera) == -1) return;
        if (behind) {
            setCameraOrder(camera, getCameraOrder(targetCamera));
        } else {
            setCameraOrder(camera, getCameraOrder(targetCamera) + 1);
        }
    }

    public static function moveVeryTop(camera:FlxCamera):Void {
        if (camera == null || getCameraOrder(camera) == -1) return;
        FlxG.game.removeChild(camera.flashSprite);
        FlxG.cameras.list.remove(camera);
        FlxG.game.addChildAt(camera.flashSprite, @:privateAccess FlxG.game.getChildIndex(FlxG.game._inputContainer));
        FlxG.cameras.list.push(camera);
        reloadIDs();
    }

    public static function moveVeryBehind(camera:FlxCamera):Void {
        if (camera == null || getCameraOrder(camera) == -1) return;
        var childIdx = -1;
        for (cam in FlxG.cameras.list) {
            if (cam != null) {
                childIdx = FlxG.game.getChildIndex(cam.flashSprite);
                break;
            }
        }
        //sorry kinda bit redundant but is worked i guess
        //get lowest index from all cam in list
        for (cam in FlxG.cameras.list) {
            if (cam != null) {
                if (childIdx > FlxG.game.getChildIndex(cam.flashSprite) && FlxG.game.getChildIndex(cam.flashSprite) > -1) {
                    childIdx = FlxG.game.getChildIndex(cam.flashSprite);
                }
            }
        }
        if (childIdx > -1) {
            FlxG.game.removeChild(camera.flashSprite);
            FlxG.cameras.list.remove(camera);
            FlxG.cameras.list.insert(0, camera);
            FlxG.game.addChildAt(camera.flashSprite, childIdx);
            reloadIDs();    
        }
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
            FlxG.game.addChildAt(camera.flashSprite, @:privateAccess FlxG.game.getChildIndex(FlxG.game._inputContainer));
            FlxG.cameras.list.push(camera);
        }
        reloadIDs();
    }

    public static function setCameraOrder(camera:FlxCamera, index:Int):Void {
        if (index < 0) {
            return moveVeryBehind(camera);
        } else if (index >= FlxG.cameras.list.length) {
            return moveVeryTop(camera);
        }
        var camObj = FlxG.cameras.list[index];
        if (camObj == null || camera == null || getCameraOrder(camera) == -1) return;
        var childIdx = FlxG.game.getChildIndex(camObj.flashSprite);
        FlxG.game.removeChild(camera.flashSprite);
		FlxG.cameras.list.remove(camera);
        FlxG.game.addChildAt(camera.flashSprite, childIdx);
        FlxG.cameras.list.insert(index, camera);
        reloadIDs();
    }

    //it just add insert function for FlxG.cameras beside add()
    public static function insert(camera:FlxCamera, index:Int, DefaultDrawTarget:Bool = true):FlxCamera {
        if (camera == null) return null;
        if (index >= FlxG.cameras.list.length) {
            return FlxG.cameras.add(camera, DefaultDrawTarget);
        } else {
            while (index < 0) {//relative order?modulo relative order?idk
                index += FlxG.cameras.list.length;
            }
            var camObj = FlxG.cameras.list[index];
            if (camObj == null) {
                return FlxG.cameras.add(camera, DefaultDrawTarget);
            } else {
                var childIdx = FlxG.game.getChildIndex(camObj.flashSprite);
                FlxG.game.addChildAt(camera.flashSprite, childIdx);
                FlxG.cameras.list.insert(index, camera);
                if (DefaultDrawTarget) {
                    @:privateAccess FlxG.cameras.defaults.push(camera);
                }
                reloadIDs();
                FlxG.cameras.cameraAdded.dispatch(camera); 
            }

        }
        return camera;
    }

    public static function getCameraOrder(camera:FlxCamera):Int {
        if (camera != null) return FlxG.cameras.list.indexOf(camera);
        return -1;
    }

    public static function reloadIDs():Void {
        for (i in 0...FlxG.cameras.list.length) {
            if (FlxG.cameras.list[i] != null) {
                FlxG.cameras.list[i].ID = i;
            }
        }
    }
}