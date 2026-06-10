//littealy same as dge.obj.mobile.VirtualButton but for lua usage
//i assumed osu mechanic will exists lol
package dge.obj.lua;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
    public var texture(default, set):String = null;
    public function new(x:Float, y:Float, image:String = '', ?width:Int = 125, ?height:Int = 125)
    {
        super(x, y, '', function() {});
        this.texture = image;
        setGraphicSize(width, height);
        updateHitbox();
        antialiasing = ClientPrefs.globalAntialiasing;
    }
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (justPressed)
        {
            loadGraphic(Paths.image('button/' + texture + '-hover'));
            setGraphicSize(Std.int(width), Std.int(height));
            updateHitbox();
        }
        else if (justReleased)
        {
            loadGraphic(Paths.image('button/' + texture));
            setGraphicSize(Std.int(width), Std.int(height));
            updateHitbox();
        }
    }
    private function set_texture(value:String):String
    {
        if (texture != value)
        {
            if (value.length <= 0)
            {
                value = texture;
            }
            texture = value;
            updateGraphic();
        }
        return value;
    }
    private function updateGraphic():Void
    {
        if (pressed)
        {
            loadGraphic(Paths.image('button/' + texture + '-hover'));
        }
        else
        {
            loadGraphic(Paths.image('button/' + texture));
        }
        setGraphicSize(Std.int(width), Std.int(height));
        updateHitbox();
    }
}