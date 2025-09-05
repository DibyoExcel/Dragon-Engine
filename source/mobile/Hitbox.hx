package mobile;

import mobile.FlxButton;

//abused FlxButton lol
class Hitbox extends FlxButton {
    override public function new(x:Float, y:Float) {
        super(x, y);
        loadGraphic(Paths.image('hitbox'));
        alpha = ClientPrefs.hitboxAlpha;
    }
    override public function update(elapsed:Float){
        super.update(elapsed);
        if (justPressed) {
            alpha = ClientPrefs.hitboxPressAlpha;
        } else if (justReleased) {
            alpha = ClientPrefs.hitboxAlpha;
        }
    }
}