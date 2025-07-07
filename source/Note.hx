package;

import editors.ChartingState;
import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

typedef EventNote =
{
	strumTime:Float,
	event:String,
	value1:String,
	value2:String
}

class Note extends FlxSprite
{
	public var extraData:Map<String, Dynamic> = [];

	public var strumTime:Float = 0;
	public var autoPress:Bool = false; // auto press like cpuController behavior but specific notes
	public var playStrumAnim:Bool = true; // play strums anim when hit this notes
	public var mustPress:Bool = false;
	public var isDad:Bool = false; // For Player play as opponent
	public var noteData:Int = 0;
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

	public var colorSwap:ColorSwap;
	public var inEditor:Bool = false;

	public var animSuffix:String = '';
	public var gfNote(default, set):Bool = false;
	public var earlyHitMult:Float = 0.5;
	public var lateHitMult:Float = 1;
	public var lowPriority:Bool = false;

	public static var swagWidth:Float = 160 * 0.7;

	private var colArray:Array<String> = ['purple', 'blue', 'green', 'red'];
	private var pixelInt:Array<Int> = [0, 1, 2, 3];

	// Lua shit
	public var noteSplashDisabled:Bool = false;
	public var noteSplashTexture:String = null;
	public var noteSplashHue:Float = 0;
	public var noteSplashSat:Float = 0;
	public var noteSplashBrt:Float = 0;

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
	public var direction:Float = 0;
	public var flipScroll(default, set):Bool = false;//flip between scroll
	private var noteScale:Float = 1.0;
	public var customField:Bool = false;
	public var fieldTarget:String = '';//warning if not exist it might set 'customField' to false(hopefully)
	public var camTarget(default, set):String = 'hud';
	public var scrollFactorCam(default,set):Array<Float> = [0.0, 0.0];//only can see in camGame
	public var noteSplashCam:String = 'hud';//notesplash on specific cam
	public var noteSplashScale:Float = 1.0;
	public var noteSplashScrollFactor:Array<Float> = [1, 1];//dont ask why 1 cuz is default of note splash



	private function set_multSpeed(value:Float):Float
	{
		resizeByRatio(value / multSpeed);
		multSpeed = value;
		// trace('fuck cock');
		return value;
	}

