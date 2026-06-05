package dge.obj.mobile;

import dge.obj.mobile.TouchButton;

class VirtualButton extends TouchButton {
    public var texture(default, set):String = null;
    override public function new(x:Float, y:Float, image:String = '') {
        super(x, y);
        this.texture = image;
        alpha = ClientPrefs.virtualButtonAlpha;
        antialiasing = ClientPrefs.globalAntialiasing;
    }
    override private function set_justPressed(value:Bool):Bool {
        if (justPressed != value) {
            justPressed = value;
                if (value) {
                    loadGraphic(Paths.image('button/' + texture + '-hover'));
                    setGraphicSize(125, 125);
                    updateHitbox();
                }
        }
        return super.set_justPressed(value);
    }
    override private function set_justReleased(value:Bool):Bool {
        if (justReleased != value) {
            justReleased = value;
                if (value) {
                    loadGraphic(Paths.image('button/' + texture));
                    setGraphicSize(125, 125);
                    updateHitbox();
                }
        }
        return super.set_justReleased(value);
    }
    private function set_texture(value:String):String {
        if (texture != value) {
            if (value.length <= 0 || value == null) {
                value = texture;
            }
            if (pressed) {
                loadGraphic(Paths.image('button/' + value + '-hover'));
                setGraphicSize(125, 125);
                updateHitbox();
            } else {
                loadGraphic(Paths.image('button/' + value));
                setGraphicSize(125, 125);
                updateHitbox();
            }
        }
        return texture = value;
    }
}