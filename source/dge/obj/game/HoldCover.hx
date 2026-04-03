package dge.obj.game;

import flixel.FlxSprite;
using StringTools;

class HoldCover extends FlxSprite
{
    public var strum:StrumNote;
    public var note:Note;
    private var timer:Float = 0;
    public function new(x:Float, y:Float, type:String) {
        super(x, y);
        var texture:String = '';
        var skin:String = PlayState.SONG.holdCoverSkin;
        var skinOpt:String = PlayState.SONG.holdCoverSkinOpt;
        var skinSec:String = PlayState.SONG.holdCoverSkinSec;
        if (skin == null || skin.length < 1) {
            skin = "holdCover";
        }
        if (skinOpt == null || skinOpt.length < 1) {
            skinOpt = skin;
        }
        if (skinSec == null || skinSec.length < 1) {
            if (skinOpt == null || skinOpt.length < 1) {
                skinOpt = skin;
            }
            skinSec = skinOpt;
        }
        if (type == 'bg') {
            texture = skin;
        } else if (type == 'gf') {
            texture = skinSec;
        } else {
            texture = skinOpt;
        }

		loadAnims(texture);
        shaderType = 'swap';

        setupThis(x, y, 0);
        antialiasing = ClientPrefs.globalAntialiasing;
    }
    function loadAnims(skin:String) {
        try {
            frames = Paths.getSparrowAtlas(skin);
        } catch (e:Dynamic) {
            frames = Paths.getSparrowAtlas('holdCover');
        }
        var colors = [ 'purple', 'blue', 'green', 'red' ];
        for (i in 0...colors.length) {
            var nameColor = colors[i];
            if (note != null && note.getActualDownscroll()) {
                var specialAnim = CoolUtil.addSpecialAnimation;
                specialAnim(this, "hold" + i, "hold cover " + nameColor + '_DownScroll0', "hold cover " + nameColor + '0', false, ClientPrefs.fpsStrumAnim);
                specialAnim(this, "end" + i, "hold cover " + nameColor + ' end_DownScroll0', "hold cover " + nameColor + ' end0', false, ClientPrefs.fpsStrumAnim);
            } else {
                animation.addByPrefix("hold" + i, "hold cover " + nameColor + '0', ClientPrefs.fpsStrumAnim, false);
                animation.addByPrefix("end" + i, "hold cover " + nameColor + ' end0', ClientPrefs.fpsStrumAnim, false);
            }
        }
    }
    public function setupThis(x:Float, y:Float, noteData:Int = 0, ?strum:StrumNote, ?note:Note) {//joke name lol
        this.strum = strum;
        this.note = note;
        var texture = '';
        alpha = ClientPrefs.holdCoverAlpha;
        if (note != null) {
            if (note.holdCoverTexture != null && note.holdCoverTexture.length > 0) {
                texture = note.holdCoverTexture;
            }
            alpha = note.holdCoverAlpha;
        }
        if (texture == null || texture.length < 1) {
            var skin:String = PlayState.SONG.holdCoverSkin;
			var skinOpt:String = PlayState.SONG.holdCoverSkinOpt;
			var skinSec:String = PlayState.SONG.holdCoverSkinSec;
			if (skin == null || skin.length < 1) {
				skin = "holdCover";
			}
			if (skinOpt == null || skinOpt.length < 1) {
				skinOpt = skin;
			}
			if (skinSec == null || skinSec.length < 1) {
				if (skinOpt == null || skinOpt.length < 1) {
					skinOpt = skin;
				}
				skinSec = skinOpt;
			}
            if (note != null) {
                if (note.mustPress) {
					texture = skin;
				} else if (note.gfNote) {
					texture = skinSec;
				} else {
					texture = skinOpt;
				}
            } else {
                texture = 'holdCover';
            }
        }
        if (note != null) {
            timer = ((note.sustainLength+((note.strumTime+note.offsetStrumTime)-Conductor.songPosition))/1000)+note.holdCoverDelaySplash;
            if (note.holdCoverCopyAlpha && strum != null) {
                alpha = strum.alpha * note.holdCoverAlpha;
            } else {
                alpha = note.holdCoverAlpha;
            }
            setGraphicSize(Std.int(width * note.holdCoverScale), Std.int(height * note.holdCoverScale));
        }
        if (strum != null) {
            setPosition((x+strum.width/2)-(width/2), (y+strum.height/2)-(height/2));
            //trace('test');
        }
        loadAnims(texture);
        playAnim("hold" + (noteData % 4));
    }
    public function playAnim(anim:String) {
        //trace(anim);
        if (timer <= 0 && anim.startsWith('hold')) return;//prevent stuck when freeze/lag
        animation.play(anim, true);
        centerOrigin();
		centerOffsets();
        if (note != null) {
            shaderType = note.holdCoverShaderType;
            if (shaderType == 'swap') {
                //swap
                colorSwap.hue = note.holdCoverHue;
                colorSwap.saturation = note.holdCoverSat;
                colorSwap.brightness = note.holdCoverBrt;
            }
            if (shaderType == 'single') {
                //single
                colorSingle.r = note.holdCoverSingleR;
                colorSingle.g = note.holdCoverSingleG;
                colorSingle.b = note.holdCoverSingleB;
            }
            if (shaderType == 'invert') {
                //invert
                colorInvert.invertR = note.holdCoverInvertR;
                colorInvert.invertG = note.holdCoverInvertG;
                colorInvert.invertB = note.holdCoverInvertB;
            }
            if (shaderType == 'rgbswap') {
                //rgbSwap
                colorRGBSwap.swapR = note.holdCoverRGBSwapR;
                colorRGBSwap.swapG = note.holdCoverRGBSwapG;
                colorRGBSwap.swapB = note.holdCoverRGBSwapB;
            }
            if (shaderType == 'pixel') {
                //pixel
                pixelSprite.pixelSize = note.holdCoverPixelSize;
            }
            if (shaderType == 'posterize') {
                //posterize
                posterize.posterizeRange = note.holdCoverPosterizeRange;
            }
            if (shaderType == 'rgbpalette') {
                //rgb palette
                rgbShader.r = note.holdCoverR;
                rgbShader.g = note.holdCoverG;
                rgbShader.b = note.holdCoverB;
            }
            if (shaderType == 'grayscale') {
                //grayscale
                grayScale.mult = note.holdCoverGrayscaleMult;
            }
            if (shaderType == 'b&w') {
                //black and white
                blackAndWhite.mult = note.holdCoverBAndWMult;
                blackAndWhite.threshold = note.holdCoverBAndWThreshold;
            }
            scrollFactor.set(note.holdCoverScrollFactor[0], note.holdCoverScrollFactor[1]);
            if (note.holdCoverCam != null && note.holdCoverCam.length > 0) {
                var camArray:Array<String> = note.holdCoverCam.split(',');
                var realCam:Array<String> = [];
                for (i in 0...camArray.length) {
                    realCam[i] = camArray[i].trim();
                }
                cameras = FunkinLua.cameraArrayFromString(realCam);
            }
        }
    }
    override function update(elapsed:Float) {
        if (strum != null) {
            var offsetX = 0.0;
            var offsetY = 0.0;
            if (note != null) {
                offsetX = note.holdCoverOffsetX;
                offsetY = note.holdCoverOffsetY;
                if (note.holdCoverCopyAlpha) {
                    alpha = strum.alpha * note.holdCoverAlpha;
                }
            }
            setPosition(((strum.x+strum.width/2)-(width/2))+offsetX, ((strum.y+strum.height/2)-(height/2))+offsetY);
        }
        if (timer > 0) {
            timer -= elapsed;
            if (timer <= 0) {
                if (note != null) {
                    playAnim('end' + (note.noteData%4));
                }
                timer = 0;
            }
        }
        if (animation.curAnim != null && animation.curAnim.name.startsWith('end') && animation.curAnim.finished) kill();
        super.update(elapsed);
    }
}