package options.dge;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualUISubState extends BaseOptionsMenu
{
	public function new()
	{

		title = 'Visual & UI Settings';
		rpcTitle = 'Visual & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Long Note Transparency',
			'How much transparent should the Long Notes be.',
			'longNoteAlpha',
			'percent',
			0.6);
		option.scrollSpeed = 1.6;
		option.minValue = 0.25;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Note Splash Transparency',
			'How much transparent should the Note Splash be.',
			'noteSplashAlpha',
			'percent',
			0.6);
		option.scrollSpeed = 1.6;
		option.minValue = 0.25;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Strum FPS',
			"How Much FPS To Strum Animation(Affected Notesplash Too).",
			'fpsStrumAnim',
			'int',
			24);
		option.minValue = 5;
		option.scrollSpeed = 10;
		addOption(option);

		var option:Option = new Option('Note Size',
			"How Much Note Size Be(No Pixel Note).",
			'strumsize',
			'float',
			0.7);
		option.minValue = 0.25;
		option.maxValue = 5;//How The Hell How Much Play Note Size As 5?
		option.scrollSpeed = 1.6;
		option.changeValue = 0.1;
		addOption(option);

		var option:Option = new Option('Dark Mode',
			"Dark Mode.",
			'darkmode',
			'bool',
			false);
		option.onChange = reloadSubstate;
		addOption(option);

		var option:Option = new Option('Opponent Note Splashes',
			"Show Opponent Note Splash",
			'noteSplashesOpt',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Classic Strums',
			"The FNF Classic Strum(Note Splash Will Disable).",
			'clsstrum',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Overfill Health Bar',
			"Messed Up Health Bar With Spammy.",
			'ofhb',
			'bool',
			true);
		addOption(option);

		var EUoption:Option = new Option('Extra UI',
			"Extra UI By DubEnderDragon.",
			'extUI',
			'bool',
			false);
		EUoption.onChange = reloadSubstate;
		addOption(EUoption);
		if (EUoption.getValue() == true) {
			var option:Option = new Option('Key Stroke Transparency',
			'How much transparent should the Key Stroke be.',
			'keyStrokeAlpha',
			'percent',
			1);
			option.scrollSpeed = 1.6;
			option.minValue = 0.1;
			option.maxValue = 1;
			option.changeValue = 0.01;
			option.decimals = 2;
			addOption(option);
		}

		super();
		changeBGColor(0xffff0000);
	}
	override public function close():Void {
		super.close();
		ClientPrefs.saveSettings();
		//trace("setting save!");
	}
	function reloadSubstate() {
		FlxG.resetState();
	}
}
