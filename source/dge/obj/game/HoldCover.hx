package dge.obj.game;

import flixel.FlxSprite;
using StringTools;
import dge.backend.EKUtil;

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
        if (type == 'bf') {
            texture = skin;
        } else if (type == 'gf') {
            texture = skinSec;
        } else {
            texture = skinOpt;
        }

		loadAnims(texture);
        shader = colorSwap.shader;

        setupThis(x, y, 0);
        antialiasing = ClientPrefs.globalAntialiasing;
    }
    function loadAnims(skin:String) {
        var fr = Paths.getSparrowAtlas(skin);
        if (fr != null) {
            frames = fr;
        } else {
            frames = Paths.getSparrowAtlas('holdCover');
        }
        var colors = EKUtil.colArray;
        for (i in 0...colors.length) {
            var nameColor = colors[i];
            var specialAnim = CoolUtil.addSpecialAnimation;
            var defaultColor = EKUtil.defaultCol.toLowerCase();
            if (note != null && note.getActualDownscroll()) {
                specialAnim(this, "hold" + i, "hold cover " + nameColor + '_DownScroll0', "hold cover " + nameColor + '0', false, ClientPrefs.fpsStrumAnim);
                specialAnim(this, "end" + i, "hold cover " + nameColor + ' end_DownScroll0', "hold cover " + nameColor + ' end0', false, ClientPrefs.fpsStrumAnim);
                if (animation != null && !animation.exists("hold")) {
                    animation.addByPrefix('hold', "hold cover " + defaultColor + '0', ClientPrefs.fpsStrumAnim);
                }
            } else {
                specialAnim(this, "hold" + i, "hold cover " + nameColor + '0', "hold cover " + defaultColor + '0', false, ClientPrefs.fpsStrumAnim);
                specialAnim(this, "end" + i, "hold cover " + nameColor + ' end0', "hold cover " + defaultColor + ' end0', false, ClientPrefs.fpsStrumAnim);
            }
        }
    }
    public function setupThis(x:Float, y:Float, noteData:Int = 0, ?strum:StrumNote, ?note:Note) {//joke name lol
        this.strum = strum;
        this.note = note;
        var texture = '';
        alpha = ClientPrefs.holdCoverAlpha;
        if (note != null) {
            var holdData = note.holdCoverData;
            if (holdData.texture != null && holdData.texture.length > 0) {
                texture = holdData.texture;
            }
            alpha = holdData.alpha;
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
			}
			if (texture == null || texture.length < 1) texture = 'holdCover';
        }
        if (note != null) {
            var holdData = note.holdCoverData;
            timer = ((note.sustainLength+((note.strumTime+note.offsetStrumTime)-Conductor.songPosition))/1000)+note.holdCoverDelaySplash;
            if (holdData.copyAlpha && strum != null) {
                alpha = strum.alpha * holdData.alpha;
            } else {
                alpha = holdData.alpha;
            }
            setGraphicSize(Std.int(width * (holdData.scale*(ClientPrefs.strumsize*(EKUtil.getNoteScale(EKUtil.getCurrentMania()))))), Std.int(height * (holdData.scale*(ClientPrefs.strumsize*(EKUtil.getNoteScale(EKUtil.getCurrentMania()))))));
        }
        if (strum != null) {
            setPosition((x+strum.width/2)-(width/2), (y+strum.height/2)-(height/2));
            //trace('test');
        }
        loadAnims(texture);
        var mania = EKUtil.getCurrentMania();
        var indexTarget = EKUtil.noteAnimIndex[mania-1];
        var animIndex = indexTarget[noteData % indexTarget.length];
        // trace(animIndex);
        playAnim("hold" + (animIndex % 9));
    }
    public function playAnim(anim:String) {
        //trace(anim);
        if (timer <= 0 && anim.startsWith('hold')) return;//prevent stuck when freeze/lag
        animation.play(anim, true);
        centerOrigin();
		centerOffsets();
        if (note != null) {
            var holdData = note.holdCoverData;
            origin.x += holdData.offsetOrigin.x;
            origin.y += holdData.offsetOrigin.y;
            var shaderData = holdData.shader;
            var shaderType = holdData.shaderType.toLowerCase();
            shader = FunkinLua.shaderSpriteHandler(this, shaderType);
            if (shaderType == 'swap') {
                //swap
                colorSwap.hue = shaderData.colorSwap.hue;
                colorSwap.saturation = shaderData.colorSwap.saturation;
                colorSwap.brightness = shaderData.colorSwap.brightness;
            }
            if (shaderType == 'single') {
                //single
                colorSingle.r = shaderData.singleColor.r;
                colorSingle.g = shaderData.singleColor.g;
                colorSingle.b = shaderData.singleColor.b;
            }
            if (shaderType == 'invert') {
                //invert
                colorInvert.invertR = shaderData.invertColor.r;
                colorInvert.invertG = shaderData.invertColor.g;
                colorInvert.invertB = shaderData.invertColor.b;
            }
            if (shaderType == 'rgbswap') {
                //rgbSwap
                colorRGBSwap.swapR = shaderData.rgbSwap.r;
                colorRGBSwap.swapG = shaderData.rgbSwap.g;
                colorRGBSwap.swapB = shaderData.rgbSwap.b;
            }
            if (shaderType == 'pixel') {
                //pixel
                pixelSprite.pixelSize = shaderData.pixel.size;
            }
            if (shaderType == 'posterize') {
                //posterize
                posterize.posterizeRange = shaderData.posterize.range;
            }
            if (shaderType == 'rgbpalette') {
                //rgb palette
                rgbShader.r = shaderData.rgbPalette.r;
                rgbShader.g = shaderData.rgbPalette.g;
                rgbShader.b = shaderData.rgbPalette.b;
            }
            if (shaderType == 'grayscale') {
                //grayscale
                grayScale.mult = shaderData.grayscale.mult;
            }
            if (shaderType == 'b&w') {
                //black and white
                blackAndWhite.mult = shaderData.BAndW.mult;
                blackAndWhite.threshold = shaderData.BAndW.threshold;
            }
            scrollFactor.set(holdData.scrollFactor.x, holdData.scrollFactor.y);
            if (holdData.camera != null && holdData.camera.length > 0) {
                var camArray:Array<String> = holdData.camera.split(',');
                var realCam:Array<String> = [];
                for (i in 0...camArray.length) {
                    realCam[i] = camArray[i].trim();
                }
                cameras = FunkinLua.cameraArrayFromString(realCam);
            } else {
                cameras = null;
            }
        }
    }
    override function update(elapsed:Float) {
        if (strum != null) {
            var offsetX = 0.0;
            var offsetY = 0.0;
            if (note != null) {
                offsetX = note.holdCoverData.offset.x;
                offsetY = note.holdCoverData.offset.y;
                if (note.holdCoverData.copyAlpha) {
                    alpha = strum.alpha * note.holdCoverData.alpha;
                }
            }
            setPosition(((strum.x+strum.width/2)-(width/2))+offsetX, ((strum.y+strum.height/2)-(height/2))+offsetY);
        }
        if (timer > 0) {
            var speed = (PlayState.instance != null ? PlayState.instance.playbackRate : 1);
            timer -= elapsed * speed;
            if (timer <= 0) {
                if (note != null) {
                    var mania = EKUtil.getCurrentMania();
                    var indexTarget = EKUtil.noteAnimIndex[mania-1];
                    var animIndex = indexTarget[note.noteData % indexTarget.length];
                    playAnim('end' + animIndex);
                }
                timer = 0;
            }
        }
        if (animation.curAnim != null && animation.curAnim.name.startsWith('end') && animation.curAnim.finished) kill();
        super.update(elapsed);
    }
}