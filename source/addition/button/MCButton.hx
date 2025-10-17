//this shit nothing to do
package addition.button;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MCButton extends FlxButton
{
    private var buttonText:FlxText;
    public function new(x, y, text:String, callBack:Void->Void) {
        super(x, y, text, callBack);
        this.loadGraphic(Paths.image("MCButton/normal"));
        this.onOver.callback = function() {
            this.loadGraphic(Paths.image("MCButton/hover"));
        }
        this.onOut.callback = function() {
            this.loadGraphic(Paths.image("MCButton/normal"));
        }
        label.setFormat(null, 16, FlxColor.WHITE, "center");
        label.x = (this.width-label.width)/2;
        label.y = (this.height-label.height)/2;
    }
}