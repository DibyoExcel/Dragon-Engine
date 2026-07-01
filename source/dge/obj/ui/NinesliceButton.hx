package dge.obj.ui;

import flixel.FlxG;
import flixel.FlxCamera;
import flixel.input.mouse.FlxMouse;

class NinesliceButton extends NinesliceSprite
{
    public var callback:Void->Void;
    public var onContextMenu:Void->Void;
    public var onHover:Bool->Void;
    public var hover:Bool = false;
    private var mouse:FlxMouse = null;
    public var holdThre:Float = 1.0;
    var holdTime:Float = 0.0;
    
    public function new(x:Float, y:Float, width:Int, height:Int, ?texture:String, ?callback:Void->Void, ?contextMenu:Void->Void) {
        super(x, y, width, height, texture);
        this.callback = callback;
        onContextMenu = contextMenu;
    }
    override public function update(e:Float) {
        super.update(e);
        if (FlxG.mouse != null) {
            var cams = cameras;
            if (cams == null) {
                cams = @:privateAccess {FlxCamera._defaultCameras;};
            }
            for (cam in cams) {
                if (overlapsPoint(FlxG.mouse.getWorldPosition(cam), true, cam)) {
                    if (mouse == null && FlxG.mouse.justPressed) {
                        mouse = FlxG.mouse;
                    }
                    if (!hover) {
                        hover = true;
                        TL.loadGraphic(texture + '/top_left-hover');
                        TM.loadGraphic(texture + '/top_middle-hover');
                        TR.loadGraphic(texture + '/top_right-hover');
                        ML.loadGraphic(texture + '/middle_left-hover');
                        C.loadGraphic(texture + '/center-hover');
                        MR.loadGraphic(texture + '/middle_right-hover');
                        BL.loadGraphic(texture + '/bottom_left-hover');
                        BM.loadGraphic(texture + '/bottom_middle-hover');
                        BR.loadGraphic(texture + '/bottom_right-hover');
                        resize(Std.int(width), Std.int(height));
                        if (onHover != null) onHover(true);
                        break;
                    }
                } else {
                    if (hover) {
                        hover = false;
                        TL.loadGraphic(texture + '/top_left');
                        TM.loadGraphic(texture + '/top_middle');
                        TR.loadGraphic(texture + '/top_right');
                        ML.loadGraphic(texture + '/middle_left');
                        C.loadGraphic(texture + '/center');
                        MR.loadGraphic(texture + '/middle_right');
                        BL.loadGraphic(texture + '/bottom_left');
                        BM.loadGraphic(texture + '/bottom_middle');
                        BR.loadGraphic(texture + '/bottom_right');
                        resize(Std.int(width), Std.int(height));
                        if (onHover != null) onHover(false);
                    }
                }
            }
            if (mouse != null && mouse.pressed && onContextMenu != null) {
                for (cam in cams) {
                    if (overlapsPoint(FlxG.mouse.getWorldPosition(cam), true, cam)) {
                        if (holdTime < holdThre) {
                            holdTime += e;
                        } else {
                            onContextMenu();
                            holdTime = 0;
                            mouse = null;
                        }
                    }
                }
            }
            if (mouse != null && mouse.justReleased) {
                for (cam in cams) {
                    if (overlapsPoint(FlxG.mouse.getWorldPosition(cam), true, cam) && callback != null) {
                        callback();
                    }
                }
                mouse = null;
            }
        }
    }

    override function set_texture(value:String):String {
        if (texture != value) {
            texture = value;
            if (hover) {
                TL.loadGraphic(texture + '/top_left-hover');
                TM.loadGraphic(texture + '/top_middle-hover');
                TR.loadGraphic(texture + '/top_right-hover');
                ML.loadGraphic(texture + '/middle_left-hover');
                C.loadGraphic(texture + '/center-hover');
                MR.loadGraphic(texture + '/middle_right-hover');
                BL.loadGraphic(texture + '/bottom_left-hover');
                BM.loadGraphic(texture + '/bottom_middle-hover');
                BR.loadGraphic(texture + '/bottom_right-hover');
            } else {
                TL.loadGraphic(texture + '/top_left');
                TM.loadGraphic(texture + '/top_middle');
                TR.loadGraphic(texture + '/top_right');
                ML.loadGraphic(texture + '/middle_left');
                C.loadGraphic(texture + '/center');
                MR.loadGraphic(texture + '/middle_right');
                BL.loadGraphic(texture + '/bottom_left');
                BM.loadGraphic(texture + '/bottom_middle');
                BR.loadGraphic(texture + '/bottom_right');
            }
            resize(Std.int(width), Std.int(height));
        }
        return value;
    }
}