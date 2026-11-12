package;

import Type.ValueType;
import editors.ChartingState;
import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.FlxCamera;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import dge.obj.game.HoldCover;

using StringTools;
import dge.backend.EKUtil;
import dge.frontend.math.BoundHelper.Point;

typedef NoteJson = {
	noteData:Null<NoteSide>
}

typedef NoteSide = {
	global:Null<NoteState>,
	player:Null<NoteState>,
	opponent:Null<NoteState>,
	gfPlayer:Null<NoteState>,
	gfOpponent:Null<NoteState>
}

typedef NoteState = {
	sustain:Dynamic,
	normal:Dynamic
}

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

typedef ExternalSpriteData = {
	shader:ShaderShit,
	shaderType:String,
	texture:String,
	angle:Float,
	alpha:Float,
	camera:String,
	scale:Float,
	scrollFactor:Point,
	offset:Point,
	offsetOrigin:Point,
	copyAlpha:Bool,
	disabled:Bool
}

typedef ShaderShit = {
	//colorSwap
	colorSwap:ColorSwapSetting,
	//single
	singleColor:RGBFloat,
	//invert
	invertColor:RGBBool,
	//RGBSwap
	rgbSwap:RGBInt,
	//pixel
	pixel:PixelSetting,
	//posterize
	posterize:PosterizeSetting,
	//RGB Palette
	rgbPalette:RGBInt,
	//GS
	grayscale:GrayscaleSetting,
	//BW
	BAndW:BANDWSetting
}

typedef ColorSwapSetting = {
	hue:Float,
	saturation:Float,
	brightness:Float
}

typedef RGBBool = {
	r:Bool,
	g:Bool,
	b:Bool
}

typedef RGBFloat = {
	r:Float,
	g:Float,
	b:Float
}

typedef RGBInt = {
	r:Int,
	g:Int,
	b:Int
}

typedef PixelSetting = {
	size:Float
}

typedef PosterizeSetting = {
	range:Float
}

typedef GrayscaleSetting = {
	mult:Float
}

typedef BANDWSetting = {
	mult:Float,
	threshold:Float
}


class Note extends FlxSprite
{
	public var extraData:Map<String, Dynamic> = [];

	public var strumTime:Float = 0;
	public var mustPress(default, set):Bool = false;
	public var isDad:Bool = false; // For Player play as opponent
	public var noteData(default, set):Int = 0;//add for adaptive note(not color swap change)
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var ignoreNote:Bool = false;
	public var hitByOpponent:Bool = false;
	public var noteWasHit:Bool = false;
	public var prevNote:Note;
	public var nextNote:Note;

	public var spawned:Bool = false;

	public var tail:Array<Note> = []; // for sustains
	public var parent:Note;
	public var blockHit:Bool = false; // only works for player

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var noteType(default, set):String = null;

	public var eventName:String = '';
	public var eventLength:Int = 0;
	public var eventVal1:String = '';
	public var eventVal2:String = '';

	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote(default, set):Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth(get, never):Float;

	// private var EKutil.colArray:Array<String> = ['purple', 'blue', 'green', 'red', 'space', 'yellow', 'purplealt', 'redalt', 'bluealt'];
	// private var EKUtil.pixelInt:Array<Int> = [0, 1, 2, 3, 4, 5, 6, 7, 8];

	// Lua shit
	@:deprecated("use noteSplashData.disabled instead")
	public var noteSplashDisabled(get, set):Bool;
	@:deprecated("use noteSplashData.texture instead")
	public var noteSplashTexture(get, set):String;
	@:deprecated("use noteSplashData.shaderType instead")
	public var noteSplashShaderType(get, set):String;
	@:deprecated("use noteSplashData.angle instead")
	public var noteSplashAngle(get, set):Float;
	@:deprecated("use noteSplashData.alpha instead")
	public var noteSplashAlpha(get, set):Float;
	//swap
	@:deprecated("use noteSplashData.shader.colorSwap.hue instead")
	public var noteSplashHue(get, set):Float;
	@:deprecated("use noteSplashData.shader.colorSwap.saturation instead")
	public var noteSplashSat(get, set):Float;
	@:deprecated("use noteSplashData.shader.colorSwap.brightness instead")
	public var noteSplashBrt(get, set):Float;
	//single
	@:deprecated("use noteSplashData.shader.singleColor.r instead")
	public var noteSplashSingleR(get, set):Float;
	@:deprecated("use noteSplashData.shader.singleColor.g instead")
	public var noteSplashSingleG(get, set):Float;
	@:deprecated("use noteSplashData.shader.singleColor.b instead")
	public var noteSplashSingleB(get, set):Float;
	//invert
	@:deprecated("use noteSplashData.shader.invertColor.r instead")
	public var noteSplashInvertR(get, set):Bool;
	@:deprecated("use noteSplashData.shader.invertColor.g instead")
	public var noteSplashInvertG(get, set):Bool;
	@:deprecated("use noteSplashData.shader.invertColor.b instead")
	public var noteSplashInvertB(get, set):Bool;
	//colorRGBSwap
	@:deprecated("use noteSplashData.shader.rgbSwap.r instead")
	public var noteSplashRGBSwapR(get, set):Int;
	@:deprecated("use noteSplashData.shader.rgbSwap.g instead")
	public var noteSplashRGBSwapG(get, set):Int;
	@:deprecated("use noteSplashData.shader.rgbSwap.b instead")
	public var noteSplashRGBSwapB(get, set):Int;
	//pixel
	@:deprecated("use noteSplashData.shader.pixel.size instead")
	public var noteSplashPixelSize(get, set):Float;
	//posterize
	@:deprecated("use noteSplashData.shader.posterize.range instead")
	public var noteSplashPosterizeRange(get, set):Float;
	//rgb palette
	@:deprecated("use noteSplashData.shader.rgbPalette.r instead")
	public var noteSplashR(get, set):Int;
	@:deprecated("use noteSplashData.shader.rgbPalette.g instead")
	public var noteSplashG(get, set):Int;
	@:deprecated("use noteSplashData.shader.rgbPalette.b instead")
	public var noteSplashB(get, set):Int;
	//grayscale
	@:deprecated("use noteSplashData.shader.grayscale.mult instead")
	public var noteSplashGrayscaleMult(get, set):Float;
	//black and white
	@:deprecated("use noteSplashData.shader.BAndW.mult instead")
	public var noteSplashBAndWMult(get, set):Float;
	@:deprecated("use noteSplashData.shader.BAndW.threshold instead")
	public var noteSplashBAndWThreshold(get, set):Float;

	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var offsetAngle:Float = 0;
	public var multAlpha:Float = 1;
	public var multSpeed(default, set):Float = 1;

	public var copyX:Bool = true;
	public var copyY:Bool = true;
	public var copyAngle:Bool = true;
	public var copyAlpha:Bool = true;

	public var hitHealth:Float = 0.023;
	public var missHealth:Float = 0.0475;
	public var rating:String = 'unknown';
	public var ratingMod:Float = 0; // 9 = unknown, 0.25 = shit, 0.5 = bad, 0.75 = good, 1 = sick
	public var ratingDisabled:Bool = false;

	public var texture(default, set):String = null;

