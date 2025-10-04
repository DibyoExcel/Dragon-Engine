package;


import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;
import flixel.FlxSprite;
#if WINDOW_COLOR
import hxwindowmode.WindowColorMode;
#end

//crash handler stuff
#if CRASH_HANDLER
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
#if desktop
import Discord.DiscordClient;
#end
#end

#if sys
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;
#end


using StringTools;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 60; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		#if android
		if (!FileSystem.exists(StorageManager.getEngineDir())) {
			FileSystem.createDirectory(StorageManager.getEngineDir());
			Application.current.window.alert('External(' + StorageManager.getEngineDir() + ')Folder has been created. Extract app assets bundles("assets" and "mods") to' + StorageManager.getEngineDir(), 'Storage Manager');
			Sys.exit(0);
		}
		var loadData:Array<String> = ['dialogue', 'dialoguecharacter', 'menucharacter', 'weeks'];
		for (i in 0...loadData.length) {
			if (!FileSystem.exists(StorageManager.getEngineDir() + 'load/')) {
				FileSystem.createDirectory(StorageManager.getEngineDir() + 'load/');
			}
			if (!FileSystem.exists(StorageManager.getEngineDir() + 'load/' + loadData[i] + '/')) {
				FileSystem.createDirectory(StorageManager.getEngineDir() + 'load/' + loadData[i] + '/');
			}
			if (!FileSystem.exists(StorageManager.getEngineDir() + 'load/' + loadData[i] + '/')) {
				FileSystem.createDirectory(StorageManager.getEngineDir() + 'load/' + loadData[i] + '/');
			}
			if (!FileSystem.exists(StorageManager.getEngineDir() + 'load/' + loadData[i] + '/put json file here.txt')) {
				File.saveContent(StorageManager.getEngineDir() + 'load/' + loadData[i] + '/put json file here.txt', '');
			}
		}
		#end
		#if WINDOW_COLOR
		WindowColorMode.setWindowBorderColor([255, 0, 0]);
		WindowColorMode.redrawWindowHeader();
		#end
		super();

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = 1280;
		var stageHeight:Int = 720;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}
	
		ClientPrefs.loadDefaultKeys();
		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		fpsVar = new FPS(10, 3, 0x00FF00);
		addChild(fpsVar);
		if(fpsVar != null) {
			fpsVar.visible = ClientPrefs.showFPS;
		}
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		
		#if html5
		FlxG.autoPause = false;
		FlxG.mouse.visible = false;
		#else
		FlxG.autoPause = ClientPrefs.autopause;
		#end
		#if android
		FlxG.android.preventDefaultKeys = [BACK];
		#end
		
		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = StorageManager.getEngineDir() + "crash/DragonEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			 switch(stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\nPlease report this error to the GitHub page: https://github.com/DibyoExcel/Dragon-Engine\n\n> Crash Handler written by: sqirra-rng";

		if (!FileSystem.exists(StorageManager.getEngineDir() + "crash/"))
			FileSystem.createDirectory(StorageManager.getEngineDir() + "crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));

		Application.current.window.alert(errMsg, "Error!");
		#if desktop
		DiscordClient.shutdown();
		#end
		Sys.exit(1);
	}
	#end
}
