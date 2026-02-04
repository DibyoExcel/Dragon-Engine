package options.dge;

import openfl.text.TextFormat;
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

class MiscSubState extends BaseOptionsMenu
{
	public function new()
	{

		title = 'Miscellaneous Settings';
		rpcTitle = 'Miscellaneous Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Start Pause',
			"Start Pause After Load Song.",
			'startPause',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Dragon Word',
			"Dragon's Word.",
			'dragonW',
			'bool',
			false);
		addOption(option);
		#if !html5
		var option:Option = new Option('Auto Pause',
			"If UnChecked The Game Keep Run Even Not Focus.",
			'autopause',
			'bool',
			true);
		option.onChange = changeAutoPause;
		addOption(option);
		#end

		var option:Option = new Option('Hide Original Credits',
			"If Checked The Original Credits Will Hide.",
			'disableOGCredit',
			'bool',
			false);
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
			'Turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end
		var option:Option = new Option('Limit Notes Spawn',
			"Should Note has limit to spawn?",
			'limitSpawn',
			'bool',
			false);

		addOption(option);
		
		var option:Option = new Option('Limit Notes Spawn Number',
			"How Much Limit notes to spawn.",
			'limitSpawnNotes',
			'int',
			50);
		option.minValue = 5;
		option.scrollSpeed = 20;
		addOption(option);

		var option:Option = new Option('Result Screen',
			"If Checked The Result screen will show after end song.",
			'useResultScr',
			'bool',
			false);
		addOption(option);
		#if !html5
		/*var option:Option = new Option('Pause Unfocus',
			"If Checked the game will open pause screen.",
			'pauseUnFocus',
			'bool',
			false);
		addOption(option);*/
		#end
		var option:Option = new Option('FPS Font Size',
			"FPS Counter Font Size.",
			'fpsFontSize',
			'int',
			#if mobile 18 #else 14 #end);
		option.minValue = 5;
		option.scrollSpeed = 15;
		option.onChange = function() {
			if (Main.fpsVar != null) {
				Main.fpsVar.defaultTextFormat = new TextFormat("_sans", ClientPrefs.fpsFontSize);
			}
		}
		addOption(option);

		var option:Option = new Option('Classic Spawn Note',
			"If Checked It Will Use Classic Note Spawn.(Might Reduce Lag)",
			'classicNoteSpawn',
			'bool',
			false);
		addOption(option);

		super();
		changeBGColor(0xffff0000);
	}
	override public function close():Void {
		super.close();
		ClientPrefs.saveSettings();
		//trace("setting save!");
	}
	function changeAutoPause() {
		FlxG.autoPause = ClientPrefs.autopause;
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