	public var noAnimation:Bool = false;
	public var noMissAnimation:Bool = false;
	public var hitCausesMiss:Bool = false;
	public var distance:Float = 2000; // plan on doing scroll directions soon -bb

	public var hitsoundDisabled:Bool = false;
	//end of psych core

	//dge core
	public var autoPress:Bool = false; // auto press like cpuControlled behavior but specific notes(cant be pressed by player)
	public var direction:Float = 0;
	@:deprecated("use noteSplashData.camera instead")
	public var noteSplashCam(get, set):String;//notesplash on specific cam(if want the this 'note' use 'setObjectCamera()' in lua)
	@:deprecated("use noteSplashData.scale instead")
	public var noteSplashScale(get, set):Float;
	@:deprecated("use noteSplashData.scrollFactor instead")
	public var noteSplashScrollFactor(get, set):Array<Float>;//dont ask why 1 cuz is default of note splash(if want the this 'note' use 'setScrollFactor()' in lua)
	public var offsetStrumTime:Float = 0;
	public var fakeNoHit:Bool = false;//DISABLED!
	public var ignoreTextureChange:Bool = false;//for prevent change when use changeNotesTexture() lua
	//strum hit anim
	public var playStrumAnim:Bool = true; // play strums anim when hit this notes
	public var animConfirm:String = '';//static, confirm, notes, pressed
	//end of strum anim when hit
	//custom field
	public var customField:Bool = false;//info this become unused
	public var fieldTarget:String = '';//warning if not exist it might set 'customField' to false(hopefully)
	public var isCustomField(get, never):Bool;//return `true` if `targetField` is not empty or null string or else will `false`
	//end of custom field
	//sustain thing
	public var sustainTail:Bool = false;
	public var alignSustainNote(default, set):String = 'center';//'center', 'left', 'right'. only for main notes. not effect for long/sustain notes.
	//end sustain thing
	//hitsound
	public var hitsound(default, set):String = null;//custom hitsound per note
	public var forceHitsound:Bool = false;//force play hitsound even hitsound disabled in settings
	public var forceNoteSplash:Bool = false;//force note splash even note splash disabled in settings
	//end of hitsound
	//scroll stuff
	public var flipScroll(default, set):Bool = false;//flip between scroll
	public var downScroll(default, set):Null<Bool> = null;
	//end of scroll stuff
	//idea from GD
	//jack note gimmick lol
	public var multiPress:Int = 0;//how many multi press remaining(0 = no multi press)
	public var strumTimeOffsetMultiPress:Float = 500;//how much offset for each multi press notes(lol so long name)
	//end jack note gimmick lol
	//strum attach
	public var attachStrum:Bool = true;
	public var strumNote:StrumNote = null;//current notes being attach to strum note(will null if not attach)
	//end strum attach
	//opponent rating
	public var opponentRating:Bool = false;//whether this note give rating to opponent when hit
	//end opponent rating
	//copy thing
	public var copyFlipY:Bool = false;//for auto flip when use between downscroll and upscroll
	public var copyDirection:Bool = true;//attach direction from strums
	public var copyScrollFactor:Bool = true;
	public var copyCam:Bool = true;
	public var copyScaleX:Bool = true;
	public var copyScaleY:Bool = true;
	//end copy thing
	//snap prop
	public var snapX:Float = 0;
	public var snapY:Float = 0;
	public var snapAngle:Float = 0;
	public var snapAlpha:Float = 0;
	//freeze able note
	public var canFreeze:Bool = false;//whether this note can be frozen by freeze note event(false cuz will destroy note)(the note not mean to be pressed just for visual). will trigger from lua 'freezeNote()'
	//end snap prop
	public var mechanicNote:Bool = false;//whether this note is a mechanic note(only for lua or check)(recommend use json for change this)
	public var secondOpponent:Bool = false;//similar when enable gfNote in 2nd opponent mode but not apply as gf type.(only afffected if 2nd mode active)(idea from:https://youtu.be/QmXwPl3bzwk)
	public var resetTimeStrumAnim:Float = 0;//override 'resetTime' of strum(0 or under will disable override)
	public var topLayer:Bool = false;//very top layer notes
	public var noteSplash:NoteSplash = null;//it only for after spawn note splash when hit.(more likely get note splash for change the note splash properties after spawn it)
	@:deprecated("use noteSplashData.offset.x instead")
	public var noteSplashOffsetX(get, set):Float;//note splash x offset
	@:deprecated("use noteSplashData.offset.y instead")
	public var noteSplashOffsetY(get, set):Float;//note splash y offset
	@:deprecated("use noteSplashData.offsetOrigin.x instead")
	public var noteSplashOffsetOriginX(get, set):Float;//note splash x origin offset
	@:deprecated("use noteSplashData.offsetOrigin.y instead")
	public var noteSplashOffsetOriginY(get, set):Float;//note splash y origin offset
	@:deprecated("use noteSplashData.copyAlpha instead")
	public var noteSplashCopyAlpha(get, set):Bool;
	public var stickyNoteSplash:Bool = ClientPrefs.stickyNoteSplash;//make note splash always sticky at strum
	//hold cover implement(hope this work)
	public var holdCover(default, set):HoldCover = null;//this only for get current hold cover after hold cover spr spawn
	@:deprecated("use holdCoverData.disabled instead")
	public var holdCoverDisabled(get, set):Bool;
	@:deprecated("use holdCoverData.texture instead")
	public var holdCoverTexture(get, set):String;
	@:deprecated("use holdCoverData.alpha instead")
	public var holdCoverAlpha(get, set):Float;
	@:deprecated("use holdCoverData.copyAlpha instead")
	public var holdCoverCopyAlpha(default, set):Bool;
	@:deprecated("use holdCoverData.camera instead")
	public var holdCoverCam(get, set):String;//hold cover on specific cam(if want the this 'note' use 'setObjectCamera()' in lua)
	@:deprecated("use holdCoverData.scrollFactor instead")
	public var holdCoverScrollFactor(get, set):Array<Float>;//(if want the this 'note' use 'setScrollFactor()' in lua)
	@:deprecated("use holdCoverData.scale instead")
	public var holdCoverScale(get, set):Float;
	@:deprecated("use holdCoverData.offset.x instead")
	public var holdCoverOffsetX(get, set):Float;
	@:deprecated("use holdCoverData.offset.y instead")
	public var holdCoverOffsetY(get, set):Float;
	public var holdCoverDelaySplash:Float = 0.0;
	//other shader thing
	@:deprecated("use holdCoverData.shaderType instead")
	public var holdCoverShaderType(get, set):String;
	//swap
	@:deprecated("use holdCoverData.shader.colorSwap.hue instead")
	public var holdCoverHue(get, set):Float;
	@:deprecated("use holdCoverData.shader.colorSwap.brightness instead")
	public var holdCoverBrt(get, set):Float;
	@:deprecated("use holdCoverData.shader.colorSwap.saturation instead")
	public var holdCoverSat(get, set):Float;
	//single
	@:deprecated("use holdCoverData.shader.singleColor.r instead")
	public var holdCoverSingleR(get, set):Float;
	@:deprecated("use holdCoverData.shader.singleColor.g instead")
	public var holdCoverSingleG(get, set):Float;
	@:deprecated("use holdCoverData.shader.singleColor.b instead")
	public var holdCoverSingleB(get, set):Float;
	//invert
	@:deprecated("use holdCoverData.shader.invertColor.r instead")
	public var holdCoverInvertR(get, set):Bool;
	@:deprecated("use holdCoverData.shader.invertColor.g instead")
	public var holdCoverInvertG(get, set):Bool;
	@:deprecated("use holdCoverData.shader.invertColor.b instead")
	public var holdCoverInvertB(get, set):Bool;
	//colorRGBSwap
	@:deprecated("use holdCoverData.shader.rgbSwap.r instead")
	public var holdCoverRGBSwapR(get, set):Int;
	@:deprecated("use holdCoverData.shader.rgbSwap.g instead")
	public var holdCoverRGBSwapG(get, set):Int;
	@:deprecated("use holdCoverData.shader.rgbSwap.b instead")
	public var holdCoverRGBSwapB(get, set):Int;
	//pixel
	@:deprecated("use holdCoverData.shader.pixel.size instead")
	public var holdCoverPixelSize(get, set):Float;
	//posterize
	@:deprecated("use holdCoverData.shader.posterize.range instead")
	public var holdCoverPosterizeRange(get, set):Float;
	//rgb palette
	@:deprecated("use holdCoverData.shader.rgbPalette.r instead")
	public var holdCoverR(get, set):Int;
	@:deprecated("use holdCoverData.shader.rgbPalette.g instead")
	public var holdCoverG(get, set):Int;
	@:deprecated("use holdCoverData.shader.rgbPalette.b instead")
	public var holdCoverB(get, set):Int;
	//grayscale
	@:deprecated("use holdCoverData.shader.grayscale.mult instead")
	public var holdCoverGrayscaleMult(get, set):Float;
	//black and white
	@:deprecated("use holdCoverData.shader.BAndW.mult instead")
	public var holdCoverBAndWMult(get, set):Float;
	@:deprecated("use holdCoverData.shader.BAndW.threshold instead")
	public var holdCoverBAndWThreshold(get, set):Float;
	//distance update
	public var updateDistance:Bool = true;//whether update distance for note(only for visual, not affect hit time)
	//fake strum(more likely strum land  override hehe)
	//not anything because kinda odd to put it XD
	public var fakeStrumX:Null<Float> = null;//override strum attach x to 'this' position x
	public var fakeStrumY:Null<Float> = null;//override strum attach y to 'this' position y
	public var fakeStrumAngle:Null<Float> = null;//override strum attach angle to 'this' angle
	public var fakeStrumAlpha:Null<Float> = null;//override strum attach alpha to 'this' alpha
	public var fakeStrumDirection:Null<Float> = null;//override strum attach direction to 'this' direction
	public var fakeStrumDownScroll:Null<Bool> = null;//override strum attach downScroll to 'this' downScroll
	//distance more detail
	//idk why i set default to 2000 but it didt affected that much
	public var distanceX:Float = 2000;
	public var distanceY:Float = 2000;
	//shifter(inspired from CN Takeover and Vs Omega V2 mods)
	public var shifterStrength:Float = 0;//how much strength shifter mult(0=disable, more big value more big value for 'shifterEndDistance' and more lower value to 'shifterRangeMove')
	public var startPosShifter:String = '';//start pos shifter(for customStrums)
	public var shifterX:Bool = true;////should x strum will shifter
	public var shifterY:Bool = true;////should y strums will shifter
	public var shifterAngle:Bool = true;////should angle will shifter
	public var shifterDirection:Bool = true;////should direction will shifter
	public var shifterAlpha:Bool = true;////should alpha will shifter
	public var shifterDownScroll:Bool = true;//should downScroll/upScroll will shifter
	public var shifterFlipY:Bool = true;//should flipY will shifter?
	public var shifterScale:Bool = true;//should scale wil shifter?
	public var shifterEase:String = 'quadInOut';//ease tween type for shifter(same like tweeen in lua)
	public var shifterEndDistance:Float = 40; //how much distance shifter end before touching strums(more big value more range before hit strum)
	public var shiferRangeMove:Float=1;//how much movement speed shifter do(more big value more slower it get and more wider)
	public var comboTexture(default, set):String = null;//overwrite combo texture
	public var numTexture(default, set):String = null;//overwrite combo number texture
	public var downScrollOffset:Float = 0;//offset Y for Downscroll animation
	//data holdCover and Note Splash
	public var noteSplashData(default, set):ExternalSpriteData = {
		shader: {
			colorSwap: {
				hue: 0,
				saturation: 0,
				brightness: 0
			},
			singleColor: {
				r: 1,
				g: 1,
				b: 1
			},
			invertColor: {
				r: true,
				g: true,
				b: true
			},
			rgbSwap: {
				r: 0,
				g: 1,
				b: 2
			},
			pixel: {
				size: 0
			},
			posterize: {
				range: 0
			},
			rgbPalette: {
				r: 0xFFFF0000,
				g: 0xFF00FF00,
				b: 0xFF0000FF
			},
			grayscale: {
				mult: 1
			},
			BAndW: {
				mult: 1,
				threshold: 0.5
			}
		},
		shaderType: 'swap',
		texture: '',
		angle: 0,
		alpha: ClientPrefs.noteSplashAlpha,
		camera: '',
		scale: 1,
		scrollFactor: {x: 1, y: 1},
		offset: {x: 0, y: 0},
		offsetOrigin: {x: 0, y: 0},
		copyAlpha: true,
		disabled: false
	};
	public var holdCoverData(default, set):ExternalSpriteData = {
		shader: {
			colorSwap: {
				hue: 0,
				saturation: 0,
				brightness: 0
			},
			singleColor: {
				r: 1,
				g: 1,
				b: 1
			},
			invertColor: {
				r: true,
				g: true,
				b: true
			},
			rgbSwap: {
				r: 0,
				g: 1,
				b: 2
			},
			pixel: {
				size: 0
			},
			posterize: {
				range: 0
			},
			rgbPalette: {
				r: 0xFFFF0000,
				g: 0xFF00FF00,
				b: 0xFF0000FF
			},
			grayscale: {
				mult: 1
			},
			BAndW: {
				mult: 1,
				threshold: 0.5
			}
		},
		shaderType: 'swap',
		texture: '',
		angle: 0,
		alpha: ClientPrefs.holdCoverAlpha,
		camera: '',
		scale: 1,
		scrollFactor: {x: 1, y: 1},
		offset: {x: 0, y: 0},
		offsetOrigin: {x: 0, y: 0},
		copyAlpha: true,
		disabled: false
	};
	//end dge core

