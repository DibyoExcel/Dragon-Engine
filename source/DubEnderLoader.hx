package;

import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFormat;
import flixel.system.FlxPreloader;
import openfl.text.Font;
import openfl.utils.Assets;

class DubEnderLoader extends FlxPreloader
{
	private var background:Shape;
	private var barBG:Shape;
	private var bar:Shape;

	public function new()
	{
		super(3); // Optional: minimum display time in seconds
	}

	override public function create():Void
	{
		super.create();

		// Background
		background = new Shape();
		background.graphics.beginFill(0x000000); // black
		background.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		background.graphics.endFill();
		addChild(background);

		// Loading bar
		barBG = new Shape();
		barBG.graphics.beginFill(0x202020); // grey
		barBG.graphics.drawRect(0, 0, 500, 20);
		barBG.graphics.endFill();
		barBG.x = (stage.stageWidth - 500) / 2;
		barBG.y = (stage.stageHeight - 20) / 2;
		addChild(barBG);
		bar = new Shape();
		bar.graphics.beginFill(0x7900ff); // purple
		bar.graphics.drawRect(0, 0, 1, 20);
		bar.graphics.endFill();
		bar.x = (stage.stageWidth - 500) / 2;
		bar.y = (stage.stageHeight - 20) / 2;
		addChild(bar);
		// text
		var loadingText:TextField = new TextField();
		var format:TextFormat = new TextFormat(null, 18, 0xFFFFFF);
		loadingText.defaultTextFormat = format;
		loadingText.text = "Loading...";
		loadingText.embedFonts = true;
		loadingText.x = (stage.stageWidth - loadingText.width) / 2;
		loadingText.y = bar.y - 50;
		loadingText.selectable = false;
		addChild(loadingText);
	}

	override public function update(percent:Float):Void
	{
		super.update(percent);

		// Update loading bar width
		bar.width = Std.int(percent * 500); // 200 is full width
	}

	override public function destroy():Void
	{
		super.destroy();
		removeChild(background);
		removeChild(bar);
	}
}
