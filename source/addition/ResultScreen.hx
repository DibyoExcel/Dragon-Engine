package addition;
import flixel.FlxSprite;
import Alphabet;
import flixel.FlxSubState;
import flixel.FlxG;
import Controls;
import haxe.Timer;

class ResultScreen extends MusicBeatState
{
    private var A:Timer;
    public function new(score:Int, miss:Int, rating:String, percent:Float) {
        super();
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
		bg.color = 0xffff00ff;
        add(bg);
        var aaaaTxt:Alphabet = new Alphabet(25, (FlxG.height/2)-100, "SCORE:" + score, false);
        add(aaaaTxt);
        var aaaaTxt:Alphabet = new Alphabet(25, (FlxG.height/2)-25, "MISS:" + miss, false);
        add(aaaaTxt);
        var aaaaTxt:Alphabet = new Alphabet(25, (FlxG.height/2)+50, "RATING:" + rating, false);
        add(aaaaTxt);
        var aaaaTxt:Alphabet = new Alphabet(25, (FlxG.height/2)+125, "PERCENT:" + percent + "%", false);
        add(aaaaTxt);
        var tips:Alphabet = new Alphabet(0, FlxG.height-75, "Press Enter To FreePlay");
        add(tips);
        A = new Timer(60000);
        A.run = function() {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            MusicBeatState.switchState(new FreeplayState());
            if (A != null) {
                A.stop();
            }
        }
    }
    override function update(elapsed:Float) {
        if (controls.ACCEPT) {
            FlxG.sound.playMusic(Paths.music('freakyMenu'));
            MusicBeatState.switchState(new FreeplayState());
            if (A != null) {
                A.stop();
            }
        }
    }
}