	@:noCompletion
	override public function set_y(value:Float):Float {
		if (!inEditor && snapY > 0) {
			var dist = value - y;
			var snapped = Math.round(dist / snapY) * snapY;
			return super.set_y(y+snapped);
		}
		return super.set_y(value);
	}

	@:noCompletion
	override public function set_x(value:Float):Float {
		if (!inEditor && snapX > 0) {
			var dist = value - x;
			var snapped = Math.round(dist / snapX) * snapX;
			return super.set_x(x+snapped);
		}
		return super.set_x(value);
	}

	@:noCompletion
	override public function set_angle(value:Float):Float {
		if (!inEditor && snapAngle > 0) {
			var dist = value - angle;
			var snapped = Math.round(dist / snapAngle) * snapAngle;
			return super.set_angle(angle+snapped);
		}
		return super.set_angle(value);
	}

	@:noCompletion
	override public function set_alpha(value:Float):Float {
		if (!inEditor && snapAlpha > 0) {
			var dist = value - alpha;
			var snapped = Math.round(dist / snapAlpha) * snapAlpha;
			return super.set_alpha(alpha+snapped);
		}
		return super.set_alpha(value);
	}

	private function set_multSpeed(value:Float):Float
	{
		var reload:Bool = false;
		resizeByRatio(value / multSpeed);
		if (((multSpeed < 0 && value >= 0) || (multSpeed >= 0 || value < 0)) && downScroll == null) {
			reload = true;
		}
		multSpeed = value;
		if (reload) reloadAnim();
		// trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) // haha funny twitter shit
	{
		if (isSustainNote && !(animation.curAnim.name.endsWith('end') || animation.curAnim.name.endsWith('end_down')))
		{
			if (scale.y == 0) {
				scale.y += ratio;
			} else {
				scale.y *= (ratio);
			}
			updateHitbox();
		}
	}

	private function set_texture(value:String):String
	{
		if (texture != value)
		{
			reloadNote('', value);
		}
		texture = value;
		return value;
	}

	private function set_noteType(value:String):String
	{
		if (noteData > -1)
		{
			var getColorMania = ClientPrefs.arrowHSV[EKUtil.getCurrentMania() % ClientPrefs.arrowHSV.length];
			var colroNoteData = getColorMania[noteData % getColorMania.length];
			colorSwap.hue = colroNoteData[0] / 360;
			colorSwap.saturation = colroNoteData[1] / 100;
			colorSwap.brightness = colroNoteData[2] / 100;
		}

		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Hurt Note':
					ignoreNote = mustPress;
					texture = "HURTNOTE_assets";
					noteSplashData.texture = 'HURTnoteSplashes';
					colorSwap.hue = 0;
					colorSwap.saturation = 0;
					colorSwap.brightness = 0;
					lowPriority = true;

					if (isSustainNote)
					{
						missHealth = 0.1;
					}
					else
					{
						missHealth = 0.3;
					}
					hitCausesMiss = true;
					ignoreTextureChange = true;
				case 'Alt Animation':
					animSuffix = '-alt';
				// note tamplate
				case 'Auto Press':
					autoPress = true;
				case 'GF Sing Auto Press': // lmao 1 mod has this notes(pinkie pie note)
					autoPress = true;
					gfNote = true;
				case 'No Animation':
					noAnimation = true;
					noMissAnimation = true;
				case 'GF Sing':
					gfNote = true;
				case 'GF Sing Force Opponent':
					gfNote = true;
				case 'Flip Scroll':
					flipScroll = true;
				case 'Fake No Hit':
					fakeNoHit = true;
				case 'Snap Note':
					snapX = 50;
					snapY = 50;
					snapAngle = 20;
				case 'Snap Note X':
					snapX = 50;
					snapAngle = 20;
				case 'Snap Note Y':
					snapY = 50;
					snapAngle = 20;
				case 'Multi Press':
					multiPress = 2;//so it click 3 times
				case 'Down Scroll': 
					downScroll = true;
				case 'Up Scroll':
					downScroll = false;
				case 'Freeze Note'://can only trigger by event or lua
					canFreeze = true;
				case 'Second Opponent'://only work if 2nd opponent mode is active
					secondOpponent = true;
				case 'Shifter':
					shifterStrength = 1;
			}
			noteType = value;
		}
		noteSplashData.shader.colorSwap.hue = colorSwap.hue;
		noteSplashData.shader.colorSwap.saturation = colorSwap.saturation;
		noteSplashData.shader.colorSwap.brightness = colorSwap.brightness;
		holdCoverData.shader.colorSwap.hue = colorSwap.hue;
		holdCoverData.shader.colorSwap.saturation = colorSwap.saturation;
		holdCoverData.shader.colorSwap.brightness = colorSwap.brightness;
		runConfig(value);
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, mustPress:Bool = false, gfSec:Bool = false, noteType:String = '', tail:Bool = false, ?parent:Note = null)
	{
		super();
		if (parent != null) {
			this.parent = parent;
		}
		sustainTail = tail;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;
		this.inEditor = inEditor;
		
		x += (ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X) + 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;
		if (!inEditor)
			this.strumTime += ClientPrefs.noteOffset;
		
		
		texture = '';
		this.noteData = noteData;
		shader = colorSwap.shader;
		
		x += swagWidth * (noteData);
		if (!isSustainNote) //i think still need this to prevent crash(idk why)
			{ // Doing this 'if' check to fix the warnings on Senpai songs
			var animToPlay:String = '';
			var mania = EKUtil.getCurrentMania();
			var indexTarget = EKUtil.noteAnimIndex[mania-1];
			animToPlay = EKUtil.colArray[indexTarget[noteData % indexTarget.length] % EKUtil.colArray.length];
			var animName = animationDownScrollHandle(animToPlay + 'Scroll');
			animation.play(animName);
		}

		// trace(prevNote);

		if (prevNote != null)
			prevNote.nextNote = this;

		if (isSustainNote)
		{
			multAlpha = (inEditor ? 1 : ClientPrefs.longNoteAlpha);
			alpha = ClientPrefs.longNoteAlpha;
			hitsoundDisabled = true;

			copyAngle = false;
			copyScaleY = false;
			copyFlipY = true;
			var mania = EKUtil.getCurrentMania();
			var indexTarget = EKUtil.noteAnimIndex[mania-1];
			var animToPlay = EKUtil.colArray[indexTarget[noteData % indexTarget.length] % EKUtil.colArray.length];
			var animName = animationDownScrollHandle(animToPlay + (tail ? 'holdend' : 'hold'));
			animation.play(animName);

			updateHitbox();


			if (!tail) {
				scale.y *= (Conductor.stepCrochet / 100 * 1.05);
				if (PlayState.instance != null)
				{
					scale.y *= Math.abs(PlayState.instance.songSpeed);
				}
				if (PlayState.isPixelStage)
				{
					scale.y *= 1.19;
					scale.y *= (6 / height); // Auto adjust note size
				}
				updateHitbox();
			}

			if (PlayState.isPixelStage)
			{
				scale.y *= PlayState.daPixelZoom;
				updateHitbox();
			}
		}
		else if (!isSustainNote)
		{
			earlyHitMult = 1;
		}
		hitsound = 'hitsound';
		this.mustPress = mustPress;
		this.gfNote = gfSec;
		this.noteType = noteType;
		//sorry
		//runConfig(noteType);
	}
	
	var lastNoteScaleToo:Float = 1;

	public var originalHeightForCalcs:Float = 6;

	function reloadNote(?prefix:String = '', ?texture:String = '', ?suffix:String = '')
	{
		if (prefix == null)
			prefix = '';
		if (texture == null)
			texture = '';
		if (suffix == null)
			suffix = '';

		var skin:String = texture;
		var skinOG:String = PlayState.SONG.arrowSkin;
		var skinOpt:String = PlayState.SONG.arrowSkinOpt;
		var skinSec:String = PlayState.SONG.arrowSkinSec;
		if (texture == null || texture.length < 1)
		{
			if (mustPress) {
				skin = skinOG;
			} else {
				if (gfNote) {
					if (skinSec == null || skinSec.length < 1) {
						if (skinOpt == null || skinOpt.length < 1) {
							skin = skinOG;
						} else {
							skin = skinOpt;
						}
					} else {
						skin = skinSec;
					}
				} else {
					//no gf
					if (skinOpt == null || skinOpt.length < 1) {
						skin = skinOG;
					} else {
						skin = skinOpt;
					}
				}
			}
			if (skin == null || skin.length < 1)
			{
				skin = ClientPrefs.dflnoteskin;
			}
		}

		var animName:String = null;
		if (animation.curAnim != null)
		{
			animName = animation.curAnim.name;
		}

		var arraySkin:Array<String> = skin.split('/');
		arraySkin[arraySkin.length - 1] = prefix + arraySkin[arraySkin.length - 1] + suffix;

		var lastScaleY:Float = scale.y;
		var blahblah:String = arraySkin.join('/');
		var keyCount = EKUtil.colArray.length;
		if (PlayState.isPixelStage)
		{
			if (isSustainNote)
				{
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / keyCount;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			}
			else
			{
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / keyCount;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int((width * PlayState.daPixelZoom * ClientPrefs.strumsize)*EKUtil.getNoteScale(EKUtil.getCurrentMania())));
			loadPixelNoteAnims();
			antialiasing = false;

		}
		else
		{
			var fr = Paths.getSparrowAtlas(blahblah);
			var defaultSkin = Paths.getSparrowAtlas(ClientPrefs.dflnoteskin);
			if (fr != null) {
				frames = fr;
			} else if (defaultSkin != null) {
				frames = defaultSkin;
			} else {
				frames = Paths.getSparrowAtlas('NOTE_assets');
			}
			loadNoteAnims();
			setGraphicSize(Std.int(((width*0.7) * ClientPrefs.strumsize)*EKUtil.getNoteScale(EKUtil.getCurrentMania())));
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if (isSustainNote)
		{
			scale.y = lastScaleY;
		}
		if (animName != null)
			animation.play(animationDownScrollHandle(animName), true);
		
		updateHitbox();

		
		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
	}

	function loadNoteAnims()
	{
		var specialAnim = CoolUtil.addSpecialAnimation;
		for (i in 0...EKUtil.colArray.length) {//i just want it adaptive to when change noteData
			var colorDef = EKUtil.defaultCol.toLowerCase();
			specialAnim(this, EKUtil.colArray[i] + 'Scroll', EKUtil.colArray[i] + '0', colorDef + '0');
			specialAnim(this, 'purpleholdend', 'pruple end hold0', colorDef + ' hold end0'); // ?????
			specialAnim(this, EKUtil.colArray[i] + 'holdend', EKUtil.colArray[i] + ' hold end0', colorDef + ' hold end0');
			specialAnim(this, EKUtil.colArray[i] + 'hold', EKUtil.colArray[i] + ' hold piece0', colorDef + ' hold piece0');
			specialAnim(this, EKUtil.colArray[i] + 'Scroll_down', EKUtil.colArray[i] + '_DownScroll0', colorDef + '_DownScroll0');
			specialAnim(this, 'purpleholdend_down', 'pruple end hold_DownScroll0', colorDef + ' hold end_DownScroll0'); // ?????
			specialAnim(this, EKUtil.colArray[i] + 'holdend_down', EKUtil.colArray[i] + ' hold end_DownScroll0', colorDef + ' hold end_DownScroll0');
			specialAnim(this, EKUtil.colArray[i] + 'hold_down', EKUtil.colArray[i] + ' hold piece_DownScroll0', colorDef + ' hold piece_DownScroll0');
		}

	}

	function loadPixelNoteAnims()
	{
		var keyCount = EKUtil.colArray.length;
		for (i in 0...keyCount) {//i just want it adaptive to when change noteData
			animation.add(EKUtil.colArray[i] + 'Scroll', [i + keyCount]);
			animation.add(EKUtil.colArray[i] + 'holdend', [i + keyCount]);
			animation.add(EKUtil.colArray[i] + 'hold', [i]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!inEditor) {
			if ((strumTime + offsetStrumTime) > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
				&& (strumTime + offsetStrumTime) < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
				canBeHit = true;
			else
				canBeHit = false;
			
			if ((strumTime + offsetStrumTime) < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit) tooLate = true;
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	function set_flipScroll(value:Bool):Bool {
		if (flipScroll != value) {
			if (isSustainNote) {
				flipY = !flipY;
			}
			if (downScroll == null) reloadAnim();
		}
		flipScroll = value;
		return value;
	}

	function set_gfNote(value:Bool):Bool {//BETTER SYSTEM!
		if (gfNote != value) {
			gfNote = value;
			reloadNoteSkin();
		}
		return value;
	}
	private function runConfig(value:String = '') {
		#if (MODS_ALLOWED && sys)
		//also affected if change note in midgame
		loadAndSetConfig(value);
		#end
	}
	//bruh useless
	function updateSusNoteoffset() {
		if (isSustainNote && parent != null) {
			x = (parent.width/2)-(width/2);//center the long notes from parent
		}
	}

	private function set_alignSustainNote(value:String):String {
		var shouldUse:Array<String> = [ 'center', 'left', 'right' ];//please lower case
		if (alignSustainNote != value) {
			if (value == null) {
				value = 'center';
			}
			value = value.toLowerCase();
			if (shouldUse.indexOf(value) == -1) {
				value = 'center';//prevent fallout error
			}
			alignSustainNote = value;
		}
		return value;
	}

	@:noCompletion
	override function set_clipRect(rect:FlxRect):FlxRect
	{
		clipRect = rect;

		if (frames != null)
			frame = frames.frames[animation.frameIndex];

		return rect;
	}

	function set_hitsound(value:String):String {
		if (hitsound != value) {
			if (value.length < 1 || value == null) {
				value = 'hitsound';
			}
			hitsound = value;
			Paths.sound(hitsound);//is already optimized in Paths.hx
		}
		return value;
	}

	function set_downScroll(value:Null<Bool>):Null<Bool> {
		if (downScroll != value) {
			downScroll = value;
			if (value != null) {
				flipY = value;
			}
			reloadAnim();
		}
		return value;
	}
	private function set_noteData(value:Int):Int {
		if (noteData != value) {
			noteData = value;
			//info: the color swap not work when change noteData midgame, so dont blame at me, lol
			var animToPlay:String = '';
			var mania = EKUtil.getCurrentMania();
			var indexTarget = EKUtil.noteAnimIndex[mania-1];
			animToPlay = EKUtil.colArray[indexTarget[noteData % indexTarget.length] % EKUtil.colArray.length];
			if (!isSustainNote) {
				animation.play(animationDownScrollHandle(animToPlay + 'Scroll'));
			} else {
				animation.play(animationDownScrollHandle(animToPlay + (sustainTail ? 'holdend': 'hold')));
			}
		}
		return value;
	}

	//it just reference old code to new data
	inline private function get_noteSplashTexture():String return noteSplashData.texture;

	inline private function set_noteSplashTexture(value:String):String return noteSplashData.texture = value;

	inline private function get_noteSplashShaderType():String return noteSplashData.shaderType;

	inline private function set_noteSplashShaderType(value:String):String return noteSplashData.shaderType = value;
	
	inline private function get_noteSplashAngle():Float return noteSplashData.angle;

	inline private function set_noteSplashAngle(value:Float):Float return noteSplashData.angle = value;

	inline private function get_noteSplashAlpha():Float return noteSplashData.alpha;

	inline private function set_noteSplashAlpha(value:Float):Float return noteSplashData.alpha = value;

	inline private function get_noteSplashHue():Float return noteSplashData.shader.colorSwap.hue;

	inline private function set_noteSplashHue(value:Float):Float return noteSplashData.shader.colorSwap.hue = value;

	inline private function get_noteSplashSat():Float return noteSplashData.shader.colorSwap.saturation;

	inline private function set_noteSplashSat(value:Float):Float return noteSplashData.shader.colorSwap.saturation = value;

	inline private function get_noteSplashBrt():Float return noteSplashData.shader.colorSwap.brightness;

	inline private function set_noteSplashBrt(value:Float):Float return noteSplashData.shader.colorSwap.brightness = value;

	inline private function get_noteSplashSingleR():Float return noteSplashData.shader.singleColor.r;

	inline private function set_noteSplashSingleR(value:Float):Float return noteSplashData.shader.singleColor.r = value;

	inline private function get_noteSplashSingleG():Float return noteSplashData.shader.singleColor.g;

	inline private function set_noteSplashSingleG(value:Float):Float return noteSplashData.shader.singleColor.g = value;

	inline private function get_noteSplashSingleB():Float return noteSplashData.shader.singleColor.b;

	inline private function set_noteSplashSingleB(value:Float):Float return noteSplashData.shader.singleColor.b = value;

	inline private function get_noteSplashInvertR():Bool return noteSplashData.shader.invertColor.r;

	inline private function set_noteSplashInvertR(value:Bool):Bool return noteSplashData.shader.invertColor.r = value;

	inline private function get_noteSplashInvertG():Bool return noteSplashData.shader.invertColor.g;

	inline private function set_noteSplashInvertG(value:Bool):Bool return noteSplashData.shader.invertColor.g = value;

	inline private function get_noteSplashInvertB():Bool return noteSplashData.shader.invertColor.b;

	inline private function set_noteSplashInvertB(value:Bool):Bool return noteSplashData.shader.invertColor.b = value;

	inline private function get_noteSplashRGBSwapR():Int return noteSplashData.shader.rgbSwap.r;

	inline private function set_noteSplashRGBSwapR(value:Int):Int return noteSplashData.shader.rgbSwap.r = value;

	inline private function get_noteSplashRGBSwapG():Int return noteSplashData.shader.rgbSwap.g;

	inline private function set_noteSplashRGBSwapG(value:Int):Int return noteSplashData.shader.rgbSwap.g = value;

	inline private function get_noteSplashRGBSwapB():Int return noteSplashData.shader.rgbSwap.b;

	inline private function set_noteSplashRGBSwapB(value:Int):Int return noteSplashData.shader.rgbSwap.b = value;

	inline private function get_noteSplashPixelSize():Float return noteSplashData.shader.pixel.size;	

	inline private function set_noteSplashPixelSize(value:Float):Float return noteSplashData.shader.pixel.size = value;

	inline private function get_noteSplashPosterizeRange():Float return noteSplashData.shader.posterize.range;

	inline private function set_noteSplashPosterizeRange(value:Float):Float return noteSplashData.shader.posterize.range = value;

	inline private function get_noteSplashR():Int return noteSplashData.shader.rgbPalette.r;

	inline private function set_noteSplashR(value:Int):Int return noteSplashData.shader.rgbPalette.r = value;

	inline private function get_noteSplashG():Int return noteSplashData.shader.rgbPalette.g;

	inline private function set_noteSplashG(value:Int):Int return noteSplashData.shader.rgbPalette.g = value;

	inline private function get_noteSplashB():Int return noteSplashData.shader.rgbPalette.b;

	inline private function set_noteSplashB(value:Int):Int return noteSplashData.shader.rgbPalette.b = value;

	inline private function get_noteSplashGrayscaleMult():Float return noteSplashData.shader.grayscale.mult;

	inline private function set_noteSplashGrayscaleMult(value:Float):Float return noteSplashData.shader.grayscale.mult = value;

	inline private function get_noteSplashBAndWMult():Float return noteSplashData.shader.BAndW.mult;

	inline private function set_noteSplashBAndWMult(value:Float):Float return noteSplashData.shader.BAndW.mult = value;

	inline private function get_noteSplashBAndWThreshold():Float return noteSplashData.shader.BAndW.threshold;

	inline private function set_noteSplashBAndWThreshold(value:Float):Float return noteSplashData.shader.BAndW.threshold = value;

	inline private function get_noteSplashCam():String return noteSplashData.camera;

	inline private function set_noteSplashCam(value:String):String return noteSplashData.camera = value;

	inline private function get_noteSplashScale():Float return noteSplashData.scale;

	inline private function set_noteSplashScale(value:Float):Float return noteSplashData.scale = value;

	inline private function get_noteSplashScrollFactor():Array<Float> return [noteSplashData.scrollFactor.x, noteSplashData.scrollFactor.y];

	inline private function set_noteSplashScrollFactor(value:Array<Float>):Array<Float> {
		if (value.length < 2) {
			if (value.length < 1) {
				value = [1, 1];
			} else {
				value = [value[0], value[0]];
			}
		}
		noteSplashData.scrollFactor.x = value[0];
		noteSplashData.scrollFactor.y = value[1];
		return value;
	}

	inline private function get_noteSplashOffsetX():Float return noteSplashData.offset.x;

	inline private function set_noteSplashOffsetX(value:Float):Float return noteSplashData.offset.x = value;

	inline private function get_noteSplashOffsetY():Float return noteSplashData.offset.y;

	inline private function set_noteSplashOffsetY(value:Float):Float return noteSplashData.offset.y = value;

	inline private function get_noteSplashOffsetOriginX():Float return noteSplashData.offsetOrigin.x;

	inline private function set_noteSplashOffsetOriginX(value:Float):Float return noteSplashData.offsetOrigin.x = value;

	inline private function get_noteSplashOffsetOriginY():Float return noteSplashData.offsetOrigin.y;

	inline private function set_noteSplashOffsetOriginY(value:Float):Float return noteSplashData.offsetOrigin.y = value;

	inline private function get_noteSplashCopyAlpha():Bool return noteSplashData.copyAlpha;

	inline private function set_noteSplashCopyAlpha(value:Bool):Bool return noteSplashData.copyAlpha = value;
	
	inline private function get_noteSplashDisabled():Bool return noteSplashData.disabled;

	inline private function set_noteSplashDisabled(value:Bool):Bool return noteSplashData.disabled = value;

	inline private function get_holdCoverTexture():String return holdCoverData.texture;

	inline private function set_holdCoverTexture(value:String):String return holdCoverData.texture = value;

	inline private function get_holdCoverAlpha():Float return holdCoverData.alpha;

	inline private function set_holdCoverAlpha(value:Float):Float return holdCoverData.alpha = value;

	inline private function get_holdCoverCopyAlpha():Bool return holdCoverData.copyAlpha;

	inline private function set_holdCoverCopyAlpha(value:Bool):Bool return holdCoverData.copyAlpha = value;

	inline private function get_holdCoverCam():String return holdCoverData.camera;

	inline private function set_holdCoverCam(value:String):String return holdCoverData.camera = value;

	inline private function get_holdCoverScrollFactor():Array<Float> return [holdCoverData.scrollFactor.x, holdCoverData.scrollFactor.y];

	inline private function set_holdCoverScrollFactor(value:Array<Float>):Array<Float> {
		if (value.length < 2) {
			if (value.length < 1) {
				value = [1, 1];
			} else {
				value = [value[0], value[0]];
			}
		}
		holdCoverData.scrollFactor.x = value[0];
		holdCoverData.scrollFactor.y = value[1];
		return value;
	}

	inline private function get_holdCoverScale():Float return holdCoverData.scale;

	inline private function set_holdCoverScale(value:Float):Float return holdCoverData.scale = value;

	inline private function get_holdCoverOffsetX():Float return holdCoverData.offset.x;

	inline private function set_holdCoverOffsetX(value:Float):Float return holdCoverData.offset.x = value;

	inline private function get_holdCoverOffsetY():Float return holdCoverData.offset.y;

	inline private function set_holdCoverOffsetY(value:Float):Float return holdCoverData.offset.y = value;

	inline private function get_holdCoverShaderType():String return holdCoverData.shaderType;

	inline private function set_holdCoverShaderType(value:String):String return holdCoverData.shaderType = value;

	inline private function get_holdCoverHue():Float return holdCoverData.shader.colorSwap.hue;

	inline private function set_holdCoverHue(value:Float):Float return holdCoverData.shader.colorSwap.hue = value;

	inline private function get_holdCoverBrt():Float return holdCoverData.shader.colorSwap.brightness;

	inline private function set_holdCoverBrt(value:Float):Float return holdCoverData.shader.colorSwap.brightness = value;

	inline private function get_holdCoverSat():Float return holdCoverData.shader.colorSwap.saturation;

	inline private function set_holdCoverSat(value:Float):Float return holdCoverData.shader.colorSwap.saturation = value;

	inline private function get_holdCoverSingleR():Float return holdCoverData.shader.singleColor.r;

	inline private function set_holdCoverSingleR(value:Float):Float return holdCoverData.shader.singleColor.r = value;

	inline private function get_holdCoverSingleG():Float return holdCoverData.shader.singleColor.g;

	inline private function set_holdCoverSingleG(value:Float):Float return holdCoverData.shader.singleColor.g = value;

	inline private function get_holdCoverSingleB():Float return holdCoverData.shader.singleColor.b;

	inline private function set_holdCoverSingleB(value:Float):Float return holdCoverData.shader.singleColor.b = value;

	inline private function get_holdCoverInvertR():Bool return holdCoverData.shader.invertColor.r;

	inline private function set_holdCoverInvertR(value:Bool):Bool return holdCoverData.shader.invertColor.r = value;

	inline private function get_holdCoverInvertG():Bool return holdCoverData.shader.invertColor.g;

	inline private function set_holdCoverInvertG(value:Bool):Bool return holdCoverData.shader.invertColor.g = value;

	inline private function get_holdCoverInvertB():Bool return holdCoverData.shader.invertColor.b;

	inline private function set_holdCoverInvertB(value:Bool):Bool return holdCoverData.shader.invertColor.b = value;

	inline private function get_holdCoverRGBSwapR():Int return holdCoverData.shader.rgbSwap.r;

	inline private function set_holdCoverRGBSwapR(value:Int):Int return holdCoverData.shader.rgbSwap.r = value;

	inline private function get_holdCoverRGBSwapG():Int return holdCoverData.shader.rgbSwap.g;

	inline private function set_holdCoverRGBSwapG(value:Int):Int return holdCoverData.shader.rgbSwap.g = value;

	inline private function get_holdCoverRGBSwapB():Int return holdCoverData.shader.rgbSwap.b;

	inline private function set_holdCoverRGBSwapB(value:Int):Int return holdCoverData.shader.rgbSwap.b = value;

	inline private function get_holdCoverPixelSize():Float return holdCoverData.shader.pixel.size;
	
	inline private function set_holdCoverPixelSize(value:Float):Float return holdCoverData.shader.pixel.size = value;

	inline private function get_holdCoverPosterizeRange():Float return holdCoverData.shader.posterize.range;

	inline private function set_holdCoverPosterizeRange(value:Float):Float return holdCoverData.shader.posterize.range = value;

	inline private function get_holdCoverR():Int return holdCoverData.shader.rgbPalette.r;

	inline private function set_holdCoverR(value:Int):Int return holdCoverData.shader.rgbPalette.r = value;

	inline private function get_holdCoverG():Int return holdCoverData.shader.rgbPalette.g;

	inline private function set_holdCoverG(value:Int):Int return holdCoverData.shader.rgbPalette.g = value;

	inline private function get_holdCoverB():Int return holdCoverData.shader.rgbPalette.b;

	inline private function set_holdCoverB(value:Int):Int return holdCoverData.shader.rgbPalette.b = value;

	inline private function get_holdCoverGrayscaleMult():Float return holdCoverData.shader.grayscale.mult;

	inline private function set_holdCoverGrayscaleMult(value:Float):Float return holdCoverData.shader.grayscale.mult = value;

	inline private function get_holdCoverBAndWMult():Float return holdCoverData.shader.BAndW.mult;

	inline private function set_holdCoverBAndWMult(value:Float):Float return holdCoverData.shader.BAndW.mult = value;

	inline private function get_holdCoverBAndWThreshold():Float return holdCoverData.shader.BAndW.threshold;

	inline private function set_holdCoverBAndWThreshold(value:Float):Float return holdCoverData.shader.BAndW.threshold = value;

	inline private function get_holdCoverDisabled():Bool return holdCoverData.disabled;

	inline private function set_holdCoverDisabled(value:Bool):Bool return holdCoverData.disabled = value;

	private function set_mustPress(value:Bool):Bool {
		if (mustPress != value) {
			mustPress = value;
			reloadNoteSkin();
		}
		return value;
	}
	public function reloadNoteSkin() {
		reloadNote('', texture);
	}
	function set_holdCover(value:HoldCover):HoldCover{
		if (holdCover != value) {
			if (holdCover != null) {
				holdCover.kill();//this not even funny when lua scripter messed up
				value = null;//nah ragebait
			}
			holdCover = value;
		}
		return value;
	}
	public function getActualDownscroll():Bool {
		//dont mind it. it just handle for existed feature hehe
		if (downScroll != null) {
			return downScroll;
		} else {
			var down = ClientPrefs.downScroll;
			if (strumNote != null) down = strumNote.downScroll;
			if (PlayState.instance != null && PlayState.instance.songSpeed < 0) down = !down;
			if (multSpeed < 0) down = !down;
			if (flipScroll) down = !down;
			return down;
		}
	}
	function loadAndSetConfig(value:String) {
		#if (MODS_ALLOWED && sys)
		if (!CacheUtil.jsonParse.exists(value)) {
			var jsonString:String = '';
			if (FileSystem.exists(Paths.modFolders('custom_notetypes/' + value + '.json'))) {
				jsonString =  File.getContent(Paths.modFolders('custom_notetypes/' + value + '.json'));
			} else if (FileSystem.exists(Paths.externalPreloadPath('custom_notetypes/' + value + '.json'))) {
				jsonString =  File.getContent(Paths.externalPreloadPath('custom_notetypes/' + value + '.json'));
			} else {
				jsonString = '';
			}
			if (jsonString.length > 0) {
				try {
					CacheUtil.jsonParse.set(value, haxe.Json.parse(jsonString));
				} catch (e:Dynamic) {
					trace('Error parsing custom_notetypes/' + value + '.json.(' + e + ')');
					CacheUtil.jsonParse.set(value, {});
				}
			} else {
				CacheUtil.jsonParse.set(value, {});
			}
		}
		//overengineer lol
		if (CacheUtil.jsonParse.exists(value) && Reflect.fields(CacheUtil.jsonParse.get(value)).length > 0) {
			var jsonVar:NoteJson = cast CacheUtil.jsonParse.get(value);
			if (jsonVar.noteData == null) {
				//classsic(it has been here long ago from v1.6.1.7)(but not advance like the new one, it just simply set the property without check anything)
				setConfig(jsonVar, value);
			} else {
				//new(note if inside field error entire json just removed due idk how to fix deleted inside field)
				//global is for all type(no matter what type is this)
				if (jsonVar.noteData.global != null) {
					if (jsonVar.noteData.global.sustain != null && isSustainNote) {
						setConfig(jsonVar.noteData.global.sustain, value);
					} else if (jsonVar.noteData.global.normal != null && !isSustainNote) {
						setConfig(jsonVar.noteData.global.normal, value);
					} else {
						setConfig(jsonVar.noteData.global, value);
					}
				}
				//is for specific type
				if (jsonVar.noteData.player != null && mustPress && !gfNote) {
					if (jsonVar.noteData.player.sustain != null && isSustainNote) {
						setConfig(jsonVar.noteData.player.sustain, value);
					} else if (jsonVar.noteData.player.normal != null && !isSustainNote) {
						setConfig(jsonVar.noteData.player.normal, value);
					} else {
						setConfig(jsonVar.noteData.player, value);
					}
				} else if (jsonVar.noteData.opponent != null && !mustPress && !gfNote) {
					if (jsonVar.noteData.opponent.sustain != null && isSustainNote) {
						setConfig(jsonVar.noteData.opponent.sustain, value);
					} else if (jsonVar.noteData.opponent.normal != null && !isSustainNote) {
						setConfig(jsonVar.noteData.opponent.normal, value);
					} else {
						setConfig(jsonVar.noteData.opponent, value);
					}
				} else if (jsonVar.noteData.gfOpponent != null && !mustPress && gfNote) {
					if (jsonVar.noteData.gfOpponent.sustain != null && isSustainNote) {
						setConfig(jsonVar.noteData.gfOpponent.sustain, value);
					} else if (jsonVar.noteData.gfOpponent.normal != null && !isSustainNote) {
						setConfig(jsonVar.noteData.gfOpponent.normal, value);
					} else {
						setConfig(jsonVar.noteData.gfOpponent, value);
					}
				} else if (jsonVar.noteData.gfPlayer != null && mustPress && gfNote) {
					if (jsonVar.noteData.gfPlayer.sustain != null && isSustainNote) {
						setConfig(jsonVar.noteData.gfPlayer.sustain, value);
					} else if (jsonVar.noteData.gfPlayer.normal != null && !isSustainNote) {
						setConfig(jsonVar.noteData.gfPlayer.normal, value);
					} else {
						setConfig(jsonVar.noteData.gfPlayer, value);
					}
				} else {
					setConfig(jsonVar.noteData, value);
				}
			}
		}
		#end
	}

	function setConfig(jsonRaw:Dynamic, name:String):Void {
		if (Reflect.fields(jsonRaw).length < 1 || name == null || name.length < 1) return;
		var koruptor = Reflect.fields(jsonRaw);
		for (tikus in koruptor) {
			if (tikus.startsWith("_")) continue;
			var beban = tikus.split('.');
			var val = Reflect.field(jsonRaw, tikus);
			if (Std.isOfType(val, Dynamic) && Type.typeof(val) == ValueType.TObject) continue;//ignore anonymous
			if (beban.length <= 1) {
				try{
					Reflect.setProperty(this, tikus, val);
				} catch (e:Dynamic) {
					trace(e);
				}
			} else {
				//get this shit from FunkinLua.hx
				try{
					var target = Reflect.getProperty(this, beban[0]);
					for (key in 1...beban.length-1) {
						target = Reflect.getProperty(target, beban[key]);
					}
					Reflect.setProperty(target, beban[beban.length-1], val);
				} catch (e:Dynamic) {
					trace(e);
					//dont repeat when is error
					CacheUtil.jsonParse.set(name, {});//idk how i remove when inside field was error so i deleted entire instead
				}
			}
		}
	}
	@:noCompletion
	override function get_cameras():Array<FlxCamera>
	{
		return _cameras;
	}

	private function animationDownScrollHandle(anim:String):String {
		if (anim == null || anim.length < 1) return '';
		if (getActualDownscroll() && !anim.endsWith('_down')) {
			if (animation != null && animation.exists(anim + '_down')) {
				return anim + '_down';
			}
		} else if (!getActualDownscroll() && anim.endsWith('_down')) {
			return anim = anim.substring(0, anim.length-5);
		}
		if (anim.endsWith('_down') && !animation.exists(anim + '_down')) anim = anim.substring(0, anim.length-5);
		return anim;
	}
	public function reloadAnim(){
		if (animation != null && animation.curAnim != null) {
			var animname:String = animationDownScrollHandle(animation.curAnim.name);
			animation.play(animname, true);
		}
	}
	private function get_isCustomField():Bool {
		return (fieldTarget != null && fieldTarget.length > 0);
	}
	private function set_comboTexture(value:String):String {
		if (value != null && value.length > 0) {
			try{
				Paths.getSparrowAtlas(value);
				comboTexture = value;
			} catch(e:Dynamic) {
				value = null;
			}
		}
		return value;
	}
	private function set_numTexture(value:String):String {
		if (value != null && value.length > 0) {
			try{
				Paths.getSparrowAtlas(value);
				numTexture = value;
			} catch(e:Dynamic) {
				value = null;
			}
		}
		return value;
	}
	private function set_noteSplashData(value:ExternalSpriteData):ExternalSpriteData {
		if (value != null) {
			noteSplashData = value;
		}
		return value;
	}
	private function set_holdCoverData(value:ExternalSpriteData):ExternalSpriteData {
		if (value != null) {
			holdCoverData = value;
		}
		return value;
	}
	private static function get_swagWidth():Float {
		return (160*0.7) * ClientPrefs.strumsize;
	}
	override function draw() {
		var origY = y;
		if (animation != null && animation.curAnim != null && animation.curAnim.name.endsWith('_down')) {
			y += downScrollOffset;
		}
		super.draw();
		y = origY;
	}
}
