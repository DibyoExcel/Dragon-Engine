package options;

import dge.obj.mobile.VirtualButton;
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
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import dge.backend.ModSetting;
#end

using StringTools;

class MainOptionsState extends MusicBeatState
{
	var options:Array<String> = ['DGE Settings', 'Psych Settings'];
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	private var enterButton:VirtualButton;
	private var settingName:String = 'Global Setting';

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'DGE Settings':
				LoadingState.loadAndSwitchState(new dge.states.options.DragonOptionsState());
			case 'Psych Settings':
				LoadingState.loadAndSwitchState(new options.PsychOptionsState());
			#if MODS_ALLOWED
			case settingName:
				var path = Paths.mods('settings.json');
				if (FileSystem.exists(path)) {//nah ah
					var storageKey = '_global';
					var getName = haxe.Json.parse(File.getContent(path)).storageKey;
					if (getName != null) {
						storageKey = getName;
					}
					ModSetting.init(storageKey);
					openSubState(new dge.states.options.custom.ModSubState(File.getContent(path), settingName));
				}
			#end
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Main Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		var randomColor:Int = 0xFF000000 | (Std.random(256) << 16) | (Std.random(256) << 8) | Std.random(256);
		bg.color = randomColor;
		CoolUtil.fitBackground(bg);
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);
		#if MODS_ALLOWED
		var path = Paths.mods('settings.json');
		if (FileSystem.exists(path)) {
			var getName = haxe.Json.parse(File.getContent(path)).settingName;
			if (settingName != null && settingName.length > 0) settingName = getName;
			options.push(settingName);
		}
		#end
		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		changeSelection();
		#if mobile
		enterButton = new VirtualButton(FlxG.width-125, FlxG.height-125, 'enter');
		add(enterButton);
		#end
		super.create();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P #if mobile || dge.backend.TouchUtil.swipeUp() #end) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P #if mobile || dge.backend.TouchUtil.swipeDown() #end) {
			changeSelection(1);
		}

		if (controls.BACK #if android || FlxG.android.justPressed.BACK #end) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT #if mobile || enterButton.justPressed #end) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}