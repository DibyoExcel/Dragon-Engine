package dge.obj.mobile;
//better input

import flixel.FlxCamera;
import flixel.FlxSprite;
import dge.obj.mobile.TouchButton;

class Hitbox extends TouchButton
{
    public var pressAlpha(default, set):Float = ClientPrefs.hitboxPressAlpha;
    public var unpressAlpha(default, set):Float = ClientPrefs.hitboxAlpha;
    public var texture(default, set):String = null;
    //extra variable
    public var snapX:Float = 0;
	public var snapY:Float = 0;
	public var snapAngle:Float = 0;
	public var snapAlpha:Float = 0;
    //hint hitbox
    public var hitboxHint:FlxSprite = null;
    public var hintTexture(default, set):String = null;
    

    override private function set_justReleased(value:Bool):Bool {
        if (justReleased != value) {
            if (value) {
                alpha = unpressAlpha;
            }
        }
        return super.set_justReleased(value);
    }

    override private function set_justPressed(value:Bool):Bool {
        if (justPressed != value) {
            if (value) {
                alpha = pressAlpha;
            }
        }
        return super.set_justPressed(value);
    }

    private function set_texture(value:String):String {
        if (texture != value) {
            if (value == null || value.length < 1) {
                value = 'hitbox';
            }
            texture = value;
            var lastColor = this.color;
            var lastSize = [Std.int(width), Std.int(height)];
            loadGraphic(Paths.image(value));
            if (lastSize[0] > 0 && lastSize[1] > 0) {
                setGraphicSize(lastSize[0], lastSize[1]);
                updateHitbox();
            }
            this.color = lastColor;
        }
        return value;
    }

     public function new(x:Float, y:Float) {
        super(x, y);
        texture = '';
        alpha = unpressAlpha;
        shader = colorSwap.shader;
        blend = FunkinLua.blendModeFromString(ClientPrefs.hitboxBlend);
        antialiasing = ClientPrefs.globalAntialiasing;
        stickyInput = ClientPrefs.stickyHitbox;
        hitboxHint = new FlxSprite();
        hitboxHint.alpha = ClientPrefs.hitboxHintAlpha;
        hitboxHint.antialiasing = ClientPrefs.globalAntialiasing;
        hintTexture = '';
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

    function set_pressAlpha(value:Float):Float {
        if (pressAlpha != value) {
            pressAlpha = value;
            if (pressed) alpha = value;
        }
        return value;
    }

    function set_unpressAlpha(value:Float):Float {
        if (unpressAlpha != value) {
            unpressAlpha = value;
            if (!pressed) alpha = value;
        }
        return value;
    }

    function set_hintTexture(value:String):String {
        if (hintTexture != value) {
            hintTexture = value;
            if (hintTexture == null || hintTexture.length < 1) {
                hintTexture = 'hitbox-hint';
            }
            if (hitboxHint != null) {
                hitboxHint.loadGraphic(Paths.image(hintTexture));
                hitboxHint.color = this.color;
                fitHintToHitbox();
            }
        }
        return value;
    }

    override function destroy():Void {
        super.destroy();
        if (hitboxHint != null) {
            hitboxHint.destroy();
            hitboxHint = null;
        }
    }

    override function updateHitbox():Void {
        super.updateHitbox();
        fitHintToHitbox();
    }

    override function draw():Void {
        super.draw();
        if (hitboxHint != null && hitboxHint.visible && hitboxHint.alpha > 0) {
            CoolUtil.alignItem(this, hitboxHint, BOTTOM_MIDDLE);
            var offsetMax = 100;
            var centerOffset = (height - hitboxHint.height) / 2;
            hitboxHint.y -= Math.min(centerOffset, offsetMax);
            hitboxHint.color = this.color;
            hitboxHint.cameras = this.cameras;
            hitboxHint.draw();
        }
    }

    function fitHintToHitbox() {
        if (hitboxHint != null && hitboxHint.graphic != null && hitboxHint.frameWidth > 0 && hitboxHint.frameHeight > 0) {
            var scaleX = width / hitboxHint.frameWidth;
            var scaleY = height / hitboxHint.frameHeight;
            var scale = Math.min(scaleX, scaleY) * 0.35;
            
            hitboxHint.scale.set(scale, scale);
            hitboxHint.updateHitbox();
            
            CoolUtil.alignItem(this, hitboxHint, BOTTOM_MIDDLE);
            var offsetMax = 50;
            var centerOffset = (height - hitboxHint.height) / 2;
            hitboxHint.y -= Math.min(centerOffset, offsetMax);//so it will center if hitbox small
        }
    }
}