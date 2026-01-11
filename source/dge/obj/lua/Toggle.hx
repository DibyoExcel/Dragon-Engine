//extends from Button LOL
package dge.obj.lua;

class Toggle extends Button
{
    public var isOn(default, set):Bool = false;
    public function new(x:Float, y:Float, image:String = '', ?width:Int = 125, ?height:Int = 125, initialState:Bool = false)
    {
        super(x, y, image, width, height);
        isOn = initialState;
        sizeWidth = width;
        sizeHeight = height;
        updateGraphic();        
    }
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (justPressed)
        {
            //try override from Button state
            updateGraphic();
        }
        else
        if (justReleased)
        {
            isOn = !isOn;
            updateGraphic();
        }
    }
    override private function updateGraphic():Void
    {
        if (isOn)
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
    private function set_isOn(value:Bool):Bool
    {
        if (isOn != value)
        {
            isOn = value;
            updateGraphic();
        }
        return isOn;
    }
}