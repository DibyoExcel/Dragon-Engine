package dge.obj.mobile;

class ToggleButton extends VirtualButton//it should could nested?
{
    public var enable(default, set):Bool = false;

    public function new(x:Float = 0, y:Float = 0, image:String = '', startEnable:Bool = false) {
        super(x, y, image);
        enable = startEnable;
        updateGraphic();
    }
    override public function update(e:Float) {
        super.update(e);
        if (justReleased) {
            enable = !enable;
            updateGraphic();
        }
    }
    override function set_texture(value:String):String {
        if (texture != value) {
            if (value.length > 0) {
                texture = value;
                updateGraphic();
            }
        }
        return value;
    }
    private function set_enable(value:Bool):Bool {
        if (enable != value) {
            enable = value;
            updateGraphic();
        }
        return value;
    }
    private function updateGraphic():Void {
        if (enable) {
            loadGraphic(Paths.image('button/' + texture + '-hover'));
        } else {
            loadGraphic(Paths.image('button/' + texture));
        }
        setGraphicSize(125, 125);
        updateHitbox();
    }
}