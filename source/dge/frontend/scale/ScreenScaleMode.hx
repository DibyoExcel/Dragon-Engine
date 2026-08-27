package dge.frontend.scale;

import flixel.FlxG;
import flixel.system.scaleModes.BaseScaleMode;

class ScreenScaleMode extends BaseScaleMode
{
    public static var allowWideScreen(default, set):Bool = false;
    public static var screenWidth(default, set):Int = 960;
    public static var screenHeight(default, set):Int = 960;
    private static var resolutionListener:Array<Int->Int->Void> = [];

    public function new(W:Int = 1280, H:Int = 720) {
        screenWidth = W;
        screenHeight = H;
        super();
    }

    override function updateGameSize(Width:Int, Height:Int):Void
	{
        if(allowWideScreen)
        {
            super.updateGameSize(Width, Height);
        }
        else
        {
            var ratio:Float = FlxG.width / FlxG.height;
            var realRatio:Float = Width / Height;
    
            var scaleY:Bool = realRatio < ratio;
    
            if (scaleY)
            {
                gameSize.x = Width;
                gameSize.y = Math.floor(gameSize.x / ratio);
            }
            else
            {
                gameSize.y = Height;
                gameSize.x = Math.floor(gameSize.y * ratio);
            }
        }
	}

    override function updateGamePosition():Void
	{
        if(allowWideScreen)
		    FlxG.game.x = FlxG.game.y = 0;
        else
            super.updateGamePosition();
	}

    @:noCompletion
    private static function set_allowWideScreen(value:Bool):Bool
    {
        allowWideScreen = value;
        @:privateAccess FlxG.game.resizeGame(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
        return value;
    }

    private static function set_screenWidth(value:Int):Int {
        if (screenWidth != Std.int(Math.abs(value))) {
            screenWidth = Std.int(Math.abs(value));
            updateScreenSize();
        }
        return Std.int(Math.abs(value));
    }

    private static function set_screenHeight(value:Int):Int {
        if (screenHeight != Std.int(Math.abs(value))) {
            screenHeight = Std.int(Math.abs(value));
            updateScreenSize();
        }
        return Std.int(Math.abs(value));
    }

    private static function updateScreenSize():Void {
        @:privateAccess {
            FlxG.width = screenWidth;
            FlxG.height = screenHeight;
            FlxG.game.resizeGame(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
        }
        for (l in resolutionListener) {
            if (l == null) continue;
            l(screenWidth, screenHeight);
        }
    }

    override public function onMeasure(W:Int, H:Int):Void {
        @:privateAccess {
            FlxG.width = screenWidth;
            FlxG.height = screenHeight;
        }
        updateGameSize(W, H);
		updateDeviceSize(W, H);
		updateScaleOffset();
		updateGamePosition();
    }

    public static function addEventListener(Fn:Int->Int->Void) {
        if (resolutionListener.indexOf(Fn) == -1 && Fn != null) {
            resolutionListener.push(Fn);
        }
    }
    public static function removeEventListener(Fn:Int->Int->Void) {
        resolutionListener.remove(Fn);
    }
}