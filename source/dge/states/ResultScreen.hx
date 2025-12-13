package dge.states;
import mobile.VirtualButton;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import Alphabet;
import Controls;
import haxe.Timer;

class ResultScreen extends MusicBeatState
{
    public var toStoryMode:Bool = false;
    private var ForceFreePlay:Timer;
    private var enterButton:VirtualButton;
    public function new(score:Int, miss:Int, rating:Null<String>, percent:Null<Float>) {
        super();
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
        add(bg);
        var aaaa:Alphabet = new Alphabet(0, (FlxG.height/2)-125, (ClientPrefs.dragonW ? 'Coins: ' : 'Score: ') + score, false);
        add(aaaa);
        var aaaa:Alphabet = new Alphabet(0, (FlxG.height/2)-50, (ClientPrefs.dragonW ? 'Slay: ' : 'Misses: ') + miss, false);
        add(aaaa);
        if (rating != null) {
            var aaaa:Alphabet = new Alphabet(0, (FlxG.height/2)+25, (ClientPrefs.dragonW ? 'Fang: ' : 'Rating: ') + rating, false);
        }
        add(aaaa);
        var aaaa:Alphabet = new Alphabet(0, (FlxG.height/2)+100, "Percent: " + Highscore.floorDecimal(percent * 100, 2) + "%", false);
        add(aaaa);
        var tips:Alphabet = new Alphabet(0, FlxG.height-75, "Press Enter To FreePlay");
        add(tips);
        #if mobile
        enterButton = new VirtualButton(FlxG.width-125, FlxG.height-125, 'enter');
        add(enterButton);
        #end
        ForceFreePlay = new Timer(60000);//60 Second In This Substate Will Force To Free Play
        ForceFreePlay.run = function() {
            if (toStoryMode) {
                MusicBeatState.switchState(new StoryMenuState());
            } else {
                MusicBeatState.switchState(new FreeplayState());
            }
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
            if (ForceFreePlay != null) {
                ForceFreePlay.stop();
            }
        }
    }
    override public function update(elapsed:Float) {
        if (controls.ACCEPT #if mobile || enterButton.justPressed #end) {
            if (toStoryMode) {
                MusicBeatState.switchState(new StoryMenuState());
            } else {
                MusicBeatState.switchState(new FreeplayState());
            }
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
            if (ForceFreePlay != null) {
                ForceFreePlay.stop();
            }
        }
    }
}