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
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.FlxGamepad;
import flixel.graphics.FlxGraphic;

import dge.input.device.GamepadControls;

using StringTools;

class GamepadControlsSubState extends MusicBeatSubstate {
	private static var curSelected:Int = 2;
	private static var curAlt:Bool = false;

	private static var defaultKey:String = 'Reset to Default Buttons';
	private var bindLength:Int = 0;
	#if mobile
	private var touch:TouchUtil = new TouchUtil();
	#end

	var optionShit:Array<Dynamic> = [
		['NOTES'],
		['4 KEY'],
		['Left', 'note_left'],
		['Down', 'note_down'],
		['Up', 'note_up'],
		['Right', 'note_right'],
		[''],
		['1 KEY'],
		['Center', 'note_1K_space'],
		[''],
		['2 KEY'],
		['Left', 'note_2K_left'],
		['Right', 'note_2K_right'],
		[''],
		['3 KEY'],
		['Left', 'note_3K_left'],
		['Center', 'note_3K_space'],
		['Right', 'note_3K_right'],
		[''],
		['5 KEY'],
		['Left', 'note_5K_left'],
		['Down', 'note_5K_down'],
		['Center', 'note_5K_space'],
		['Up', 'note_5K_up'],
		['Right', 'note_5K_right'],
		[''],
		['6 KEY'],
		['Left', 'note_6K_left'],
		['Down', 'note_6K_down'],
		['Right', 'note_6K_right'],
		['Left 2', 'note_6K_left2'],
		['Up', 'note_6K_up'],
		['Right 2', 'note_6K_right2'],
		[''],
		['7 KEY'],
		['Left', 'note_7K_left'],
		['Down', 'note_7K_down'],
		['Right', 'note_7K_right'],
		['Center', 'note_7K_space'],
		['Left 2', 'note_7K_left2'],
		['Up', 'note_7K_up'],
		['Right 2', 'note_7K_right2'],
		[''],
		['8 KEY'],
		['Left', 'note_8K_left'],
		['Down', 'note_8K_down'],
		['Up', 'note_8K_up'],
		['Right', 'note_8K_right'],
		['Left 2', 'note_8K_left2'],
		['Down 2', 'note_8K_down2'],
		['Up 2', 'note_8K_up2'],
		['Right 2', 'note_8K_right2'],
		[''],
		['9 KEY'],
		['Left', 'note_9K_left'],
		['Down', 'note_9K_down'],
		['Up', 'note_9K_up'],
		['Right', 'note_9K_right'],
		['Center', 'note_9K_space'],
		['Left 2', 'note_9K_left2'],
		['Down 2', 'note_9K_down2'],
		['Up 2', 'note_9K_up2'],
		['Right 2', 'note_9K_right2'],
		[''],
		['UI'],
		['Left', 'ui_left'],
		['Down', 'ui_down'],
		['Up', 'ui_up'],
		['Right', 'ui_right'],
		[''],
		['Reset', 'reset'],
		['Accept', 'accept'],
		['Back', 'back'],
		['Pause', 'pause'],
		[''],
		['DEBUG'],
		['Key 1', 'debug_1'],
		['Key 2', 'debug_2']
	];

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpInputs:Array<AttachedText> = [];
	private var grpInputsAlt:Array<AttachedText> = [];
	var rebindingKey:Bool = false;
	var nextAccept:Int = 5;

	public function new() {
		super();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		CoolUtil.fitBackground(bg);
		bg.antialiasing = true;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		optionShit.push(['']);
		optionShit.push([defaultKey]);

		for (i in 0...optionShit.length) {
			var isCentered:Bool = false;
			var isDefaultKey:Bool = (optionShit[i][0] == defaultKey);
			if(unselectableCheck(i, true)) {
				isCentered = true;
			}

			var optionText:Alphabet = new Alphabet(125 + (CoolUtil.getXFrom1280P()), 300, optionShit[i][0], (!isCentered || isDefaultKey));
			optionText.isMenuItem = true;
			if(isCentered) {
				optionText.screenCenter(X);
				optionText.y -= 55;
				optionText.startPosition.y -= 55;
			}
			optionText.changeX = false;
			optionText.distancePerItem.y = 60;
			optionText.targetY = i - curSelected;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(!isCentered) {
				addBindTexts(optionText, i);
				bindLength++;
				if(curSelected < 0) curSelected = i;
			}
		}
		changeSelection();
	}

