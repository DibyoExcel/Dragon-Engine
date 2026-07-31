package dge.obj.game;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class ComboSpr extends FlxSprite
{
    var tweenAlpha:FlxTween;

    public function new(texture:String = '', anim:String = 'shit') {
        super(0, 0);
        setupRating(texture, anim);
    }

    public function setupRating(texture:String = '', anim:String = 'shit', startMult:Float = 1, scale:Float = 0.7) {
        if (texture == null || texture.length < 1) texture = 'comboSpr';
        reset(0, 0);
        alpha = 1;
        loadAnims(texture);
        initSize(scale);
        animation.play(anim, true);
        moveSetup(startMult);
    }

    override function kill() {
        removeTween();
        super.kill();
    }
    
    override function destroy() {
        removeTween();
        super.destroy();
    }
    override function reset(x, y) {
        removeTween();
        super.reset(x, y);
    }
    function removeTween() {
        if (tweenAlpha != null) {
            tweenAlpha.cancel();
            tweenAlpha = null;
        }
    }
    function loadAnims(texture:String) {
        try {
            this.frames = Paths.getSparrowAtlas(texture);
        } catch (e:Dynamic) {
            this.frames = Paths.getSparrowAtlas('comboAtlas');
        }
        var list = [ 'combo', 'shit', 'bad', 'good', 'sick' ];
        for (anim in list) {
            animation.addByPrefix(anim, anim, 24);
        }
        for (num in 0...10) {
            animation.addByPrefix('num' + num, 'num' + num, 24);
        }
    }
    function moveSetup(startMult:Float) {
        var playBackSpeed:Float = 1;
        if (PlayState.instance != null) playBackSpeed = PlayState.instance.playbackRate;
        tweenAlpha = FlxTween.tween(this, {alpha : 0}, 0.2 / playBackSpeed, {
            onComplete: function(_) {
                kill();
                tweenAlpha = null;
            },
            startDelay: Conductor.crochet * (0.002/startMult) / playBackSpeed
        });
    }
    public function initSize(scale:Float) {
        if (!PlayState.isPixelStage)
        {
            setGraphicSize(Std.int(width * scale));
            antialiasing = ClientPrefs.globalAntialiasing;
        }
        else
        {
            setGraphicSize(Std.int(width * PlayState.daPixelZoom * 0.85 * (scale / 0.7)));
        }
        updateHitbox();
    }
}