package;

import flixel.FlxG;
import flixel.FlxSprite;
using StringTools;

class NoteSplash extends FlxSprite
{
	private var idleAnim:String;
	private var strum:StrumNote = null;
	private var note:Note = null;

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
		shaderType = 'swap';

		setupNoteSplash(x, y, note);
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	public function setupNoteSplash(x:Float, y:Float, note:Int = 0, texture:String = null, hueColor:Float = 0, satColor:Float = 0, brtColor:Float = 0, cam:String = '', scale:Float = 1, sfX:Float = 1.0, sfY:Float = 1.0, ?oriNote:Note) {
		alpha = ClientPrefs.noteSplashAlpha;//for case

		if(texture == null || texture.length <= 0) {
			var skin:String = PlayState.SONG.splashSkin;
			var skinOpt:String = PlayState.SONG.splashSkinOpt;
			var skinSec:String = PlayState.SONG.splashSkinSec;
			if (skin == null || skin.length < 1) {
				skin = "noteSplashes";
			}
			if (skinOpt == null || skinOpt.length < 1) {
				skinOpt = skin;
			}
			if (skinSec == null || skinSec.length < 1) {
				if (skinOpt == null || skinOpt.length < 1) {
					skinOpt = skin;
				}
				skinSec = skinOpt;
			}
			if (oriNote != null) {
				if (oriNote.mustPress) {
					texture = skin;
				} else if (oriNote.gfNote) {
					texture = skinSec;
				} else {
					texture = skinOpt;
				}
			} else {
				texture = 'noteSplashes';
			}
		}
		if (cam != null && cam != '') {
			var camArray:Array<String> = cam.split(',');
			var realCam:Array<String> = [];
			for (i in 0...camArray.length) {
				realCam[i] = camArray[i].trim();
			}
			cameras = FunkinLua.cameraArrayFromString(realCam);
		}
		scrollFactor.set(sfX, sfY);
		loadAnims(texture);
		setGraphicSize(Std.int(width*scale), Std.int(height*scale));
		var noteWidth = Note.swagWidth;
		var noteHeight = Note.swagWidth;
		var noteSplashOffsetX = 0.0;
		var noteSplashOffsetY = 0.0;
		var noteSplashOffsetOriginX = 0.0;
		var noteSplashOffsetOriginY = 0.0;
		if (oriNote != null) {
			this.note = oriNote;
			if (oriNote.strumNote != null) this.strum = oriNote.strumNote;
			shaderType = oriNote.noteSplashShaderType;
            if (shaderType == 'swap') {
				//swap
                colorSwap.hue = oriNote.noteSplashHue;
                colorSwap.saturation = oriNote.noteSplashSat;
                colorSwap.brightness = oriNote.noteSplashBrt;
            }
            if (shaderType == 'single') {
                //single
                colorSingle.r = oriNote.noteSplashSingleR;
                colorSingle.g = oriNote.noteSplashSingleG;
                colorSingle.b = oriNote.noteSplashSingleB;
            }
            if (shaderType == 'invert') {
                //invert
                colorInvert.invertR = oriNote.noteSplashInvertR;
                colorInvert.invertG = oriNote.noteSplashInvertG;
                colorInvert.invertB = oriNote.noteSplashInvertB;
            }
            if (shaderType == 'rgbswap') {
                //rgbSwap
                colorRGBSwap.swapR = oriNote.noteSplashRGBSwapR;
                colorRGBSwap.swapG = oriNote.noteSplashRGBSwapG;
                colorRGBSwap.swapB = oriNote.noteSplashRGBSwapB;
            }
            if (shaderType == 'pixel') {
                //pixel
                pixelSprite.pixelSize = oriNote.noteSplashPixelSize;
            }
            if (shaderType == 'posterize') {
                //posterize
                posterize.posterizeRange = oriNote.noteSplashPosterizeRange;
            }
            if (shaderType == 'rgbpalette') {
                //rgb palette
                rgbShader.r = oriNote.noteSplashR;
                rgbShader.g = oriNote.noteSplashG;
                rgbShader.b = oriNote.noteSplashB;
            }
            if (shaderType == 'grayscale') {
                //grayscale
                grayScale.mult = oriNote.noteSplashGrayscaleMult;
            }
            if (shaderType == 'b&w') {
                //black and white
                blackAndWhite.mult = oriNote.noteSplashBAndWMult;
                blackAndWhite.threshold = oriNote.noteSplashBAndWThreshold;
            }
			//angle
			angle = oriNote.noteSplashAngle;
			//alpha
			if (oriNote.noteSplashCopyAlpha && oriNote.strumNote != null) {
				alpha = oriNote.strumNote.alpha * oriNote.noteSplashAlpha;
			} else {
				alpha = oriNote.noteSplashAlpha;
			}
			if (oriNote.strumNote != null) {
				noteWidth = oriNote.strumNote.width;
				noteHeight = oriNote.strumNote.height;
			}
			noteSplashOffsetX = oriNote.noteSplashOffsetX;
			noteSplashOffsetY = oriNote.noteSplashOffsetY;
			noteSplashOffsetOriginX = oriNote.noteSplashOffsetOriginX;
			noteSplashOffsetOriginY = oriNote.noteSplashOffsetOriginY;
		}
		setPosition((x + (noteWidth/2)-(width/2))+noteSplashOffsetX, (y + (noteHeight/2))-(height/2)+noteSplashOffsetY);
		//offset.set(10, 10);//what is this?!?
		
		var animNum:Int = FlxG.random.int(1, 2);
		animation.play('note' + (note % 4) + '-' + animNum, true);
		if(animation.curAnim != null)animation.curAnim.frameRate = ClientPrefs.fpsStrumAnim + FlxG.random.int(-2, 2);
		centerOrigin();
		origin.x += noteSplashOffsetOriginX;
		origin.y += noteSplashOffsetOriginY;
	}

	function loadAnims(skin:String) {
		try{
			frames = Paths.getSparrowAtlas(skin);
		}
		catch(e:Dynamic) {
			frames = Paths.getSparrowAtlas('noteSplashes');
		}
		var col = [ 'purple', 'blue', 'green', 'red' ];
		for (color in 0...col.length) {
			for (i in 1...3) {
				animation.addByPrefix("note" + color + "-" + i, "note splash " + col[color] + ' ' + i, ClientPrefs.fpsStrumAnim, false);
			}
		}
	}

	override function update(elapsed:Float) {
		if (strum != null && note != null) {
			if (note.noteSplashCopyAlpha) {
				alpha = strum.alpha * note.noteSplashAlpha;
			} 
		}
		if(animation.curAnim != null)if(animation.curAnim.finished) kill();

		super.update(elapsed);
	}
}