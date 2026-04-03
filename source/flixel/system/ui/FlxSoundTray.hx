package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
//import flixel.system.FlxAssets;
import flixel.util.FlxColor;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	var text:TextField = new TextField();
	@:keep
	public function new()
	{
		super();
        Paths.sound('changeVolume');//precache sound

		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0xFF000000));
		screenCenter();
		addChild(tmp);

		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat(Paths.textFormatFont('vcr.ttf'), 10, 0xff0000);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		addChild(text);
		text.text = "VOLUME";
		text.y = 16;

		var bx:Int = 10;
		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(6, 10, false, 0xff0000));
			tmp.x = bx;
			tmp.y = 5;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
		}
		alpha = 0;
		visible = false;
	}

	/**
	 * This function just updates the soundtray object.
	 */
	public function update(MS:Float):Void
	{
		// Animate stupid sound tray thing
		if (_timer > 0)
		{
			_timer -= MS / 1000;
		}
		else if (alpha > 0)
		{
			alpha -= (MS / 1000) ;

			if (alpha <= 0)
			{
				visible = false;
				active = false;
			}
		}
	}

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	Silent	Whether or not it should beep.
	 */
	public function show(Silent:Bool = false):Void
	{
		var dtf:TextFormat = new TextFormat(Paths.textFormatFont('vcr.ttf'), 10, 0xff0000);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		if (!Silent)
		{
			var sound = Paths.sound('changeVolume');//now is possible to change in mods hehe
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 1;
		alpha = 1;
		visible = true;
		active = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.25;
			}
		}
		// Save sound preferences(instant)
		FlxG.save.data.mute = FlxG.sound.muted;
		FlxG.save.data.volume = FlxG.sound.volume;
		FlxG.save.flush();
	}

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
	}
}
#end