	public function resizeByRatio(ratio:Float) // haha funny twitter shit
	{
		if (isSustainNote && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= (ratio);
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
		if (noteData > -1 && noteData < ClientPrefs.arrowHSV.length)
		{
			colorSwap.hue = ClientPrefs.arrowHSV[noteData & 4][0] / 360;
			colorSwap.saturation = ClientPrefs.arrowHSV[noteData & 4][1] / 100;
			colorSwap.brightness = ClientPrefs.arrowHSV[noteData & 4][2] / 100;
		}

		if (noteData > -1 && noteType != value)
		{
			switch (value)
			{
				case 'Hurt Note':
					ignoreNote = mustPress;
					texture = "HURTNOTE_assets";
					noteSplashTexture = 'HURTnoteSplashes';
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
					if (inEditor) {
						mustPress = false; 
					}
					gfNote = true;
				case 'Flip Scroll':
					flipScroll = true;
			}
			noteType = value;
		}
		noteSplashHue = colorSwap.hue;
		noteSplashSat = colorSwap.saturation;
		noteSplashBrt = colorSwap.brightness;
		return value;
	}

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inEditor:Bool = false, mustPress:Bool = false, gfSec:Bool = false, noteType:String = '')
	{
		super();

		this.mustPress = mustPress;

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
		
		this.noteData = noteData;
		
		if (noteData > -1)
			{
				var skin:String = PlayState.SONG.splashSkin;
				var skinOpt:String = PlayState.SONG.splashSkinOpt;
				var skinSec:String = PlayState.SONG.splashSkinSec;
				if (skin.length < 1 || skin == null) {
					skin = "noteSplashes";
				}
				if (skinOpt.length < 1 || skinOpt == null) {
					skinOpt = skin;
				}
				if (skinSec.length < 1 || skinSec == null) {
					if (skinOpt.length < 1 || skinOpt == null) {
						skinSec = skin;
					} else {
						skinSec = skinOpt;
					}
					skinSec = skinOpt;
				}
				var gamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
				if (PlayState.SONG.secOpt && !mustPress && !(gamemode == "bothside")) {
					noteScale = 0.75;
				}
				texture = '';
				colorSwap = new ColorSwap();
				shader = colorSwap.shader;
				var gamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
				this.gfNote = gfSec;
				this.noteType = noteType;
				if (mustPress) {
					noteSplashTexture = skin;
				} else {
					if (PlayState.SONG.secOpt && !(gamemode == "bothside")) {
						noteSplashScale = 0.75;
					}
					if (gfNote) {
						noteSplashTexture = skinSec;
					} else {
						noteSplashTexture = skinOpt;
					}
				}
			
			x += swagWidth * (noteData);
			if (!isSustainNote && noteData > -1 && noteData < 8)
				{ // Doing this 'if' check to fix the warnings on Senpai songs
				var animToPlay:String = '';
				animToPlay = colArray[noteData % 4];
				animation.play(animToPlay + 'Scroll');
			}
		}

		// trace(prevNote);

		if (prevNote != null)
			prevNote.nextNote = this;

		if (isSustainNote && prevNote != null)
		{
			multAlpha = ClientPrefs.longNoteAlpha;
			alpha = ClientPrefs.longNoteAlpha;
			hitsoundDisabled = true;

			offsetX += (width / 2);
			copyAngle = false;

			animation.play(colArray[noteData % 4] + 'holdend');

			updateHitbox();

			offsetX -= (width / 2);

			if (PlayState.isPixelStage)
				offsetX += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(colArray[prevNote.noteData % 4] + 'hold');
				prevNote.scale.y *= (Conductor.stepCrochet / 100 * 1.05);
				if (PlayState.instance != null)
				{
					prevNote.scale.y *= PlayState.instance.songSpeed;
				}

				if (PlayState.isPixelStage)
				{
					prevNote.scale.y *= 1.19;
					prevNote.scale.y *= (6 / height); // Auto adjust note size
				}
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
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
		x += offsetX;
		if (!inEditor) {
			var opponentGamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
			if (opponentGamemode == "opponent" && mustPress)
				{
					rating = "sick"; // uuuuhhhhhh
				}
		}
		if (!inEditor) {
			scrollFactor.set(scrollFactorCam[0], scrollFactorCam[1]);
		}
	}

	var lastNoteOffsetXForPixelAutoAdjusting:Float = 0;
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
		if (texture.length < 1 || texture == null)
		{
			if (mustPress) {
				skin = skinOG;
			} else {
				if (gfNote) {
					if (skinSec.length < 1 || skinSec == null) {
						if (skinOpt.length < 1 || skinOpt == null) {
							skin = skinOG;
						} else {
							skin = skinOpt;
						}
					} else {
						skin = skinSec;
					}
				} else {
					//no gf
					if (skinOpt.length < 1 || skinOpt == null) {
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
		if (PlayState.isPixelStage)
		{
			if (isSustainNote)
			{
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'));
				width = width / 4;
				height = height / 2;
				originalHeightForCalcs = height;
				loadGraphic(Paths.image('pixelUI/' + blahblah + 'ENDS'), true, Math.floor(width), Math.floor(height));
			}
			else
			{
				loadGraphic(Paths.image('pixelUI/' + blahblah));
				width = width / 4;
				height = height / 5;
				loadGraphic(Paths.image('pixelUI/' + blahblah), true, Math.floor(width), Math.floor(height));
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
			loadPixelNoteAnims();
			antialiasing = false;

			if (isSustainNote)
			{
				offsetX += lastNoteOffsetXForPixelAutoAdjusting;
				lastNoteOffsetXForPixelAutoAdjusting = (width - 7) * (PlayState.daPixelZoom / 2);
				offsetX -= lastNoteOffsetXForPixelAutoAdjusting;

				/*if(animName != null && !animName.endsWith('end'))
					{
						lastScaleY /= lastNoteScaleToo;
						lastNoteScaleToo = (6 / height);
						lastScaleY *= lastNoteScaleToo;
				}*/
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(blahblah);
			loadNoteAnims();
			setGraphicSize(Std.int(width * ClientPrefs.strumsize));
			antialiasing = ClientPrefs.globalAntialiasing;
		}
		if (isSustainNote)
		{
			scale.y = lastScaleY;
		}
		if (animName != null)
			animation.play(animName, true);
		
		updateHitbox();

		
		if (inEditor)
		{
			setGraphicSize(ChartingState.GRID_SIZE, ChartingState.GRID_SIZE);
			updateHitbox();
		}
		if (!inEditor) {
			var gamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
			if (!mustPress) {
				scale.x *= noteScale;
				if (!isSustainNote) {
					scale.y *= noteScale;
				}
			}
		}
	}

	function loadNoteAnims()
	{
		animation.addByPrefix(colArray[noteData % 4] + 'Scroll', colArray[noteData % 4] + '0');

		if (isSustainNote)
		{
			animation.addByPrefix('purpleholdend', 'pruple end hold'); // ?????
			animation.addByPrefix(colArray[noteData%4] + 'holdend', colArray[noteData%4] + ' hold end');
			animation.addByPrefix(colArray[noteData%4] + 'hold', colArray[noteData%4] + ' hold piece');
		}
	}

	function loadPixelNoteAnims()
	{
		if (isSustainNote)
		{
			animation.add(colArray[noteData % 4] + 'holdend', [pixelInt[noteData % 4] + 4]);
			animation.add(colArray[noteData % 4] + 'hold', [pixelInt[noteData % 4]]);
		}
		else
		{
			animation.add(colArray[noteData % 4] + 'Scroll', [pixelInt[noteData % 4] + 4]);
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!inEditor) {
			var gamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
			if (gamemode != null) {
				if ((gamemode != "opponent" ? (gamemode == "bothside v2" || gamemode == "bothside" ? true : mustPress) : !mustPress))
				{
					// ok river
					if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult)
						&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
						canBeHit = true;
					else
						canBeHit = false;

					if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
						tooLate = true;
				}
				else
				{
					canBeHit = false;

					if (strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult))
					{
						if ((isSustainNote && prevNote.wasGoodHit) || strumTime <= Conductor.songPosition)
							wasGoodHit = true;
					}
				}
			}
		}

		if (tooLate && !inEditor)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}

	function set_flipScroll(value:Bool):Bool {
		if (flipScroll != value) {
			if (isSustainNote && prevNote != null) {
				flipY = !flipY;
			}
		}
		flipScroll = value;
		return value;
	}

	function set_gfNote(value:Bool):Bool {//BETTER SYSTEM!
		if (gfNote != value) {
			gfNote = value;
			reloadNote('', texture);
			if (noteType != 'Hurt Note') {
				var skin:String = PlayState.SONG.splashSkin;
				var skinOpt:String = PlayState.SONG.splashSkinOpt;
				var skinSec:String = PlayState.SONG.splashSkinSec;
				if (skin.length < 1 || skin == null) {
					skin = "noteSplashes";
				}
				if (skinOpt.length < 1 || skinOpt == null) {
					skinOpt = skin;
				}
				if (skinSec.length < 1 || skinSec == null) {
					if (skinOpt.length < 1 || skinOpt == null) {
						skinSec = skin;
					} else {
						skinSec = skinOpt;
					}
					skinSec = skinOpt;
				}
				if (noteSplashTexture == null || noteSplashTexture.length < 1) {
					if (gfNote && !mustPress) {
						noteSplashTexture = skinSec;
					} else {
						noteSplashTexture = skinOpt;
					}
				}
			}
		}
		return value;
	}
	public function onChangeSecOpt(value:Bool = false) {
		if (!mustPress) {
			var gamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
			if (value) {
				if (!(gamemode == "bothside")) {
					noteScale = 0.75;
					noteSplashScale = 0.75;
				}
			} else {
				if (!(gamemode == "bothside")) {
					noteScale = 1.0;
					noteSplashScale = 1.0;
				}
			}
			reloadNote('', texture);
		}
	}

	function set_camTarget(value:String):String {
		if (camTarget != value) {
			if (value != '') {
				cameras = [FunkinLua.cameraFromString(value)];
			} else {
				cameras = null;
			}
		}
		camTarget = value;
		return value;
	}

	function set_scrollFactorCam(value:Array<Float>):Array<Float> {
		if (scrollFactorCam[0] != value[0] || scrollFactorCam[1] != value[1]) {
			scrollFactor.set(value[0], value[1]);
		}
		scrollFactorCam[0] = value[0];
		scrollFactorCam[1] = value[1];
		return value;
	}
}
