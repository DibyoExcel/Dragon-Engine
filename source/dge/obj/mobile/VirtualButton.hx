package dge.obj.mobile;

import dge.obj.mobile.FlxButton;

class VirtualButton extends FlxButton {
    private var image:String;
    override public function new(x:Float, y:Float, image:String = '') {
        super(x, y, '', function(){});
        this.image = image;
        scrollFactor.set();
        alpha = ClientPrefs.virtualButtonAlpha;
        if (image.length > 0) {
            loadGraphic(Paths.image('button/' + image));
            setGraphicSize(125, 125);
            updateHitbox();
        }
    }
    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        if (justPressed) {
            loadGraphic(Paths.image('button/' + image + '-hover'));
            setGraphicSize(125, 125);
            updateHitbox();
        } else if (justReleased) {
            loadGraphic(Paths.image('button/' + image));
            setGraphicSize(125, 125);
            updateHitbox();
        }
    }
}