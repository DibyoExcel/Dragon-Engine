package dge.states.options.custom;

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
import dge.states.options.custom.BaseOptionsMenu;
import dge.states.options.custom.Option;
import dge.backend.ModSetting;

using StringTools;

class ModSubState extends BaseOptionsMenu
{
	public function new(rawJson:String, folder:String)
	{
		if (rawJson.length>0) {
			var jsonParse = haxe.Json.parse(rawJson);
			title = folder;
			rpcTitle = folder + ' Menu'; //for Discord Rich Presence
	
			if (jsonParse.optionsList != null) {
				var optionList:Array<Dynamic> = cast jsonParse.optionsList;//force feed it
				for (opt in optionList) {
					if (opt.name == null || opt.name.length < 1 || opt.variable == null || opt.variable.length < 1) continue;
					var option:Option = new Option(
					(opt.name != null ? opt.name : 'No Name'),
					(opt.description != null ? opt.description : 'No Description.'),
					(opt.variable != null ? opt.variable : 'unknown'),
					(opt.type != null ? opt.type : 'bool'),
					(opt.defaultValue != null ? opt.defaultValue : false),
					(opt.options)
					);
					var field = Reflect.fields(opt);
					for (fields in field) {
						if (fields.startsWith("_") || fields == 'name' || fields == 'description' || fields == 'variable' || fields == 'type' || fields == 'defaultValue' || fields == 'options') continue;//EXCLUDE	
						var value = Reflect.field(opt, fields);
						try{
							Reflect.setProperty(option, fields, value);
						}
					}
					addOption(option);
				}
			}
		}
		super();
		if (rawJson.length > 0) {
			var jsonParse = haxe.Json.parse(rawJson);
			if (jsonParse.bgColor != null) {
				var forceString:String = cast jsonParse.bgColor;
				forceString = forceString.replace("#", "0xFF");
				changeBGColor(Std.int(Std.parseInt(forceString)));
			}
		}
	}
	override public function close():Void {
		ModSetting.saveSettings();
		super.close();
		
		//trace("setting save!");
	}
}
