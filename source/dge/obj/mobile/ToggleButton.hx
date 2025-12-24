package dge.obj.mobile;

class ToggleButton extends VirtualButton//it should could nested?
{
    public var enable:Bool = false;

    public function new(x:Float = 0, y:Float = 0, image:String = '', startEnable:Bool = false) {
        super(x, y, image);
        enable = startEnable;
        if (enable) {
            loadGraphic(Paths.image('button/' + image + '-hover'));
            setGraphicSize(125, 125);
            updateHitbox();
        } else {
            loadGraphic(Paths.image('button/' + image));
            setGraphicSize(125, 125);
            updateHitbox();
        }
    }
    override public function update(e:Float) {
        super.update(e);
        if (justPressed) {
            enable = !enable;
        } else if (justReleased) {
            if (enable) {
                loadGraphic(Paths.image('button/' + image + '-hover'));
                setGraphicSize(125, 125);
                updateHitbox();
            } else {
                loadGraphic(Paths.image('button/' + image));
                setGraphicSize(125, 125);
                updateHitbox();
            }
        }
    }
}