package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
using StringTools;

class NoteSplash extends FlxSprite
{
	public var colorSwap:ColorSwap = null;
	private var idleAnim:String;
	private var textureLoaded:String = null;

	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0, ?type:String = 'bf') {
		super(x, y);

		var skin:String = 'noteSplashes';
		if (type == 'bf') {
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		} else if (type == 'opt') {
			if(PlayState.SONG.splashSkinOpt != null && PlayState.SONG.splashSkinOpt.length > 0) skin = PlayState.SONG.splashSkinOpt;
		} else if (type == 'gf') {
			if(PlayState.SONG.splashSkinSec != null && PlayState.SONG.splashSkinSec.length > 0) skin = PlayState.SONG.splashSkinSec;
		}

		loadAnims(skin);
		
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, cam:String = '', scale:Float = 1, sfX:Float = 1.0, sfY:Float = 1.0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = ClientPrefs.noteSplashAlpha;

		if(texture == null) {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		setGraphicSize(Std.int(width*scale), Std.int(height*scale));
		if (cam != null && cam != '') {
			var camArray:Array<String> = cam.split(',');
			var realCam:Array<String> = [];
			for (i in 0...camArray.length) {
				realCam[i] = camArray[i].trim();
			}
			cameras = FunkinLua.cameraArrayFromString(realCam);
		}
		scrollFactor.set(sfX, sfY);

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + (note % 4) + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = ClientPrefs.fpsStrumAnim + FlxG.random.int(-2, 2);
	}

	public function setupNoteSplashOpt(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, cam:String = '', scale:Float = 1, sfX:Float = 1.0, sfY:Float = 1.0) {
		setPosition(x - Note.swagWidth * 0.95, y - Note.swagWidth);
		alpha = ClientPrefs.noteSplashAlpha;

		if(texture == null) {
			texture = 'noteSplashes';
			if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) texture = PlayState.SONG.splashSkin;
		}
		setGraphicSize(Std.int(width*scale), Std.int(height*scale));
		if (cam != null || cam != '') {
			var camArray:Array<String> = cam.split(',');
			var realCam:Array<String> = [];
			for (i in 0...camArray.length) {
				realCam[i] = camArray[i].trim();
			}
			cameras = FunkinLua.cameraArrayFromString(realCam);
		}
		scrollFactor.set(sfX, sfY);

		if(textureLoaded != texture) {
			loadAnims(texture);
		}
		colorSwap.hue = hueColor;
		colorSwap.saturation = satColor;
		colorSwap.brightness = brtColor;
		offset.set(10, 10);

		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + (note % 4) + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = ClientPrefs.fpsStrumAnim + FlxG.random.int(-2, 2);
	}

	function loadAnims(skin:String) {
		frames = Paths.getSparrowAtlas(skin);
		for (i in 1...3) {
			animation.addByPrefix("note1-" + i, "note splash blue " + i, ClientPrefs.fpsStrumAnim, false);
			animation.addByPrefix("note2-" + i, "note splash green " + i, ClientPrefs.fpsStrumAnim, false);
			animation.addByPrefix("note0-" + i, "note splash purple " + i, ClientPrefs.fpsStrumAnim, false);
			animation.addByPrefix("note3-" + i, "note splash red " + i, ClientPrefs.fpsStrumAnim, false);
		}
	}

	override function update(elapsed:Float) {
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}