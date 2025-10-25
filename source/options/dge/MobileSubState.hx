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

class MobileSubState extends BaseOptionsMenu
{
	public function new()
	{

		title = 'Mobile Settings';
		rpcTitle = 'Mobile Settings Menu'; //for Discord Rich Presence


		#if mobile
		var option:Option = new Option('Hitbox Transparency',
			'How much transparent should the Hitbox be.',
			'hitboxAlpha',
			'percent',
			0.0);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 0.5;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);
		var option:Option = new Option('Hitbox Transparency(Press)',
			'How much transparent should the Hitbox when press be.',
			'hitboxPressAlpha',
			'percent',
			0.25);
		option.scrollSpeed = 1.6;
		option.minValue = 0;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		addOption(option);
		var option:Option = new Option('Virtual Button Transparency',
			'How much transparent should the Virtul Button be.',
			'virtualButtonAlpha',
			'percent',
			0.5);
		option.scrollSpeed = 1.6;
		option.minValue = 0.15;
		option.maxValue = 1;
		option.changeValue = 0.01;
		option.decimals = 2;
		option.onChange = changeButtonAlpha;
		addOption(option);

		var option:Option = new Option('Swipe Distance',
			"How Much swipe range to swipe.",
			'swipeRange',
			'float',
			100);
		option.minValue = 5;
		option.scrollSpeed = 25;
		option.decimals = 1;
		option.changeValue = 0.1;
		addOption(option);
		var EUoption:Option = new Option('Space Keys',
			"Space Key for Mobile.",
			'spaceKey',
			'bool',
			false);
		EUoption.onChange = reloadSubstate;
		addOption(EUoption);
		if (EUoption.getValue() == true) {
			var option:Option = new Option('Space Key Position',
			"Position of Space Key.",
			'spaceKeyPosition',
			'string',
			'bottom',
			['bottom', 'top']);
			addOption(option);
		}
		#else
		lime.app.Application.current.window.alert('what ur doing here lol? you\'re even not in mobile.');
		close();
		#end
		super();
		changeBGColor(0xffff0000);
	}
	override public function close():Void {
		super.close();
		ClientPrefs.saveSettings();
		//trace("setting save!");
	}
	function changeButtonAlpha() {
		#if mobile
		leftButton.alpha = ClientPrefs.virtualButtonAlpha;
		rightButton.alpha = ClientPrefs.virtualButtonAlpha;
		resetButton.alpha = ClientPrefs.virtualButtonAlpha;
		enterButton.alpha = ClientPrefs.virtualButtonAlpha;
		#end
	}
	function reloadSubstate() {
		ClientPrefs.saveSettings();
		FlxG.resetState();
	}
}
