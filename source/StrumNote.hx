package;

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
	public var animConfirm(default, set):String = 'confirm';//'confirm', 'static', 'pressed', 'notes'
	public var fieldName:String = '';//only use for remove object and target of 'customStrum'
	public var memberID:Int =0; //only use target 'customStrum'(deprecated)
	public var camTarget(default, set):String = 'hud';
	public var scrollFactorCam(default,set):Array<Float> = [0.0, 0.0];//only can see in camGame
	private var gfType:Bool = false;
	public var snapX:Float = 0;
	public var snapY:Float = 0;
	public var snapAngle:Float = 0;
	public var snapAlpha:Float = 0;
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if (value == null) {
			value = '';
		}
		if(texture != value) {
			texture = value;
			reloadNote(texture);
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int, gf:Bool = false) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);
		gfType = gf;
		texture = '';

		scrollFactor.set(scrollFactorCam[0], scrollFactorCam[1]);
	}

	public function reloadNote(image:String = '')
	{
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
			if(skinOpt == null || skinOpt.length < 1) {
				skinOpt = skin;
			}
			skinSec = skinOpt;
		}
		if (image == '' || image.length < 1) {
			if (player == 1) {
				image = skin;
			} else {
				if (gfType) {
					image = skinSec;
				} else {
					image = skinOpt;
				}
			}
		}
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

		} else {
			if (noteData > -1 && noteData % 4 < ClientPrefs.arrowHSV.length)
			{
				colorSwap.hue = ClientPrefs.arrowHSV[noteData % 4][0] / 360;
				colorSwap.saturation = ClientPrefs.arrowHSV[noteData % 4][1] / 100;
				colorSwap.brightness = ClientPrefs.arrowHSV[noteData % 4][2] / 100;
			}

			if(animation.curAnim.name == animConfirm && !PlayState.isPixelStage) {
				centerOrigin();
			}
		}
	}
	private function set_camTarget(value:String):String {
		if (camTarget != value) {
			if (value != '') {
				var camArray:Array<String> = value.split(',');
				var realCam:Array<String> = [];
				for (i in 0...camArray.length) {
					realCam[i] = camArray[i].trim();
				}
				cameras = FunkinLua.cameraArrayFromString(realCam);
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
	private function set_animConfirm(value:String):String {
		var shouldUse:Array<String> = [ 'static', 'confirm', 'notes', 'pressed' ];//please lower case
		if (animConfirm != value) {
			if (value == null) {
				value = 'confirm';
			}
			value = value.toLowerCase();
			if (shouldUse.indexOf(value) == -1) {
				trace(value + ' is not animation name');
				value = 'confirm';//prevent fallout error
			}
			animConfirm = value;
		}
		return value;
	}

	override public function set_y(value:Float):Float {
		if (snapY > 0) {
			var dist = value - y;
			var snapped = Math.round(dist / snapY) * snapY;
			return super.set_y(y+snapped);
		}
		return super.set_y(value);
	}

	override public function set_x(value:Float):Float {
		if (snapX > 0) {
			var dist = value - x;
			var snapped = Math.round(dist / snapX) * snapX;
			return super.set_x(x+snapped);
		}
		return super.set_x(value);
	}

	override public function set_angle(value:Float):Float {
		if (snapAngle > 0) {
			var dist = value - angle;
			var snapped = Math.round(dist / snapAngle) * snapAngle;
			return super.set_angle(angle+snapped);
		}
		return super.set_angle(value);
	}

	override public function set_alpha(value:Float):Float {
		if (snapAlpha > 0) {
			var dist = value - alpha;
			var snapped = Math.round(dist / snapAlpha) * snapAlpha;
			return super.set_alpha(alpha+snapped);
		}
		return super.set_alpha(value);
	}
}
