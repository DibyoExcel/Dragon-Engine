package dge.obj.ui;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
using StringTools;

class NinesliceSprite extends FlxSpriteGroup
{
    private var TL:FlxSprite;
    private var TM:FlxSprite;
    private var TR:FlxSprite;

    private var ML:FlxSprite;//no mobile legends btw
    private var C:FlxSprite;
    private var MR:FlxSprite;

    private var BL:FlxSprite;
    private var BM:FlxSprite;
    private var BR:FlxSprite;

    private var CORNER_WIDTH:Int = 45;

    public var texture(default, set):String = null;
    public function new(x:Float, y:Float, width:Int = 100, height:Int = 100, ?texture:String = '') {
        super(x, y);
        if (texture == null || texture.length < 1) texture = 'ui/nineslice';
        while (texture.endsWith('/')) {
            texture = texture.substr(0, texture.length-1);
        }
        if (width < CORNER_WIDTH * 2) width = CORNER_WIDTH * 2;
        if (height < CORNER_WIDTH * 2) height = CORNER_WIDTH * 2;
        //damn i fucked up
        TL = new FlxSprite(0, 0).loadGraphic(Paths.image(texture + '/top_left'));
        TL.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        TL.updateHitbox();
        add(TL);
        var subCorner = (CORNER_WIDTH*2);
        TM = new FlxSprite(TL.x + CORNER_WIDTH, TL.y).loadGraphic(Paths.image(texture + '/top_middle'));
        TM.setGraphicSize(width - subCorner, CORNER_WIDTH);
        TM.updateHitbox();
        add(TM);
        TR = new FlxSprite(TL.x + width - CORNER_WIDTH, TL.y).loadGraphic(Paths.image(texture + '/top_right'));
        TR.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        TR.updateHitbox();
        add(TR);
        ML = new FlxSprite(TL.x, TL.y + CORNER_WIDTH).loadGraphic(Paths.image(texture + '/middle_left'));
        ML.setGraphicSize(CORNER_WIDTH, height - subCorner);
        ML.updateHitbox();
        add(ML);
        C = new FlxSprite(TL.x + CORNER_WIDTH, TL.y + CORNER_WIDTH).loadGraphic(Paths.image(texture + '/center'));
        C.setGraphicSize(width - subCorner, height - subCorner);
        C.updateHitbox();
        add(C);
        MR = new FlxSprite(TL.x + width - CORNER_WIDTH, TL.y + CORNER_WIDTH).loadGraphic(Paths.image(texture + '/middle_right'));
        MR.setGraphicSize(CORNER_WIDTH, height - subCorner);
        MR.updateHitbox();
        add(MR);
        BL = new FlxSprite(TL.x, TL.y + height - CORNER_WIDTH).loadGraphic(Paths.image(texture + '/bottom_left'));
        BL.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        BL.updateHitbox();
        add(BL);
        BM = new FlxSprite(TL.x + CORNER_WIDTH, TL.y + height - CORNER_WIDTH).loadGraphic(Paths.image(texture + '/bottom_middle'));
        BM.setGraphicSize(width - subCorner, CORNER_WIDTH);
        BM.updateHitbox();
        add(BM);
        BR = new FlxSprite(TL.x + width - CORNER_WIDTH, TL.y + height - CORNER_WIDTH).loadGraphic(Paths.image(texture + '/bottom_right'));
        BR.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        BR.updateHitbox();
        add(BR);
        resize(width, height);
    }
    
    public function resize(width:Int, height:Int):Void {
        if (width < CORNER_WIDTH * 2) width = CORNER_WIDTH * 2;
        if (height < CORNER_WIDTH * 2) height = CORNER_WIDTH * 2;
        var subCorner = CORNER_WIDTH * 2;

        TL.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        TL.updateHitbox();
        TL.setPosition(x, y);

        TM.setGraphicSize(width - subCorner, CORNER_WIDTH);
        TM.updateHitbox();
        TM.setPosition(TL.x + CORNER_WIDTH, TL.y);

        TR.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        TR.updateHitbox();
        TR.setPosition(TL.x + width - CORNER_WIDTH, TL.y);

        ML.setGraphicSize(CORNER_WIDTH, height - subCorner);
        ML.updateHitbox();
        ML.setPosition(TL.x, TL.y + CORNER_WIDTH);

        C.setGraphicSize(width - subCorner, height - subCorner);
        C.updateHitbox();
        C.setPosition(TL.x + CORNER_WIDTH, TL.y + CORNER_WIDTH);

        MR.setGraphicSize(CORNER_WIDTH, height - subCorner);
        MR.updateHitbox();
        MR.setPosition(TL.x + width - CORNER_WIDTH, TL.y + CORNER_WIDTH);

        BL.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        BL.updateHitbox();
        BL.setPosition(TL.x, TL.y + height - CORNER_WIDTH);

        BM.setGraphicSize(width - subCorner, CORNER_WIDTH);
        BM.updateHitbox();
        BM.setPosition(TL.x + CORNER_WIDTH, TL.y + height - CORNER_WIDTH);

        BR.setGraphicSize(CORNER_WIDTH, CORNER_WIDTH);
        BR.updateHitbox();
        BR.setPosition(TL.x + width - CORNER_WIDTH, TL.y + height - CORNER_WIDTH);
    }

    function set_texture(value:String):String {
        if (texture != value) {
            if (value == null || value.length < 1) value = 'ui/nineslice';
            while (value.endsWith('/')) {
                value = value.substr(0, value.length-1);
            }
            var size = [ Std.int(width), Std.int(height) ];
            texture = value;
            TL.loadGraphic(Paths.image(texture + '/top_left'));
            TM.loadGraphic(Paths.image(texture + '/top_middle'));
            TR.loadGraphic(Paths.image(texture + '/top_right'));
            ML.loadGraphic(Paths.image(texture + '/middle_left'));
            C.loadGraphic(Paths.image(texture + '/center'));
            MR.loadGraphic(Paths.image(texture + '/middle_right'));
            BL.loadGraphic(Paths.image(texture + '/bottom_left'));
            BM.loadGraphic(Paths.image(texture + '/bottom_middle'));
            BR.loadGraphic(Paths.image(texture + '/bottom_right'));

            resize(size[0], size[1]);
        }
        return value;
    }
}