package addition;

import flixel.FlxSprite;

class Keypress extends FlxSprite
{
    private var isPress:Bool = false;
    public var colorKey(default,set):Int = 0xffff0000;
    public var colorKeyPress(default, set):Int = 0xffffffff;
    public var snapX:Float = 0;
	public var snapY:Float = 0;
	public var snapAngle:Float = 0;
	public var snapAlpha:Float = 0;
    public var alphaKey(default, set):Float = ClientPrefs.keyStrokeAlpha;
    public var alphaKeyPress(default, set):Float = ClientPrefs.keyStrokeAlpha;

    public function new(x:Float, y:Float, color:Int) {
        super(x, y);
        makeGraphic(50, 50);
        this.colorKey = color;
        this.color = color;
        shaderType = 'swap';
        alpha = alphaKey;
    }
    
    public function onKey(press:Bool = false) {
        isPress = press;
        if (press) {
            color = colorKeyPress;
            alpha = alphaKeyPress;
        } else {
            color = colorKey;
            alpha = alphaKey;
        }

    }

    private function set_colorKeyPress(value:Int):Int {
        if (color != value) {
            colorKeyPress = value;
            if (isPress) {
                color = value;
            }
        }
        return value;
    }

    private function set_colorKey(value:Int):Int {
        if (color != value) {
            colorKey = value;
            if (!isPress) {
                color = value;
            }
        }
        return value;
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

    private function set_alphaKey(value:Float):Float {
        if (alphaKey != value) {
            alphaKey = value;
            if (!isPress) {
                alpha = alphaKey;
            }
        }
        return value;
    }

    private function set_alphaKeyPress(value:Float):Float {
        if (alphaKeyPress != value) {
            alphaKeyPress = value;
            if (isPress) {
                alpha = alphaKeyPress;
            }
        }
        return value;
    }
}