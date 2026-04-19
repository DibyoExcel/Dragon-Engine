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

using StringTools;

class MiscSubState extends BaseOptionsMenu
{
	public function new()
	{

		title = 'DGE Miscellaneous Settings';
		rpcTitle = 'DGE Miscellaneous Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Dragon Word',
			"Dragon's Word.",
			'dragonW',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Hide Original Credits',
			"If Checked The Original Credits Will Hide.",
			'disableOGCredit',
			'bool',
			false);
		addOption(option);

		#if CHECK_FOR_UPDATES
		var option:Option = new Option('Check for Updates',
			'Turn this on to check for updates when you start the game.',
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end
		#if !html5
		/*var option:Option = new Option('Pause Unfocus',
			"If Checked the game will open pause screen.",
			'pauseUnFocus',
			'bool',
			false);
		addOption(option);*/
		#end

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
}
