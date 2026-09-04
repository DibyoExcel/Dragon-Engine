package dge.obj.game;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.events.Event;
import flixel.graphics.FlxGraphic;
using StringTools;

class VideoSprite extends FlxSprite
{
    var videoFake:vlc.MP4Handler;
	var volume:Float = 0;
    public var finishCallback:Void->Void;
	public function new(x:Float, y:Float, videoPath:String, camera:String = 'other', hasVolume:Bool = true) {
		super(x, y);
		this.visible = false;
		videoFake = new vlc.MP4Handler();
		videoFake.playVideo(videoPath);
		videoFake.volume = hasVolume ? 1 : 0;
		volume = hasVolume ? 1 : 0;
		videoFake.visible = false;
		videoFake.readyCallback = function () {
			this.visible = true;
			loadGraphic(FlxGraphic.fromBitmapData(videoFake.bitmapData, false, null, false));
			updateHitbox();
		}
		var camArray:Array<String> = camera.split(',');
		var realCam:Array<String> = [];
		for (i in 0...camArray.length) {
			realCam[i] = camArray[i].trim();
		}
		cameras = FunkinLua.cameraArrayFromString(realCam);
		videoFake.finishCallback = function () {
			if (finishCallback != null) {
                finishCallback();
            }
            destroy();
		};
		@:privateAccess FlxG.stage.removeEventListener(Event.ENTER_FRAME, videoFake.update);
	}
	
	override function update(e:Float):Void {
		super.update(e);
		videoFake.volume = volume;
	}

    public function resume() {
        videoFake.resume();
    }
    public function pause() {
        videoFake.pause();
    }
    public function finishVideo() {
        videoFake.finishVideo();
    }
}