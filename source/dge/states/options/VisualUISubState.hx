package dge.states.options;

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
import options.BaseOptionsMenu;
import options.Option;
import flixel.util.FlxColor;

using StringTools;

class VisualUISubState extends BaseOptionsMenu
{

	var colorKeyPress:Array<String> = ['FF00FF', '00FFFF', '00FF00', '0000FF'];
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
		option.onChange = function() {
			keyBroker = true;
			ClientPrefs.saveSettings();
			//reset
			TitleState.initialized = false;
			TitleState.closedState = false;
			FlxG.sound.music.fadeOut(0.3);
			if(FreeplayState.vocals != null)
			{
				FreeplayState.vocals.fadeOut(0.3);
				FreeplayState.vocals = null;
			}
			FlxG.camera.fade(FlxColor.BLACK, 0.5, false, FlxG.resetGame, false);
		}
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

		var option:Option = new Option('Default Note Skin',
			"Change Default Noteskin.",
			'dflnoteskin',
			'stringfree',
			'NOTE_assets');
		option.showNote = true;
		option.onChange = onChangeNoteSkin;
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
			for (i in 0...colorKeyPress.length) {
				var option:Option = new Option('Key Stroke Color ' +  (i+1),
				"Color For Keystroke " + (i+1),
				'keyPressColor' + (i+1),
				'hex',
				colorKeyPress[i]);
				addOption(option);
			}
		}
		var option:Option = new Option('Pause BG Transparency',
		'How much transparent should the Pause Background.',
		'pauseBGAlpha',
		'percent',
		0.6);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		var option:Option = new Option('Classic Animation',
			"Using classic animation Strums and Character. Checked if you not like new animation behavior.",
			'classicAnim',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Botplay Text',
			"Botplay Text",
			'botplayText',
			'stringfree',
			'BOTPLAY');
		addOption(option);

		var option:Option = new Option('Hold Cover',
			"Show Player Hold Cover.",
			'holdCover',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Opponent Hold Cover',
			"Show Opponent Hold Cover.",
			'holdCoverOpt',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hold Cover Transparency',
			'How much transparent should the Hold Cover be.',
			'holdCoverAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.25;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);

		super();
		changeBGColor(0xffff0000);
	}
	override public function close():Void {
		super.close();
		ClientPrefs.saveSettings();
		//trace("setting save!");
	}
	function reloadSubstate() {
		ClientPrefs.saveSettings();
		FlxG.resetState();
	}
	function onChangeNoteSkin() {
		for (i in 0...spriteNote.length) {
			try{
				spriteNote[i].frames = Paths.getSparrowAtlas(ClientPrefs.dflnoteskin);
			} catch (e:Dynamic) {
				spriteNote[i].frames = Paths.getSparrowAtlas("NOTE_assets");
			}
			spriteNote[i].animation.addByPrefix('idle', 'arrow' + arrowDir[i].toUpperCase(), ClientPrefs.fpsStrumAnim, true);
			spriteNote[i].animation.addByPrefix('confirm', arrowDir[i].toLowerCase() + ' confirm', ClientPrefs.fpsStrumAnim, true);
			spriteNote[i].animation.play('idle');
			spriteNote[i].centerOrigin();
			spriteNote[i].centerOffsets();
		}
		for (i in 0...spriteNote_c.length) {
			try{
				spriteNote_c[i].frames = Paths.getSparrowAtlas(ClientPrefs.dflnoteskin);
			} catch (e:Dynamic) {
				spriteNote_c[i].frames = Paths.getSparrowAtlas("NOTE_assets");
			}
			spriteNote_c[i].animation.addByPrefix('idle', noteColor[i].toLowerCase() + "0", ClientPrefs.fpsStrumAnim, true);
			//spriteNote_c[i].animation.addByPrefix('confirm', arrowDir[i].toLowerCase() + ' confirm', ClientPrefs.fpsStrumAnim, false);
			spriteNote_c[i].animation.play('idle');
		}
	}
}
