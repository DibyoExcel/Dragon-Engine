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
	
	private var player:Int;
	
	public var texture(default, set):String = null;
	private function set_texture(value:String):String {
		if(texture != value) {
			texture = value;
			reloadNote();
		}
		return value;
	}

	public function new(x:Float, y:Float, leData:Int, player:Int) {
		colorSwap = new ColorSwap();
		shader = colorSwap.shader;
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);

		var skin:String = PlayState.SONG.arrowSkin;
		var skinOpt:String = PlayState.SONG.arrowSkinOpt;
		var skinSec:String = PlayState.SONG.arrowSkinSec;
		if(PlayState.SONG.arrowSkin != null && PlayState.SONG.arrowSkin.length > 0) {
			skin = PlayState.SONG.arrowSkin;
		} else {
			skin = ClientPrefs.dflnoteskin;
		}
		if(PlayState.SONG.arrowSkinOpt != null && PlayState.SONG.arrowSkinOpt.length > 0) {
			skinOpt = PlayState.SONG.arrowSkinOpt;
		} else {
			skinOpt = skin;
		}
		if(PlayState.SONG.arrowSkinSec != null && PlayState.SONG.arrowSkinSec.length > 0) {
			skinSec = PlayState.SONG.arrowSkinSec;
		} else {
			skinSec = skin;
		}
		if (player == 0) {
			if (noteData > 3) {
				texture = skinSec;
			} else {
				texture = skinOpt;
			}
		} else {
			texture = skin;
		}

		scrollFactor.set();
	}

	public function reloadNote()
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + texture));
			width = width / 4;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + texture), true, Math.floor(width), Math.floor(height));

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
					animation.add('confirm', [12, 16], ClientPrefs.fpsStrumAnim, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [5, 9], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('confirm', [13, 17], ClientPrefs.fpsStrumAnim, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [6, 10], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('confirm', [14, 18], (ClientPrefs.fpsStrumAnim)/2, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [7, 11], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('confirm', [15, 19], ClientPrefs.fpsStrumAnim, false);
			}
		}
		else
		{
			frames = Paths.getSparrowAtlas(texture);
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');

			antialiasing = ClientPrefs.globalAntialiasing;
			
			setGraphicSize(Std.int(width * ClientPrefs.strumsize));

			switch (Math.abs(noteData) % 4)
			{
				case 0:
					animation.addByPrefix('static', 'arrowLEFT');
					animation.addByPrefix('pressed', 'left press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'left confirm', ClientPrefs.fpsStrumAnim, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN');
					animation.addByPrefix('pressed', 'down press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'down confirm', ClientPrefs.fpsStrumAnim, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP');
					animation.addByPrefix('pressed', 'up press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'up confirm', ClientPrefs.fpsStrumAnim, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT');
					animation.addByPrefix('pressed', 'right press', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'right confirm', ClientPrefs.fpsStrumAnim, false);
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
		if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
			centerOrigin();
		//}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false) {
		animation.play(anim, force);
		centerOffsets();
		centerOrigin();
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

			if(animation.curAnim.name == 'confirm' && !PlayState.isPixelStage) {
				centerOrigin();
			}
		}
	}
}
