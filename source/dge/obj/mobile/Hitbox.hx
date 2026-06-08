//better input but sadly cant drag between hitbox without release touch(same touch i mean)
package dge.obj.mobile;

import flixel.input.touch.FlxTouch;
import flixel.FlxSprite;
import flixel.FlxG;
import dge.obj.mobile.TouchButton;



class Hitbox extends TouchButton
{
    public var pressAlpha:Float = ClientPrefs.hitboxPressAlpha;
    public var unpressAlpha:Float = ClientPrefs.hitboxAlpha;
    public var texture(default, set):String = null;
    //extra variable
    public var snapX:Float = 0;
	public var snapY:Float = 0;
	public var snapAngle:Float = 0;
	public var snapAlpha:Float = 0;
    public var sizeWidth(default, set):Int = 0;
    public var sizeHeight(default, set):Int = 0;
    

    override private function set_justReleased(value:Bool):Bool {
        if (justReleased != value) {
            justReleased = value;
            if (value) {
                alpha = unpressAlpha;
            }
        }
        return value;
    }

    override private function set_justPressed(value:Bool):Bool {
        if (justPressed != value) {
            justPressed = value;
            if (value) {
                alpha = pressAlpha;
            }
        }
        return value;
    }

    private function set_texture(value:String):String {
        if (texture != value) {
            if (value == null || value.length < 1) {
                value = 'hitbox';
            }
            texture = value;
            var lastColor = this.color;
            loadGraphic(Paths.image(value));
            this.color = lastColor;
        }
        return value;
    }

     public function new(x:Float, y:Float) {
         super(x, y);
         texture = '';
         alpha = unpressAlpha;
         shaderType = 'swap';
         blend = FunkinLua.blendModeFromString(ClientPrefs.hitboxBlend);
         antialiasing = ClientPrefs.globalAntialiasing;
         stickyInput = ClientPrefs.stickyHitbox;
     }

     override public function set_y(value:Float):Float {
		if (snapY > 0) {
			var dist = value - y;
			var snapped = Math.round(dist / snapY) * snapY;
			return super.set_y(y+snapped);
		}
		return super.set_y(value);
	}
    
	override public function set_x(value:Float):Float {
		if (snapX > 0) {
			var dist = value - x;
			var snapped = Math.round(dist / snapX) * snapX;
			return super.set_x(x+snapped);
		}
		return super.set_x(value);
	}

	override public function set_angle(value:Float):Float {
		if (snapAngle > 0) {
			var dist = value - angle;
			var snapped = Math.round(dist / snapAngle) * snapAngle;
			return super.set_angle(angle+snapped);
		}
		return super.set_angle(value);
	}

	override public function set_alpha(value:Float):Float {
		if (snapAlpha > 0) {
			var dist = value - alpha;
			var snapped = Math.round(dist / snapAlpha) * snapAlpha;
			return super.set_alpha(alpha+snapped);
		}
		return super.set_alpha(value);
	}

    private function set_sizeWidth(value:Int):Int {
        if (sizeWidth != value) {
            sizeWidth = value;
            setGraphicSize(value, sizeHeight);
            updateHitbox();
        }
        return value;
    }

    private function set_sizeHeight(value:Int):Int {
        if (sizeHeight != value) {
            sizeHeight = value;
            setGraphicSize(sizeWidth, value);
            updateHitbox();
        }
        return value;
    }
}