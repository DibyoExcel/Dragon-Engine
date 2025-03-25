package pauseSetting.options;

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

class DragonOptionsState extends BaseOptionsMenu
{
	public function new()
	{

		title = 'Dragon Settings';
		rpcTitle = 'Dragon Settings Menu'; //for Discord Rich Presence

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
		var option:Option = new Option('Start Pause',
			"Start Pause After Load Song.",
			'startPause',
			'bool',
			false);
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
		var option:Option = new Option('Dragon Word',
			"Dragon's Word.",
			'dragonW',
			'bool',
			false);
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

		var option:Option = new Option('Auto Pause',
			"If UnChecked The Game Keep Run Even Not Focus.",
			'autopause',
			'bool',
			true);
		option.onChange = changeAutoPause;
		addOption(option);

		var option:Option = new Option('Hide Original Credits',
			"If Checked The Original Credits Will Hide.",
			'disableOGCredit',
			'bool',
			false);
		option.onChange = changeAutoPause;
		addOption(option);

		var option:Option = new Option('Default Note Skin',
			"Change Default Noteskin.",
			'dflnoteskin',
			'string',
			'NOTE_assets',
			['NOTE_assets', 'NOTE_minecraft_assets']);
		option.showNote = true;
		option.onChange = onChangeNoteSkin;
		addOption(option);
		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'On Release builds, turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end
		super();
	}
	override public function close():Void {
		super.close();
		ClientPrefs.saveSettings();
		FlxG.switchState(new pauseSetting.MainOptionsState());
		//trace("setting save!");
	}
	function changeAutoPause() {
		FlxG.autoPause = ClientPrefs.autopause;
	}
	function reloadSubstate() {
		FlxG.state.closeSubState();
		FlxG.state.openSubState(new pauseSetting.options.DragonOptionsState());
	}
	function onChangeNoteSkin() {
		trace("'" + ClientPrefs.dflnoteskin + "'");
		for (i in 0...spriteNote.length) {
			spriteNote[i].frames = Paths.getSparrowAtlas(ClientPrefs.dflnoteskin);
			spriteNote[i].animation.addByPrefix('idle', 'arrow' + arrowDir[i].toUpperCase(), ClientPrefs.fpsStrumAnim, true);
			spriteNote[i].animation.addByPrefix('confirm', arrowDir[i].toLowerCase() + ' confirm', ClientPrefs.fpsStrumAnim, true);
			spriteNote[i].animation.play('idle');
			spriteNote[i].centerOrigin();
			spriteNote[i].centerOffsets();
		}
		for (i in 0...spriteNote_c.length) {
			spriteNote_c[i].frames = Paths.getSparrowAtlas(ClientPrefs.dflnoteskin);
			spriteNote_c[i].animation.addByPrefix('idle', noteColor[i].toLowerCase() + "0", ClientPrefs.fpsStrumAnim, true);
			//spriteNote_c[i].animation.addByPrefix('confirm', arrowDir[i].toLowerCase() + ' confirm', ClientPrefs.fpsStrumAnim, false);
			spriteNote_c[i].animation.play('idle');
		}
	}
}
