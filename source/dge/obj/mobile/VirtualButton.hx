package dge.obj.mobile;

import dge.obj.mobile.FlxButton;

class VirtualButton extends FlxButton {
    public var texture(default, set):String = null;
    override public function new(x:Float, y:Float, image:String = '') {
        super(x, y, '', function(){});
        this.texture = image;
        alpha = ClientPrefs.virtualButtonAlpha;
    }
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (justPressed) {
            loadGraphic(Paths.image('button/' + texture + '-hover'));
            setGraphicSize(125, 125);
            updateHitbox();
        } else if (justReleased) {
            loadGraphic(Paths.image('button/' + texture));
            setGraphicSize(125, 125);
            updateHitbox();
        }
    }
    private function set_texture(value:String):String {
        if (texture != value) {
            if (value.length <= 0) {
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