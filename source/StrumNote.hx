package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class StrumNote extends FlxSprite
{
	private var colorSwap:ColorSwap;
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	public var animConfirm:String = "confirm";//'confirm', 'static', 'pressed', 'notes'
	public var fieldName:String = '';//only use for remove object and target of 'customStrum'
	public var memberID:Int =0; //only use target 'customStrum'
	public var camTarget(default, set):String = 'hud';
	public var scrollFactorCam(default,set):Array<Float> = [0.0, 0.0];//only can see in camGame
	public var RGBPalette:RGBPalette;
	public var useRGBPalette(default, set):Bool = true;
	public var useShaderStatic(default, set):Bool = false;//using shader even strums is static animation
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if (value == null) {
			value = '';
		}
		var skin:String = PlayState.SONG.arrowSkin;
		var skinOpt:String = PlayState.SONG.arrowSkinOpt;
		var skinSec:String = PlayState.SONG.arrowSkinSec;
		if (skin == null || skin.length < 1) {
			skin = ClientPrefs.dflnoteskin;
		}
		//if opponent notes didt iput it ill use player skin/default. if sec opt not set texture it ill use opponent texture. bruh idk how to explain this
		if(skinOpt == null || skinOpt.length < 1) {
			skinOpt = skin;
		}
		if(skinSec == null || skinSec.length < 1) {
			skinSec = skinOpt;
		}
		if (value == '' || value.length < 1) {
			if (player == 1) {
				value = skin;
			} else {
				if (noteData > 3) {
					value = skinSec;
				} else {
					value = skinOpt;
				}
			}
		}
		if(texture != value) {
			texture = value;
			reloadNote(texture);
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		RGBPalette = new RGBPalette();
		if (useRGBPalette) {
			shader = RGBPalette.shader;
		} else {
			shader = colorSwap.shader;
		}
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);
		texture = '';

		scrollFactor.set(scrollFactorCam[0], scrollFactorCam[1]);
	}

	public function reloadNote(image:String = '')
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + image));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + image), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));

			animation.add('green', [6]);
			animation.add('red', [7]);
			animation.add('blue', [5]);
			animation.add('purple', [4]);
			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [4, 8], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [4]);
					animation.add('confirm', [12, 16], ClientPrefs.fpsStrumAnim, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [5]);
					animation.add('confirm', [13, 17], ClientPrefs.fpsStrumAnim, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [6]);
					animation.add('confirm', [14, 18], (ClientPrefs.fpsStrumAnim)/2, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [7]);
					animation.add('confirm', [15, 19], ClientPrefs.fpsStrumAnim, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(image);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');
			
			
			setGraphicSize(Std.int(width * ClientPrefs.strumsize));
			antialiasing = ClientPrefs.globalAntialiasing;
			

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'left confirm', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'purple0', ClientPrefs.fpsStrumAnim, false);
					case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'down confirm', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'blue0', ClientPrefs.fpsStrumAnim, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'up confirm', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'green0', ClientPrefs.fpsStrumAnim, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'right confirm', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'red0', ClientPrefs.fpsStrumAnim, false);
			}
		}
		updateHitbox();
		if (player == 0 && PlayState.SONG.secOpt) {
			scale.x *= 0.75;
			scale.y *= 0.75;
		}

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
		x += Note.swagWidth * noteData;
		x += 50;
		x += ((FlxG.width / 2) * player);
		ID = noteData;
		if (ClientPrefs.dflnoteskin == "NOTE_minecraft_assets") {
			useShaderStatic = true;
		}
	}

	override function update(elapsed:Float) {
		if(resetAnim > 0) {
			resetAnim -= elapsed;
			if(resetAnim <= 0) {
				playAnim('static');
				resetAnim = 0;
			}
		}
		//if(animation.curAnim != null){ //my bad i was upset
		if(animation.curAnim.name == animConfirm && !PlayState.isPixelStage) {
			centerOrigin();
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOrigin();
		centerOffsets();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;
			if (useRGBPalette) {
				if (!useShaderStatic) {
					shader = null;
				}
			}

		} else {
			if (useRGBPalette) {
				shader = RGBPalette.shader;
			} else {
				shader = colorSwap.shader;
			}
			if (noteData > -1)
			{
				RGBPalette.r = FlxColor.fromRGB(ClientPrefs.arrowRGB[noteData % 4][0][0], ClientPrefs.arrowRGB[noteData % 4][0][1], ClientPrefs.arrowRGB[noteData % 4][0][2]);
				RGBPalette.g = FlxColor.fromRGB(ClientPrefs.arrowRGB[noteData % 4][1][0], ClientPrefs.arrowRGB[noteData % 4][1][1], ClientPrefs.arrowRGB[noteData % 4][1][2]);
				RGBPalette.b = FlxColor.fromRGB(ClientPrefs.arrowRGB[noteData % 4][2][0], ClientPrefs.arrowRGB[noteData % 4][2][1], ClientPrefs.arrowRGB[noteData % 4][2][2]);
				colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
				colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
				colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
			}

			if(animation.curAnim.name == animConfirm && !PlayState.isPixelStage) {
				centerOrigin();
			}
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
	private function set_useRGBPalette(value:Bool):Bool {
		if (value != useRGBPalette) {
			useRGBPalette = value;
			if (value) {
				if (animation.curAnim.name != 'static') {
					shader = RGBPalette.shader;
				} else {
					shader = null;
				}
			} else {
				shader = colorSwap.shader;
			}
		}
		return value;
	}

	function set_useShaderStatic(value:Bool):Bool {
		if (value != useShaderStatic) {
			useShaderStatic = value;
			if (value) {
				if (animation.curAnim.name == 'static') {
					shader = RGBPalette.shader;
				} else {
					shader = null;
				}
			}
		}
		return value;
	}
}
