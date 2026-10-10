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
		var mania = EKUtil.getCurrentMania();
		var indexTarget = EKUtil.noteAnimIndex[mania-1];
		var animIndex = indexTarget[noteData % indexTarget.length];
		var spriteCount = EKUtil.colArray.length;
		if(PlayState.isPixelStage)
		{
			loadGraphic(Paths.image('pixelUI/' + image));
			width = width / 9;
			height = height / 5;
			loadGraphic(Paths.image('pixelUI/' + image), true, Math.floor(width), Math.floor(height));

			antialiasing = false;
			setGraphicSize(Std.int(((width * PlayState.daPixelZoom)*ClientPrefs.strumsize)*EKUtil.getNoteScale(EKUtil.getCurrentMania())));

			for (i in 0...spriteCount) {
				animation.add(EKUtil.colArray[i], [i+spriteCount]);
			}
			animation.add('static', [animIndex]);
			animation.add('pressed', [animIndex+spriteCount, animIndex+(spriteCount*2)], (ClientPrefs.fpsStrumAnim)/2, false);
			animation.add('notes', [animIndex, spriteCount]);
			animation.add('confirm', [animIndex+(spriteCount*2), animIndex+(spriteCount*3)], ClientPrefs.fpsStrumAnim, false);
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
			var direct = EKUtil.direction;
			for (i in 0...spriteCount) {
				animation.addByPrefix(EKUtil.colArray[i], 'arrow' + direct[i%direct.length].toUpperCase());
			}
			
			
			setGraphicSize(Std.int(((width*0.7) * ClientPrefs.strumsize)*EKUtil.getNoteScale(EKUtil.getCurrentMania())));
			antialiasing = ClientPrefs.globalAntialiasing;
			

			var mania = EKUtil.getCurrentMania();
			var indexTarget = EKUtil.noteAnimIndex[mania-1];
			var animIndex = indexTarget[noteData % indexTarget.length];
			var directName = direct[animIndex % direct.length].toLowerCase();
			var xmlName = 'arrow' + directName.toUpperCase();
			var colorName = EKUtil.colArray[animIndex & EKUtil.colArray.length];
			var addAnim = CoolUtil.addSpecialAnimation;
			var defaultColor = EKUtil.defaultCol.toLowerCase();
			var defaultDirection = EKUtil.defaultDirection.toLowerCase();
			var staticXMLDef = 'arrow' + defaultDirection;
			addAnim(this, 'static', xmlName + '0',staticXMLDef + '0');
			addAnim(this, 'pressed', directName + ' press0', defaultDirection + ' press0', false, ClientPrefs.fpsStrumAnim);
			addAnim(this, 'confirm', directName + ' confirm0', defaultDirection + ' confirm0', false, ClientPrefs.fpsStrumAnim);
			addAnim(this, 'notes', colorName + '0', defaultColor + '0', true, ClientPrefs.fpsStrumAnim);
			addAnim(this, 'static_down', xmlName + '_DownScroll0', staticXMLDef + '_DownScroll0');
			addAnim(this, 'pressed_down', directName + ' press_DownScroll0', defaultDirection + ' press_DownScroll0', false, ClientPrefs.fpsStrumAnim);
			addAnim(this, 'confirm_down', directName + ' confirm_DownScroll0', defaultDirection + ' confirm_DownScroll0', false, ClientPrefs.fpsStrumAnim);
			addAnim(this, 'notes_down', colorName + '_DownScroll0', defaultColor + '_DownScroll0', true, ClientPrefs.fpsStrumAnim);
		}
		updateHitbox();
	}
	@:noCompletion
	override function get_cameras():Array<FlxCamera>
	{
		return _cameras;
	}
}
