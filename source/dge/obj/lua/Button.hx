//littealy same as dge.obj.mobile.VirtualButton but for lua usage
//i assumed osu mechanic will exists lol
package dge.obj.lua;

import flixel.ui.FlxButton;

class Button extends FlxButton
{
    public var texture(default, set):String = null;
    public var sizeWidth(default, set):Int = 125;
    public var sizeHeight(default, set):Int = 125;
    public function new(x:Float, y:Float, image:String = '', ?width:Int = 125, ?height:Int = 125)
    {
        super(x, y, '', function() {});
        this.texture = image;
        sizeWidth = width;
        sizeHeight = height;
    }
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (justPressed)
        {
            loadGraphic(Paths.image('button/' + texture + '-hover'));
            setGraphicSize(sizeWidth, sizeHeight);
            updateHitbox();
        }
        else if (justReleased)
        {
            loadGraphic(Paths.image('button/' + texture));
            setGraphicSize(sizeWidth, sizeHeight);
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
    private function set_sizeWidth(value:Int):Int
    {
        if (sizeWidth != value)
        {
            sizeWidth = value;
            setGraphicSize(sizeWidth, sizeHeight);
            updateHitbox();
        }
        return sizeWidth;
    }
    private function set_sizeHeight(value:Int):Int
    {
        if (sizeHeight != value)
        {
            sizeHeight = value;
            setGraphicSize(sizeWidth, sizeHeight);
            updateHitbox();
        }
        return sizeHeight;
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
        setGraphicSize(sizeWidth, sizeHeight);
        updateHitbox();
    }
}