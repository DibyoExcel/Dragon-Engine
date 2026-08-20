package dge.frontend;

import openfl.system.System;
import openfl.display.Sprite;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import openfl.events.Event;

class BetterFPSCounter extends Sprite {
    public var currentFPS(default, null):Int;
    @:allow(dge.states.options.VisualUISubState)
    private var tf:TextField;
    private var bg:Shape;
    private var cacheCount:Int;
	private var currentTime:Float;
    private var times:Array<Float>;
    private var backgroundColor:Int = 0x000000;
    @:allow(dge.states.options.VisualUISubState)
    private var backgroundAlpha:Float = ClientPrefs.fpsBGAlpha;


    public function new(x:Float = 10, y:Float = 10, textColor:Int = 0x00FF00, bgColor:Int = 0x000000, bgAlpha:Float = 0.5) {
        super();

        this.x = x;
        this.y = y;
        backgroundColor = bgColor;
        backgroundAlpha = bgAlpha;

        currentFPS = 0;
        cacheCount = 0;
        times = [];

        // Background(Alphaable)
        bg = new Shape();
        addChild(bg);

        // Text for fps obvious
        tf = new TextField();
        tf.defaultTextFormat = new TextFormat(Paths.textFormatFont('vcr.ttf'), ClientPrefs.fpsFontSize, textColor);
        tf.selectable = false;
        tf.mouseEnabled = false;
        addChild(tf);


        //addEventListener(Event.ENTER_FRAME, update);
        #if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
    }

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
        var memoryMegas:Float = 0;
        var formatMegas:String = '';
        tf.text = "Dragon Engine";
        tf.text += "\nFPS: " + currentFPS + " | SPF: " + Math.floor((1/currentFPS)*10000)/10000;
        #if openfl
        memoryMegas = Math.abs(System.totalMemory / 1000000);
        formatMegas = (memoryMegas > 1000 ? Math.floor(memoryMegas / 10) / 100 + ' GB(' + Math.floor(memoryMegas*100)/100 + ' MB)' : Math.floor(memoryMegas*100)/100 + ' MB');
        tf.text += "\nMemory: " + formatMegas;
        #end
        var targetColor = 0xFF00FF00;
        if (memoryMegas > 3000 || currentFPS <= ClientPrefs.framerate / 4)
        {
            targetColor = 0xFFFF0000;
        } else if (memoryMegas > 1500 || currentFPS <= ClientPrefs.framerate / 2) {
            targetColor = 0xFFFFFF00;
        }
        setTextColor(targetColor);
        
        #if (gl_stats && !disable_cffi && (!html5 || !canvas))
        text += "\ntotalDC: " + Context3DStats.totalDrawCalls();
        text += "\nstageDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE);
        text += "\nstage3DDC: " + Context3DStats.contextDrawCalls(DrawCallContext.STAGE3D);
        #end
        updateBox(targetColor);
		cacheCount = currentCount;
	}

    function updateBox(outlineColor:Int) {
        var w = tf.textWidth + 10;
        var h = tf.textHeight + 6;

        tf.width = w;
        tf.height = h;

        bg.graphics.clear();
        bg.graphics.beginFill(backgroundColor, backgroundAlpha);
        bg.graphics.lineStyle(1, outlineColor);
        bg.graphics.drawRoundRect(0, 0, w, h, 15, 15);
        bg.graphics.endFill();
    }

    public function setTextColor(color:Int):Void {
        var fmt = tf.defaultTextFormat;
        fmt.color = color;
        tf.setTextFormat(fmt);
        updateBox(color);
    }
    public function setTextSize(size:Int) {
        var fmt = tf.defaultTextFormat;
        fmt.size = size;
        tf.setTextFormat(fmt);
        updateBox(fmt.color);
    }
}
