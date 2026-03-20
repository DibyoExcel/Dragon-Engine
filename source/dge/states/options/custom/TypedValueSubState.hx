package dge.states.options.custom;

import openfl.events.KeyboardEvent;
import dge.states.options.custom.Option;
import dge.states.options.custom.BaseOptionsMenu;
import flixel.FlxG;
import flixel.FlxSprite;
#if mobile
import dge.obj.mobile.VirtualButton;
import dge.backend.TouchUtil;
#end
using StringTools;

class TypedValueSubState extends MusicBeatSubstate
{
    private var optionObject:Option;
    private var instanceTarget:BaseOptionsMenu;
    private var showMinMax:Bool = true;
    private var enterValue:Alphabet;
    private var textTyping:Alphabet;
    private var nextAccept:Float = 5;
    #if mobile
    private var enterButton:VirtualButton;
    private var resetButton:VirtualButton;
    #end

    public function new(instance:BaseOptionsMenu, object:Option) {
        super();
        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        add(bg);
        bg.alpha = 0.75;
        this.instanceTarget = instance;
        this.optionObject = object;
        var getValue = (Std.parseFloat(object.getValue()) * (object.type == 'percent' ? 100 : 1));
        if (object.type == 'stringfree' || object.type == 'hex') {
            showMinMax = false;
            getValue = object.getValue();
        }
        var text = 'Enter Value:';
        if (showMinMax) {
            var hasMin:Bool = false;
            var hasMax:Bool = false;
            if (object.minValue != null) hasMin = true;
            if (object.maxValue != null) hasMax = true;
            if (hasMin && hasMax) {
                text += '\n(MIN: ' + (object.minValue * (object.type == 'percent' ? 100 : 1)) + ', MAX: ' + (object.maxValue * (object.type == 'percent' ? 100 : 1)) + ')';
            } else if (hasMin) {
                text += '\n(MIN: ' + (object.minValue * (object.type == 'percent' ?  100 : 1)) + ')';
            } else {
                text += '\n(MAX: ' + (object.maxValue * (object.type == 'percent' ?  100 : 1)) + ')';
            }
        }
        enterValue = new Alphabet(FlxG.width/2, #if mobile 0 #else 150 #end, text, false);//little bit higher for mobile because soft keyboard
        add(enterValue);
        enterValue.alignment = CENTERED;
        textTyping = new Alphabet(FlxG.width/2, enterValue.y+enterValue.height+15, Std.string(getValue), false);
        add(textTyping);
        textTyping.alignment = CENTERED;
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        FlxG.stage.window.textInputEnabled = true;
        #if mobile
        //move bit up to prevent accident click reset and move left right button
        enterButton = new VirtualButton(0, FlxG.height-375, 'enter');
		add(enterButton);
        resetButton = new VirtualButton(125, FlxG.height-375, 'r');
		add(resetButton);
        #end
        var tip:Alphabet = new Alphabet(FlxG.width/2, FlxG.height, 'Enter To Set\nEsc To Cancel');
        tip.y = FlxG.height - tip.height;
        tip.alignment = CENTERED;
        add(tip);
        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
    function onKeyDown(e:KeyboardEvent) {
        var key:Int = e.keyCode;
        if (key == 8) {
            var text = textTyping.text;
            if (text.length > 0) {
                text = text.substr(0, text.length - 1);
                textTyping.text = text;
                FlxG.sound.play(Paths.sound('cancelMenu'));//also deleted sound
            }
        } else if (key == 16 || key == 17 || key == 220 || key == 27 || key == 13)
        {
            return;
        } else {
            if (e.charCode == 0) {
                return;
            }
            var newText = filter(String.fromCharCode(e.charCode));
            if (optionObject.type == 'hex') {
                if (textTyping.text.length < 6) {
                    textTyping.text += newText;
                } else {
                    textTyping.text = textTyping.text.substr(0, 6);
                }
            } else {
                textTyping.text += newText;
            }
            FlxG.sound.play(Paths.sound('scrollMenu'));//i like each typing make sound lol
        }
    }

    function filter(string:String):String {
        if (optionObject.type == 'int' || optionObject.type == 'percent') {
            if (~/^[0-9]$/.match(string) || (string == '-')) {
                return string;
            }
        } else if (optionObject.type == 'float') {
            if (~/^[0-9]$/.match(string) || (string == '.') || (string == '-')) {
                return string;
            }
        } else if (optionObject.type == 'hex') {
            if (~/^[0-9A-Fa-f]$/.match(string)) {
                return string.toUpperCase();
            }
        } else {
            return string;
        }
        return '';
    }

    override function destroy() {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        super.destroy();
    }
    override function update(e) {
        super.update(e);
        if (nextAccept > 0) {
            nextAccept -= 1;
        }
        if (nextAccept <= 0) {
            #if mobile
            if (TouchUtil.tap()) {
                FlxG.stage.window.textInputEnabled = true;
            }
            #end
            if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justPressed.BACK #end) {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                close();
            }
            if (FlxG.keys.justPressed.ENTER #if mobile || enterButton.justPressed  #end && textTyping.text.trim().length > 0) {
                //done typing
                if (optionObject != null) {
                    if (optionObject.type == 'int') {
                        var valueResult = Std.int(Std.parseFloat(textTyping.text));
                        if (Math.isNaN(valueResult)) {
                            valueResult = optionObject.getValue();
                        }
                        if (optionObject.minValue != null) {
                            var value = Std.int(Std.parseFloat(Std.string(optionObject.minValue)));
                            if (value > valueResult) {
                                valueResult = Std.int(Math.max(valueResult, value));
                            }
                        }
                        if (optionObject.maxValue != null) {
                            var value = Std.int(Std.parseFloat(Std.string(optionObject.maxValue)));
                            if (value < valueResult) {
                                valueResult = Std.int(Math.min(valueResult, value));
                            }
                        }
                        optionObject.setValue(valueResult);
                    } else if (optionObject.type == 'float') {
                        var valueResult = Std.parseFloat(textTyping.text);
                        if (Math.isNaN(valueResult)) {
                            valueResult = optionObject.getValue();
                        }
                        if (optionObject.minValue != null) {
                            var value = Std.parseFloat(Std.string(optionObject.minValue));
                            if (!Math.isNaN(value)) {
                                if (value > valueResult) {
                                    valueResult = Math.max(valueResult, value);
                                }
                            }
                        }
                        if (optionObject.maxValue != null) {
                            var value = Std.parseFloat(Std.string(optionObject.maxValue));
                            if (!Math.isNaN(value)) {
                                if (value < valueResult) {
                                    valueResult = Math.min(valueResult, value);
                                }
                            }
                        }
                        optionObject.setValue(valueResult);
                    } else if (optionObject.type == 'percent') {
                        var valueResult = Std.parseInt(textTyping.text);
                        if (Math.isNaN(valueResult)) {
                            valueResult = optionObject.getValue();
                        }
                        if (optionObject.minValue != null) {
                            var value = Std.int(Std.parseFloat(Std.string(optionObject.minValue))*100);
                            if (value > valueResult) {
                                valueResult = Std.int(Math.max(valueResult, value));
                            }
                        }
                        if (optionObject.maxValue != null) {
                            var value = Std.int(Std.parseFloat(Std.string(optionObject.maxValue))*100);
                            if (value < valueResult) {
                                valueResult = Std.int(Math.min(valueResult, value));
                            }
                        }
                        optionObject.setValue(valueResult / 100);
                    } else {
                        optionObject.setValue(textTyping.text.trim());
                    }
                    instanceTarget.updateTextFrom(optionObject);
                    optionObject.change();
                }
                FlxG.sound.play(Paths.sound('scrollMenu'));
                close();
            } else if (FlxG.keys.justPressed.ENTER #if mobile || enterButton.justPressed  #end && textTyping.text.trim().length < 1) {
                lime.app.Application.current.window.alert('Text cannot be empty.', 'Warning');
            }
            if (controls.RESET #if mobile || resetButton.justPressed #end) {
                if (textTyping != null) {
                    if (optionObject != null) {
                        if (optionObject.type == 'percent') {
                            textTyping.text = Std.string(Std.parseFloat(optionObject.defaultValue)*100);
                        } else {
                            textTyping.text = Std.string(optionObject.defaultValue);
                        }
                    } else {
                        lime.app.Application.current.window.alert('Missing option object.', 'Warning');
                        close();
                    }
                }
            }
        }
    }
    override function close() {
        FlxG.stage.window.textInputEnabled = false; 
        super.close();
    }
}