	var leaving:Bool = false;
	var bindingTime:Float = 0;
    var isRebind:Bool = false;//just prevent update bug
	override function update(elapsed:Float) {
		if(!rebindingKey) {
			if (controls.UI_UP_P #if mobile || touch.swipeUp() #end) {
				changeSelection(-1);
			}
			if (controls.UI_DOWN_P #if mobile || touch.swipeDown() #end) {
				changeSelection(1);
			}
			if ((controls.UI_LEFT_P #if mobile || touch.swipeLeft() #end) || (controls.UI_RIGHT_P #if mobile || touch.swipeRight() #end)) {
				changeAlt();
			}

			if (controls.BACK #if android || FlxG.android.justPressed.BACK #end) {
				GamepadControls.saveButtonbind();
				close();
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
            var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if(controls.ACCEPT && nextAccept <= 0) {
				if(optionShit[curSelected][0] == defaultKey) {
					GamepadControls.buttonBinds = GamepadControls.defaultButtons.copy();
					reloadKeys();
					changeSelection();
					FlxG.sound.play(Paths.sound('confirmMenu'));
				} else if(!unselectableCheck(curSelected) && gamepad != null) {
                    isRebind = true;
					bindingTime = 0;
					rebindingKey = true;
					if (curAlt) {
						grpInputsAlt[getInputTextNum()].alpha = 0;
					} else {
						grpInputs[getInputTextNum()].alpha = 0;
					}
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
		} else {
            if (isRebind) {
                super.update(elapsed);
                isRebind = false;
                return;
            }
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
			if (gamepad != null) {
				var buttonPressed:Int = gamepad.firstJustPressedID();
				if (buttonPressed >= -1 && gamepad.justPressed.ANY) {
					var buttonsArrayNew:Array<FlxGamepadInputID> = GamepadControls.buttonBinds.get(optionShit[curSelected][1]);
					if (buttonsArrayNew == null) buttonsArrayNew = [NONE, NONE];

					buttonsArrayNew[curAlt ? 1 : 0] = buttonPressed;

					var opposite:Int = (curAlt ? 0 : 1);
					if(buttonsArrayNew[opposite] == buttonsArrayNew[1 - opposite]) {
						buttonsArrayNew[opposite] = NONE;
					}
					
					GamepadControls.buttonBinds.set(optionShit[curSelected][1], buttonsArrayNew);
					GamepadControls.saveButtonbind();

					reloadKeys();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					rebindingKey = false;
				}
			}
			bindingTime += elapsed;
			if(bindingTime > 5) {
				if (curAlt) {
					grpInputsAlt[curSelected].alpha = 1;
				} else {
					grpInputs[curSelected].alpha = 1;
				}
				FlxG.sound.play(Paths.sound('scrollMenu'));
				rebindingKey = false;
				bindingTime = 0;
			}
		}

		if(nextAccept > 0) {
			nextAccept -= 1;
		}
		super.update(elapsed);
	}

	function getInputTextNum() {
		var num:Int = 0;
		for (i in 0...curSelected) {
			if(optionShit[i].length > 1) {
				num++;
			}
		}
		return num;
	}
	
	function changeSelection(change:Int = 0) {
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = optionShit.length - 1;
			if (curSelected >= optionShit.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var bullShit:Int = 0;

		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.6;
		}
		for (i in 0...grpInputsAlt.length) {
			grpInputsAlt[i].alpha = 0.6;
		}

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
					if(curAlt) {
						for (i in 0...grpInputsAlt.length) {
							if(grpInputsAlt[i].sprTracker == item) {
								grpInputsAlt[i].alpha = 1;
								break;
							}
						}
					} else {
						for (i in 0...grpInputs.length) {
							if(grpInputs[i].sprTracker == item) {
								grpInputs[i].alpha = 1;
								break;
							}
						}
					}
				}
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	function changeAlt() {
		curAlt = !curAlt;
		for (i in 0...grpInputs.length) {
			if(grpInputs[i].sprTracker == grpOptions.members[curSelected]) {
				grpInputs[i].alpha = 0.6;
				if(!curAlt) {
					grpInputs[i].alpha = 1;
				}
				break;
			}
		}
		for (i in 0...grpInputsAlt.length) {
			if(grpInputsAlt[i].sprTracker == grpOptions.members[curSelected]) {
				grpInputsAlt[i].alpha = 0.6;
				if(curAlt) {
					grpInputsAlt[i].alpha = 1;
				}
				break;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}

	private function unselectableCheck(num:Int, ?checkDefaultKey:Bool = false):Bool {
		if(optionShit[num][0] == defaultKey) {
			return checkDefaultKey;
		}
		return optionShit[num].length < 2 && optionShit[num][0] != defaultKey;
	}

	private function addBindTexts(optionText:Alphabet, num:Int) {
		var buttons:Array<FlxGamepadInputID> = GamepadControls.buttonBinds.get(optionShit[num][1]);
		if (buttons == null) buttons = [NONE, NONE];

		var text1 = new AttachedText(getButtonName(buttons[0]), 400, -55);
		text1.setPosition(optionText.x + 400, optionText.y - 55);
		text1.sprTracker = optionText;
		grpInputs.push(text1);
		add(text1);

		var text2 = new AttachedText(getButtonName(buttons[1]), 800, -55);
		text2.setPosition(optionText.x + 800, optionText.y - 55);
		text2.sprTracker = optionText;
		grpInputsAlt.push(text2);
		add(text2);
	}

	private function getButtonName(button:FlxGamepadInputID):String {
        if (button == NONE) return "NONE";
        return shortenButtonName(button.toString());
    }

    public static function shortenButtonName(name:String):String {
        if (name == null || name == "" || name == "NONE") return "---";

        var formatted:String = name.toUpperCase();

        // shortened gamepad key
        formatted = formatted.replace("LEFT_STICK_DIGITAL_", "LS_");
        formatted = formatted.replace("RIGHT_STICK_DIGITAL_", "RS_");
        formatted = formatted.replace("LEFT_SHOULDER", "LB");
        formatted = formatted.replace("RIGHT_SHOULDER", "RB");
        formatted = formatted.replace("LEFT_TRIGGER", "LT");
        formatted = formatted.replace("RIGHT_TRIGGER", "RT");
        formatted = formatted.replace("LEFT_STICK_CLICK", "LS_CLK");
        formatted = formatted.replace("RIGHT_STICK_CLICK", "RS_CLK");
        formatted = formatted.replace("DPAD_", "DP-");

        return formatted;
    }

	function reloadKeys() {
		while(grpInputs.length > 0) {
			var item:AttachedText = grpInputs[0];
			item.kill();
			grpInputs.remove(item);
			item.destroy();
		}
		while(grpInputsAlt.length > 0) {
			var item:AttachedText = grpInputsAlt[0];
			item.kill();
			grpInputsAlt.remove(item);
			item.destroy();
		}

		// trace('Reloaded gamepad buttons: ' + GamepadControls.buttonBinds);

		for (i in 0...grpOptions.length) {
			if(!unselectableCheck(i, true)) {
				addBindTexts(grpOptions.members[i], i);
			}
		}

		var bullShit:Int = 0;
		for (i in 0...grpInputs.length) {
			grpInputs[i].alpha = 0.6;
		}
		for (i in 0...grpInputsAlt.length) {
			grpInputsAlt[i].alpha = 0.6;
		}

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
					if(curAlt) {
						for (i in 0...grpInputsAlt.length) {
							if(grpInputsAlt[i].sprTracker == item) {
								grpInputsAlt[i].alpha = 1;
							}
						}
					} else {
						for (i in 0...grpInputs.length) {
							if(grpInputs[i].sprTracker == item) {
								grpInputs[i].alpha = 1;
							}
						}
					}
				}
			}
		}
	}
}