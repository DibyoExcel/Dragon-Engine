package openfl.display;

import flixel.FlxG;
import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.math.FlxMath;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
#end
import openfl.Lib;

#if openfl
import openfl.system.System;
#end


/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.framerate) currentFPS = ClientPrefs.framerate;

		if (currentCount != cacheCount /*&& visible*/)
		{
			text = "FPS: " + currentFPS + " | SPF: " + Math.floor((1/currentFPS)*10000)/10000;
			var memoryMegas:Float = 0;
			var formatMegas:String = '';
			#if openfl
			memoryMegas = Math.abs(System.totalMemory / 1000000);
			formatMegas = (memoryMegas > 1000 ? Math.floor(memoryMegas / 10) / 100 + ' GB(' + Math.floor(memoryMegas*100)/100 + ' MB)' : Math.floor(memoryMegas*100)/100 + ' MB');
			text += " | Memory: " + formatMegas;
			#end
			#if android
			text += "\nDragon Engine(Android)";
			#elseif html5
			text += "\nDragon Engine(HTML5)";
			#else
			if ((Lib.application.window.width >= Lib.application.window.display.bounds.width && Lib.application.window.height >= Lib.application.window.display.bounds.height && Lib.application.window.x == 0 && Lib.application.window.y == 0) || FlxG.fullscreen) {
				text += "\nDragon Engine";
			}
			#end
			textColor = 0xFF00FF00;
			if (memoryMegas > 3000 || currentFPS <= ClientPrefs.framerate / 2)
			{
				textColor = 0xFFFF0000;
			}

			#if (gl_stats && !disable_cffi && (!html5 || !canvas))
			text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
			text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
			text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
			#end

			text += "\n";
		}

		cacheCount = currentCount;
	}
}
