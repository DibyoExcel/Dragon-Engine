package dge.states;

import lime.system.System as LimeSys;
import flixel.FlxSprite;
import haxe.Json;
import openfl.utils.Assets;
import sys.io.File;
import sys.FileSystem;
import openfl.system.System;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;
using StringTools;

typedef JsonError = {
    var background:String;
    var background_dark:String;
    var exitGameButtonColor:String;
    var restartGameButtonColor:String;
    var copyLogButtonColor:String;
    var errorTextColor:String;
    var exitGameButtonTextColor:String;
    var restartGameButtonTextColor:String;
    var copyLogButtonTextColor:String;
    //texts-lang
    var exitGameButtonText:String;
    var restartGameButtonText:String;
    var copyLogButtonText:String;
    var fontType:String;
    var errorMessage:String;
}

class ErrorState extends FlxState
{
    private var text:FlxText;
    private var exitGameButton:FlxButton;
    private var restartGameButton:FlxButton;
    private var copyLogButton:FlxButton;
    var defaultJson:JsonError = {
        background: "",//is for image path
        background_dark: "",//same as 'background' but for darkmode setting
        exitGameButtonColor: "#FF0000",
        restartGameButtonColor: "#00FF00",
        copyLogButtonColor: "#FF8000",
        errorTextColor: "#FF0000",
        exitGameButtonTextColor: "#FFFFFF",
        restartGameButtonTextColor: "#FFFFFF",
        copyLogButtonTextColor: "#FFFFFF",
        exitGameButtonText: "Exit Game",
        restartGameButtonText: "Restart Game",
        copyLogButtonText: "Copy Error Log",
        fontType: "vcr.ttf",
        errorMessage: "ERROR!!\n\n{logmsg}\n\nDevice Info:\nModel: {deviceModel}\nVendor: {deviceVendor}\nPlatform: {platformLabel} ({platformName} {platformVersion})"
    };
    public function new(errorMessage:String)
    {
        super();
        var configJson:JsonError = getJsonConfig();
        for (field in Reflect.fields(defaultJson)) {
            if (!Reflect.hasField(configJson, field) || Reflect.field(configJson, field) == null) {
                Reflect.setField(configJson, field, Reflect.field(defaultJson, field));
                //trace('ErrorState: Missing field "' + field + '" in configJson, using default value.');
            }
        }
        #if !mobile
        FlxG.mouse.visible = true;
        #end
        bgColor = 0xFF000000;
        if (configJson.background.length > 0 && configJson.background_dark.length > 0) {
            var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(ClientPrefs.darkmode ? configJson.background_dark : configJson.background));
            CoolUtil.fitBackground(bg);
            add(bg);
        } else if (configJson.background.length > 0) {
            var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(configJson.background));
            CoolUtil.fitBackground(bg);
            add(bg);
        } else if (configJson.background_dark.length > 0) {
            var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(configJson.background_dark));
            CoolUtil.fitBackground(bg);
            add(bg);
        }
        text = new FlxText(0, 0, FlxG.width/2, CoolUtil.keyTOVariable(configJson.errorMessage, [
            'logmsg' => errorMessage,
            'deviceModel' => LimeSys.deviceModel,
            'deviceVendor' => LimeSys.deviceVendor,
            'platformLabel' => LimeSys.platformLabel,
            'platformName' => LimeSys.platformName,
            'platformVersion' => LimeSys.platformVersion
        ]));
        text.setFormat(Paths.font(configJson.fontType), 30, Std.int(Std.parseInt(configJson.errorTextColor.replace("#", "0xFF"))), 'left');
        add(text);
        restartGameButton = new FlxButton(0, 0, configJson.restartGameButtonText, function() {
            TitleState.initialized = false;
			TitleState.closedState = false;
            FlxG.resetGame();
        });
        restartGameButton.setGraphicSize(Std.int(FlxG.width/3), 75);
        restartGameButton.updateHitbox();
        restartGameButton.screenCenter();
        restartGameButton.x += FlxG.width/4;
        restartGameButton.y -= 100;
        restartGameButton.color = Std.int(Std.parseInt(configJson.restartGameButtonColor.replace("#", "0xFF")));
        restartGameButton.label.setFormat(Paths.font(configJson.fontType), 50, Std.int(Std.parseInt(configJson.restartGameButtonTextColor.replace("#", "0xFF"))));
        restartGameButton.label.fieldWidth = restartGameButton.width;
        add(restartGameButton);
        copyLogButton = new FlxButton(0, 0, configJson.copyLogButtonText, function() {
            System.setClipboard(text.text);
        });
        copyLogButton.setGraphicSize(Std.int(FlxG.width/3), 75);
        copyLogButton.updateHitbox();
        copyLogButton.screenCenter();
        copyLogButton.x += FlxG.width/4;
        copyLogButton.label.setFormat(Paths.font(configJson.fontType), 50, Std.int(Std.parseInt(configJson.copyLogButtonTextColor.replace("#", "0xFF"))));
        copyLogButton.label.fieldWidth = copyLogButton.width;
        copyLogButton.color = Std.int(Std.parseInt(configJson.copyLogButtonColor.replace("#", "0xFF")));
        add(copyLogButton);
        exitGameButton = new FlxButton(0, 0, configJson.exitGameButtonText, function() {
            Sys.exit(0);
        });
        exitGameButton.setGraphicSize(Std.int(FlxG.width/3), 75);
        exitGameButton.updateHitbox();
        exitGameButton.screenCenter();
        exitGameButton.x += FlxG.width/4;
        exitGameButton.y += 100;
        exitGameButton.label.setFormat(Paths.font(configJson.fontType), 50, Std.int(Std.parseInt(configJson.exitGameButtonTextColor.replace("#", "0xFF"))));
        exitGameButton.label.fieldWidth = exitGameButton.width;
        exitGameButton.color = Std.int(Std.parseInt(configJson.exitGameButtonColor.replace("#", "0xFF")));
        add(exitGameButton);
    }
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        if (text.height > FlxG.height)
        {
            //cheap scrolling lol
            scrollText(FlxG.mouse.wheel);
            if (FlxG.keys.justPressed.DOWN) {
                scrollText(-1);
            }
            else if (FlxG.keys.justPressed.UP)
            {
                scrollText(1);
            }
            #if mobile
            scrollText(dge.backend.TouchUtil.scrollSwipe());
            #end
            if (text.y > 0)
            {
                text.y = 0;
            }
            else if (text.y + text.height < FlxG.height)
            {
                text.y = FlxG.height - text.height;
            }
        }
    }
    function getJsonConfig():JsonError
    {
        var fullText:String = '';
        #if MODS_ALLOWED
        if (FileSystem.exists(Paths.modFolders('data/crashConfig.json'))) {
            fullText = File.getContent(Paths.modFolders('data/crashConfig.json'));
        } else if (FileSystem.exists(Paths.externalPreloadPath('data/crashConfig.json'))) {
            fullText = File.getContent(Paths.externalPreloadPath('data/crashConfig.json'));
        } else {
            fullText = Assets.getText(Paths.getPreloadPath('data/crashConfig.json'));
        }
        #else
        fullText = Assets.getText(Paths.getPreloadPath('data/crashConfig.json'));
        #end
        if (fullText.length > 0) {
            var parsed = Json.parse(fullText);
            var jsonConfig:JsonError = {
                background: parsed.background != null ? parsed.background : defaultJson.background,
                background_dark: parsed.background_dark != null ? parsed.background_dark : defaultJson.background_dark,
                exitGameButtonColor: parsed.exitGameButtonColor != null ? parsed.exitGameButtonColor : defaultJson.exitGameButtonColor,
                restartGameButtonColor: parsed.restartGameButtonColor != null ? parsed.restartGameButtonColor : defaultJson.restartGameButtonColor,
                copyLogButtonColor: parsed.copyLogButtonColor != null ? parsed.copyLogButtonColor : defaultJson.copyLogButtonColor,
                errorTextColor: parsed.errorTextColor != null ? parsed.errorTextColor : defaultJson.errorTextColor,
                exitGameButtonTextColor: parsed.exitGameButtonTextColor != null ? parsed.exitGameButtonTextColor : defaultJson.exitGameButtonTextColor,
                restartGameButtonTextColor: parsed.restartGameButtonTextColor != null ? parsed.restartGameButtonTextColor : defaultJson.restartGameButtonTextColor,
                copyLogButtonTextColor: parsed.copyLogButtonTextColor != null ? parsed.copyLogButtonTextColor : defaultJson.copyLogButtonTextColor,
                exitGameButtonText: parsed.exitGameButtonText != null ? parsed.exitGameButtonText : defaultJson.exitGameButtonText,
                restartGameButtonText: parsed.restartGameButtonText != null ? parsed.restartGameButtonText : defaultJson.restartGameButtonText,
                copyLogButtonText: parsed.copyLogButtonText != null ? parsed.copyLogButtonText : defaultJson.copyLogButtonText,
                fontType: parsed.fontType != null ? parsed.fontType : defaultJson.fontType,
                errorMessage: parsed.errorMessage != null ? parsed.errorMessage : defaultJson.errorMessage
            };
            return jsonConfig;
        }
        return defaultJson;
    }
    function scrollText(value:Float) {
        if (value < 0 && text.y + text.height > FlxG.height)
            {
                text.y -= 20;
            }
            else if (value > 0 && text.y < 0)
            {
                text.y += 20;
            }
    }
}