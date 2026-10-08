package;

import flixel.FlxSprite;
import flixel.FlxCamera;

using StringTools;
import dge.backend.EKUtil;

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
		if (animation == null) return;
		if ((note !=null ? note.getActualDownscroll() : ClientPrefs.downScroll)) anim += '_down';
		if (anim.endsWith('_down') && animation.getByName(anim) == null) {
			anim = anim.substring(0, anim.length-5);
		}
		animation.play(anim, force);
		centerOrigin();
		centerOffsets();
		if(animation.curAnim == null || animation.curAnim.name == 'static' || animation.curAnim.name == 'static_down') {
			colorSwap.hue = 0;
			colorSwap.saturation = 0;
			colorSwap.brightness = 0;

		} else {
			if (noteData > -1)
			{
				var getColorMania = ClientPrefs.arrowHSV[EKUtil.getCurrentMania() % ClientPrefs.arrowHSV.length];
				var colroNoteData = getColorMania[noteData % getColorMania.length];
				colorSwap.hue = colroNoteData[0] / 360;
				colorSwap.saturation = colroNoteData[1] / 100;
				colorSwap.brightness = colroNoteData[2] / 100;
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
		var skin:String = image;
		var skinOG:String = PlayState.SONG.arrowSkin;
		var skinOpt:String = PlayState.SONG.arrowSkinOpt;
		var skinSec:String = PlayState.SONG.arrowSkinSec;
		if (skin == null || skin.length < 1) {
			if (player == 1) {
				skin = skinOG;
			} else {
				if (gfType) {
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
					if (skinOpt == null || skinOpt.length < 1) {
						skin = skinOG;
					} else {
						skin = skinOpt;
					}
				}
			}
		}
		if (skin == null || skin.length < 1) {
			skin = ClientPrefs.dflnoteskin;
		}
		image = skin;
		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + image));
			width = width / 9;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + image), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(((width * PlayState.daPixelZoom)*ClientPrefs.strumsize)*EKUtil.getNoteScale(EKUtil.getCurrentMania())));

			animation.add('green', [11]);
			animation.add('red', [12]);
			animation.add('blue', [10]);
			animation.add('purple', [9]);
			animation.add('green', [11]);
			animation.add('red', [12]);
			animation.add('blue', [10]);
			animation.add('purple', [9]);
			var mania = EKUtil.getCurrentMania();
			var indexTarget = EKUtil.noteAnimIndex[mania-1];
			var animIndex = indexTarget[noteData % indexTarget.length];
			switch (animIndex)
			{
				case 0:
					animation.add('static', [0]);
					animation.add('pressed', [9, 18], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [9]);
					animation.add('confirm', [18, 27], ClientPrefs.fpsStrumAnim, false);
				case 1:
					animation.add('static', [1]);
					animation.add('pressed', [10, 19], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [10]);
					animation.add('confirm', [19, 28], ClientPrefs.fpsStrumAnim, false);
				case 2:
					animation.add('static', [2]);
					animation.add('pressed', [11, 20], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [11]);
					animation.add('confirm', [20, 29], (ClientPrefs.fpsStrumAnim)/2, false);
				case 3:
					animation.add('static', [3]);
					animation.add('pressed', [12, 21], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [12]);
					animation.add('confirm', [21, 30], ClientPrefs.fpsStrumAnim, false);
				case 4:
					animation.add('static', [4]);
					animation.add('pressed', [13, 22], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [13]);
					animation.add('confirm', [22, 31], ClientPrefs.fpsStrumAnim, false);
				case 5:
					animation.add('static', [5]);
					animation.add('pressed', [14, 23], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [14]);
					animation.add('confirm', [23, 32], ClientPrefs.fpsStrumAnim, false);
				case 6:
					animation.add('static', [6]);
					animation.add('pressed', [15, 24], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [15]);
					animation.add('confirm', [24, 33], ClientPrefs.fpsStrumAnim, false);
				case 7:
					animation.add('static', [7]);
					animation.add('pressed', [16, 25], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [16]);
					animation.add('confirm', [25, 34], ClientPrefs.fpsStrumAnim, false);
				case 8:
					animation.add('static', [8]);
					animation.add('pressed', [17, 26], (ClientPrefs.fpsStrumAnim)/2, false);
					animation.add('notes', [17]);
					animation.add('confirm', [26, 35], ClientPrefs.fpsStrumAnim, false);
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
			animation.addByPrefix('space', 'arrowSPACE');
			animation.addByPrefix('yellow', 'arrowUPALT');
			animation.addByPrefix('altpurple', 'arrowDOWNALT');
			animation.addByPrefix('altred', 'arrowLEFTALT');
			animation.addByPrefix('altblue', 'arrowRIGHTALT');
			
			
			setGraphicSize(Std.int(((width*0.7) * ClientPrefs.strumsize)*EKUtil.getNoteScale(EKUtil.getCurrentMania())));
			antialiasing = ClientPrefs.globalAntialiasing;
			

			var addAnimThingy = CoolUtil.addSpecialAnimation;
			var mania = EKUtil.getCurrentMania();
			var indexTarget = EKUtil.noteAnimIndex[mania-1];
			var animIndex = indexTarget[noteData % indexTarget.length];
			switch (animIndex)
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
				//ek
				case 4:
					animation.addByPrefix('static', 'arrowSPACE0');
					animation.addByPrefix('pressed', 'space press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'space confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'space0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowSPACE_DownScroll0');
					animation.addByPrefix('pressed_down', 'space press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'space confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'space_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 5:
					animation.addByPrefix('static', 'arrowLEFTALT0');
					animation.addByPrefix('pressed', 'leftalt press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'leftalt confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'yellow0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowLEFTALT_DownScroll0');
					animation.addByPrefix('pressed_down', 'leftalt press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'leftalt confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'yellow_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 6:
					animation.addByPrefix('static', 'arrowDOWNALT0');
					animation.addByPrefix('pressed', 'downalt press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'downalt confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'purplealt0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowDOWNALT_DownScroll0');
					animation.addByPrefix('pressed_down', 'downalt press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'downalt confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'purplealt_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 7:
					animation.addByPrefix('static', 'arrowUPALT0');
					animation.addByPrefix('pressed', 'upalt press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'upalt confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'redalt0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowUPALT_DownScroll0');
					animation.addByPrefix('pressed_down', 'upalt press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'upalt confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'redalt_DownScroll0', ClientPrefs.fpsStrumAnim, false);
				case 8:
					animation.addByPrefix('static', 'arrowRIGHTALT0');
					animation.addByPrefix('pressed', 'rightalt press0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm', 'rightalt confirm0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes', 'bluealt0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('static_down', 'arrowRIGHTALT_DownScroll0');
					animation.addByPrefix('pressed_down', 'rightalt press_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('confirm_down', 'rightalt confirm_DownScroll0', ClientPrefs.fpsStrumAnim, false);
					animation.addByPrefix('notes_down', 'bluealt_DownScroll0', ClientPrefs.fpsStrumAnim, false);
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
