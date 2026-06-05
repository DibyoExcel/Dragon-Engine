package dge.obj.mobile;

class ToggleButton extends VirtualButton//it should could nested?
{
    public var enable(default, set):Bool = false;

    public function new(x:Float = 0, y:Float = 0, image:String = '', ?startEnable:Bool = false) {
        super(x, y, image);
        enable = startEnable;
        updateGraphic();
        antialiasing = ClientPrefs.globalAntialiasing;
    }
   override private function set_justPressed(value:Bool):Bool {
        if (justPressed != value) {
            justPressed = value;
            if (value) {
                enable = !enable;
            }
            updateGraphic();
        }
        return value;
    }
    override private function set_justReleased(value:Bool):Bool {
        if (justReleased != value) {
            justReleased = value;
            updateGraphic();
        }
        return value;
    }
    override function set_texture(value:String):String {
        if (texture != value) {
            if (value != null && value.length > 0) {
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