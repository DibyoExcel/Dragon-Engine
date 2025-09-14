package;

import mobile.VirtualButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class OutdatedState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;

	private var backButton:VirtualButton;
	private var enterButton:VirtualButton;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
		bg.color = 0xff800080;
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			(ClientPrefs.dragonW ? "Greetings, noble warrior! it appears that you are currently utilizing an\n
			outdated version of Dragon Engine (" + Application.current.meta.get('version') + ").\n
			For a more powerful and enhanced experience, please update to " + TitleState.updateVersion + "!"  : "Sup bro, i think you currently running a\n
			outdated version of Dragon Engine (" + Application.current.meta.get('version') + "),\n
			please update to " + TitleState.updateVersion + "!") + "\n
			Press ESCAPE to proceed anyway.\n
			\n
			Thank you for using the Engine." + (ClientPrefs.dragonW ? " Squeak!" : ""),
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		#if mobile
		backButton = new VirtualButton(FlxG.width-250, FlxG.height-125, 'back');
		add(backButton);
		enterButton = new VirtualButton(FlxG.width-125, FlxG.height-125, 'enter');
		add(enterButton);
		#end
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			if (controls.ACCEPT #if mobile || enterButton.justPressed #end) {
				leftState = true;
				CoolUtil.browserLoad("https://github.com/DibyoExcel/Dragon-Engine");//bruh i forgot change after release 1.5.8 :skull:
			}
			else if(controls.BACK #if mobile || backButton.justPressed #end) {
				leftState = true;
			}

			if(leftState)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
					MusicBeatState.switchState(new MainMenuState());
					}
				});
			}
		}
		super.update(elapsed);
	}
}
