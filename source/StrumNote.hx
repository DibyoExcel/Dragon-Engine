package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxCamera;

using StringTools;

class StrumNote extends FlxSprite
{
	public var resetAnim:Float = 0;
	private var noteData:Int = 0;
	public var direction:Float = 90;//plan on doing scroll directions soon -bb
	public var downScroll:Bool = false;//plan on doing scroll directions soon -bb
	public var sustainReduce:Bool = true;
	private var player:Int;
	public var texture(default, set):String = null;
	// # region dge core
	public var animConfirm:String = 'confirm';//'confirm', 'static', 'pressed', 'notes'(mayybe could custom if use callPropertyFromGroup())
	public var fieldName:String = '';//only use for remove object and target of 'customStrum'
	public var memberID:Int =0; //only use target 'customStrum'(deprecated)
	public var gfType:Bool = false;
	public var snapX:Float = 0;
	public var snapY:Float = 0;
	public var snapAngle:Float = 0;
	public var snapAlpha:Float = 0;
	public var ignoreTextureChange:Bool = false;
	public var sustainReducePoint:Float = 0.5;//how height before sustain note cliped(0:top of strum, 1:bottom of strum)
	public var resetTime:Float = 0.2;//how time to reset to static anim(<=0 is permanent btw)
	public var classicAnim:Bool = ClientPrefs.classicAnim;//use classic anim behavior
	public var isLocked:Bool = false;//strums become unpresseable(affected dpending gamemode)(inspired retrospcter p2 chain notes)
	//fake strum stats (for custom strum, it will use these stats instead of strum stats, if not null)
	//not anything because kinda odd to put it XD
	public var fakeStrumX:Null<Float> = null;//override strum stat x to 'this' position x
	public var fakeStrumY:Null<Float> = null;//override strum stat y to 'this' position y
	public var fakeStrumAngle:Null<Float> = null;//override strum stat angle to 'this' angle
	public var fakeStrumAlpha:Null<Float> = null;//override strum stat alpha to 'this' alpha
	public var fakeStrumDirection:Null<Float> = null;//override strum stat direction to 'this' direction
	public var fakeStrumDownScroll:Null<Bool> = null;//override strum stat downScroll to 'this' downScroll
	// # endregion
	
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
		noteData = leData;
		this.player = player;
		this.noteData = leData;
		super(x, y);
		gfType = gf;
		texture = '';
		shader = colorSwap.shader;
	}

	public function reloadNote(image:String = '')
	{
		var lastAnim:String = null;
		if(animation.curAnim != null) lastAnim = animation.curAnim.name;

		reloadAnims(image);

		if(lastAnim != null)
		{
			playAnim(lastAnim, true);
		}
	}

	public function postAddedToGroup() {
		playAnim('static');
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
		if(animation != null && animation.curAnim != null){ //my bad i was upset
			if(animation.curAnim.name == animConfirm && !PlayState.isPixelStage) {
				centerOrigin();
			}
		}

		super.update(elapsed);
	}

	public function playAnim(anim:String, ?force:Bool = false, sustainNote:Bool = false, ?note:Note = null) {
		if ((note !=null ? note.getActualDownscroll() : ClientPrefs.downScroll)) anim += '_down';
		if (anim.endsWith('_down') && animation != null && animation.getByName(anim) == null) {
			anim = anim.substring(0, anim.length-5);
		}
		animation.play(anim, force);
		centerOrigin();
		centerOffsets();
		if(animation.curAnim == null || animation.curAnim.name == 'static') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

		} else {
			if (noteData > -1)
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

	function reloadAnims(image:String) {
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
			try{
				frames = Paths.getSparrowAtlas(image);
			} catch(e:Dynamic) {
				try{
					frames = Paths.getSparrowAtlas(ClientPrefs.dflnoteskin);
				} catch (e:Dynamic) {
					frames = Paths.getSparrowAtlas('NOTE_assets');
				}
			}
			animation.addByPrefix('green', 'arrowUP');
			animation.addByPrefix('blue', 'arrowDOWN');
			animation.addByPrefix('purple', 'arrowLEFT');
			animation.addByPrefix('red', 'arrowRIGHT');
			
			
			setGraphicSize(Std.int(width * ClientPrefs.strumsize));
			antialiasing = ClientPrefs.globalAntialiasing;
			

			var addAnimThingy = CoolUtil.addSpecialAnimation;
			switch (Math.abs(noteData) % 4)
			{	
				
				case 0:
					animation.addByPrefix('static', 'arrowLEFT0');
					animation.addByPrefix('pressed', 'left press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'left confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'purple0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowLEFT_DownScroll0');
					animation.addByPrefix('pressed_down', 'left press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'left confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'purple_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 1:
					animation.addByPrefix('static', 'arrowDOWN0');
					animation.addByPrefix('pressed', 'down press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'down confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'blue0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowDOWN_DownScroll0');
					animation.addByPrefix('pressed_down', 'down press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'down confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'blue_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 2:
					animation.addByPrefix('static', 'arrowUP0');
					animation.addByPrefix('pressed', 'up press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'up confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'green0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowUP_DownScroll0');
					animation.addByPrefix('pressed_down', 'up press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'up confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'green_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 3:
					animation.addByPrefix('static', 'arrowRIGHT0');
					animation.addByPrefix('pressed', 'right press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'right confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'red0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowRIGHT_DownScroll0');
					animation.addByPrefix('pressed_down', 'right press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'right confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'red_DownScroll0', ClientPrefs.fpsStrumAnim, false);
			}
		}
		updateHitbox();
	}
	@:noCompletion
	override function get_cameras():Array<FlxCamera>
	{
		return _cameras;
	}
}
