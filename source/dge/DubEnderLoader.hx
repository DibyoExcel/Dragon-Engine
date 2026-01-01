package dge;

#if WINDOW_COLOR
import hxwindowmode.WindowColorMode;
#end

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import flash.display.Shape;
import flixel.system.FlxBasePreloader;
import openfl.text.TextField;
import openfl.text.TextFormat;



#if android
import flixel.FlxG;
import lime.app.Application;
import sys.FileSystem;
import sys.io.File;
import com.player03.android6.Permissions;
#end

@:bitmap("draconisteam/icon256.png")
class LogoBitmap extends BitmapData {}


class DubEnderLoader extends FlxBasePreloader
{
	var barBG:Shape;
	var bar:Shape;
	var logo:Bitmap;
	var loadingText:TextField;

	public function new()
	{
		super(3); // Optional: minimum display time in seconds
		#if android
		if (!Permissions.hasPermission(Permissions.WRITE_EXTERNAL_STORAGE))
		{
			lime.app.Application.current.window.alert('This app required external storage permission.', 'Storage Manager');
			Permissions.requestPermission(Permissions.WRITE_EXTERNAL_STORAGE);
			lime.app.Application.current.window.alert('this required restart.', 'Storage Manager');
			Sys.exit(0);
		} 
		if (Permissions.hasPermission(Permissions.WRITE_EXTERNAL_STORAGE)) {
			if (!FileSystem.exists(StorageManager.getEngineDir())) {
				FileSystem.createDirectory(StorageManager.getEngineDir());
				Application.current.window.alert('External(' + StorageManager.getEngineDir() + ')Folder has been created. Please insert app assets bundles("assets") to' + StorageManager.getEngineDir() + '.', 'Storage Manager');
				Sys.exit(0);
			}
			var loadData:Array<String> = ['dialogue', 'dialoguecharacter', 'menucharacter', 'weeks'];
			for (i in 0...loadData.length) {
				if (!FileSystem.exists(Paths.externalFilesPath('load/'))) {
					FileSystem.createDirectory(Paths.externalFilesPath('load/'));
				}
				if (!FileSystem.exists(Paths.externalFilesPath('load/' + loadData[i] + '/'))) {
					FileSystem.createDirectory(Paths.externalFilesPath('load/' + loadData[i] + '/'));
				}
				if (!FileSystem.exists(Paths.externalFilesPath('load/' + loadData[i] + '/'))) {
					FileSystem.createDirectory(Paths.externalFilesPath('load/' + loadData[i] + '/'));
				}
				if (!FileSystem.exists(Paths.externalFilesPath('load/' + loadData[i] + '/put json file here.txt'))) {
					File.saveContent(Paths.externalFilesPath('load/' + loadData[i] + '/put json file here.txt'), '');
				}
			}
			if (!FileSystem.exists(Paths.externalFilesPath('mods/'))) {
				FileSystem.createDirectory(Paths.externalFilesPath('mods/'));
				File.saveContent(Paths.externalFilesPath('mods/put mods folder here.txt'), 'only mobile have this generated text.');
			}
			if (!FileSystem.exists(Paths.externalFilesPath('assets/'))) {
				Application.current.window.alert('Assets Folder is Missing. Please insert app assets bundles("assets") to ' + StorageManager.getEngineDir() + '. If you don\'t know press OK to open how to insert assets.', 'Storage Manager');
				FlxG.openURL('https://dibyoexcel.github.io/Dragon-Engine/mobile_tutorial/');
				Sys.exit(0);
			}
		}
		#end
		#if WINDOW_COLOR
		WindowColorMode.setWindowBorderColor([255, 0, 0]);
		WindowColorMode.redrawWindowHeader();
		#end
	}

	override public function create():Void
	{
		super.create();
		//logo
		var logoData = new LogoBitmap(0, 0);
		logo = new Bitmap(logoData); 
		var ratio = stage.stageHeight/720;
		logo.scaleX = logo.scaleY = ratio;
		logo.x = (stage.stageWidth - #if !html5 logo.width #else 256 #end) / 2; // center horizontally
		logo.y = (stage.stageHeight - #if !html5 logo.height #else 256 #end) / 2; // center vertically
		addChild(logo);

		// Loading bar
		loadingText = new TextField();
		loadingText.defaultTextFormat = new TextFormat("_sans", Std.int(#if mobile 40 #else 20*ratio #end), 0xFFFFFF, true);
		loadingText.text = "Loading...";
		loadingText.width = stage.stageWidth;
		loadingText.x = 10;
		loadingText.y = stage.stageHeight - ((40*ratio)+loadingText.textHeight);
		addChild(loadingText);
		barBG = new Shape();
		barBG.graphics.beginFill(0x202020); // grey
		barBG.graphics.drawRect(0, 0, stage.stageWidth, (20*ratio));
		barBG.graphics.endFill();
		barBG.x = 0;
		barBG.y = (stage.stageHeight - (20*ratio));
		addChild(barBG);
		bar = new Shape();
		bar.graphics.beginFill(0xff0000); // red
		bar.graphics.drawRect(0, 0, 1, (20*ratio));
		bar.graphics.endFill();
		bar.x = 0;
		bar.y = (stage.stageHeight - (20*ratio));
		addChild(bar);
		stage.addEventListener(openfl.events.Event.RESIZE, onResize);
	}

	override public function update(percent:Float):Void
	{
		super.update(percent);

		// Update loading bar width
		if (bar != null) bar.width = Std.int(percent * stage.stageWidth);

		if (loadingText != null) loadingText.text = "Loading... (" + Std.int(percent * 100) + "%)";
	}

	override public function destroy():Void
	{
		super.destroy();
		if (stage != null) stage.removeEventListener(openfl.events.Event.RESIZE, onResize);

		if (logo != null && logo.parent != null) {
			logo.parent.removeChild(logo);
		}
		if (barBG != null && barBG.parent != null) {
			barBG.parent.removeChild(barBG);
		}
		if (bar != null && bar.parent != null) {
			bar.parent.removeChild(bar);
		}
		if (loadingText != null && loadingText.parent != null) {
			loadingText.parent.removeChild(loadingText);
		}

		logo = null;
		barBG = null;
		bar = null;
		loadingText = null;
	}


	private function onResize(e:openfl.events.Event):Void {
		if (stage == null) return;
		var ratio = stage.stageHeight/720;
		if (logo != null) {
			logo.scaleX = logo.scaleY = ratio;
			logo.x = (stage.stageWidth - #if !html5 logo.width #else 256 #end) / 2;
			logo.y = (stage.stageHeight - #if !html5 logo.height #else 256 #end) / 2;
		}

		if (barBG != null) {
			barBG.graphics.clear();
			barBG.graphics.beginFill(0x202020);
			barBG.graphics.drawRect(0, 0, stage.stageWidth, (20*ratio));
			barBG.graphics.endFill();
			barBG.x = 0;
			barBG.y = stage.stageHeight - (20*ratio);
		}

		if (bar != null) {
			bar.x = 0;
			bar.y = stage.stageHeight - (20*ratio);
		}
		if (loadingText != null) {
			loadingText.defaultTextFormat = new TextFormat("_sans", Std.int(#if mobile 40 #else 20*ratio #end), 0xFFFFFF, true);
			loadingText.width = stage.stageWidth;
			loadingText.x = 10;
			loadingText.y = stage.stageHeight - ((40*ratio)+loadingText.textHeight);
		}
	}


}
