package options;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import NoteSprite;
import Controls;

class NotesColorSubState extends MusicBeatSubstate
{
    private var noteArray:FlxTypedGroup<NoteSprite>;
    private var noteArrayY:FlxTypedGroup<NoteSprite>;
    private var curSelect:Int = 0;
    private var curSelectY:Int = 0;
    private var hoverNote:FlxSprite;
    private var hoverNoteY:FlxSprite;
    private var txtRed:FlxText;
    private var txtGreen:FlxText;
    private var txtBlue:FlxText;
    var isChangeColor:Bool = false;
    private var curSelectColor:Int = 0;
    var coolDo = 5;
    var holdTimer:Float = 0;
    private static var defaultSetting:Array<Array<Array<Int>>> = [
		//R(RGB), G(RGB), B(RGB)
		[ [ 194, 75,  153 ], [ 255, 255, 255 ], [ 60, 31, 86 ] ],
		[ [ 0, 255, 255 ], [ 255, 255, 255 ], [ 21, 66, 183 ] ],
		[ [ 18, 250, 5 ], [ 255, 255, 255 ], [ 10, 68, 71 ] ],
		[ [ 249, 57, 63 ], [ 255, 255, 255 ], [ 101, 16, 56 ] ] 
	];
    public function new() {
        super();
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
		bg.color = 0xFFea71fd;
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
        hoverNote = new FlxSprite().makeGraphic(112, 112, FlxColor.BLACK);
        hoverNote.alpha = 0.5;
        add(hoverNote);
        hoverNoteY = new FlxSprite().makeGraphic(112, 112, FlxColor.BLACK);
        hoverNoteY.alpha = 0.5;
        add(hoverNoteY);
        noteArray = new FlxTypedGroup<NoteSprite>();
        noteArrayY = new FlxTypedGroup<NoteSprite>();
        for (i in 0...ClientPrefs.arrowRGB.length) {
            var note:NoteSprite = new NoteSprite(((FlxG.width/2)-(112*2))+(i*112), 10, ClientPrefs.dflnoteskin, i);
            noteArray.add(note);
        }
        add(noteArray);
        for (i in 0...3) {
            var note:NoteSprite = new NoteSprite(FlxG.width-200, ((FlxG.height/2)-112)+(i*112), ClientPrefs.dflnoteskin, curSelect);
            if (i == 0) {
                note.RGBPalette.r = noteArray.members[curSelect].RGBPalette.r;
                note.RGBPalette.g = 0x000000;
                note.RGBPalette.b = 0x000000;
            }
            if (i == 1) {
                note.RGBPalette.r = 0x000000;
                note.RGBPalette.g = noteArray.members[curSelect].RGBPalette.g;
                note.RGBPalette.b = 0x000000;
            }
            if (i == 2) {
                note.RGBPalette.r = 0x000000;
                note.RGBPalette.g = 0x000000;
                note.RGBPalette.b = noteArray.members[curSelect].RGBPalette.b;
            }
            noteArrayY.add(note);
        }
        add(noteArrayY);
        hoverNote.x = noteArray.members[curSelect].x;
        hoverNote.y = noteArray.members[curSelect].y;
        hoverNoteY.x = noteArrayY.members[curSelectY].x;
        hoverNoteY.y = noteArrayY.members[curSelectY].y;
        txtRed = new FlxText(0, FlxG.height/2);
        txtRed.text = "Red: 0";
        txtRed.size = 50;
        txtGreen = new FlxText(0, (FlxG.height/2)+75);
        txtGreen.text = "Green: 0";
        txtGreen.size = 50;
        txtBlue = new FlxText(0, (FlxG.height/2)+150);
        txtBlue.text = "Blue: 0";
        txtBlue.size = 50;
        add(txtRed);
        add(txtGreen);
        add(txtBlue);
    }
    override public function update(e:Float) {
        if (isChangeColor) {
            if (controls.RESET) {//reset each notes
				ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] = defaultSetting[curSelect][curSelectY][curSelectColor];
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
            if (controls.BACK) {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                isChangeColor = false;
            }
            if (controls.UI_RIGHT_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] += 1;
                if (ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] > 255) {
                    ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] = 0;
                }
            } else if (controls.UI_LEFT_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] -= 1;
                if (ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] < 0) {
                    ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] = 255;
                }
            }
            if (controls.UI_RIGHT) {
                holdTimer += e;
                if (holdTimer > 0.5) {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] += 1;
                    if (ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] > 255) {
                        ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] = 0;
                    }
                }
            } else if (controls.UI_LEFT) {
                holdTimer += e;
                if (holdTimer > 0.5) {
                    FlxG.sound.play(Paths.sound('scrollMenu'));
                    ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] -= 1;
                    if (ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] < 0) {
                        ClientPrefs.arrowRGB[curSelect][curSelectY][curSelectColor] = 255;
                    }
                }
            } else {
                if (holdTimer > 0) {
                    holdTimer = 0;
                }
            }
            if (controls.UI_UP_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelectColor -= 1;
                if (curSelectColor < 0) {
                    curSelectColor = 2;
                }
            } else if (controls.UI_DOWN_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelectColor += 1;
                if (curSelectColor > 2) {
                    curSelectColor = 0;
                }
            }
            if (curSelectColor == 0) {
                txtRed.color = 0xffffff;
                txtGreen.color = 0x808080;
                txtBlue.color = 0x808080;
            } else if (curSelectColor == 1) {
                txtRed.color = 0x808080;
                txtGreen.color = 0xffffff;
                txtBlue.color = 0x808080;
            } else if (curSelectColor == 2) {
                txtRed.color = 0x808080;
                txtGreen.color = 0x808080;
                txtBlue.color = 0xffffff;
            } else {
                //unkno var
                txtRed.color = 0x808080;
                txtGreen.color = 0x808080;
                txtBlue.color = 0x808080;
            }
        } else {
            if (controls.RESET) {
				ClientPrefs.arrowRGB = defaultSetting;
				FlxG.sound.play(Paths.sound('cancelMenu'));
			}
            if (controls.ACCEPT && coolDo <= 0) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                isChangeColor = true;
            }
            if (controls.BACK) {
                FlxG.sound.play(Paths.sound('cancelMenu'));
                ClientPrefs.saveSettings();
                close();
            }
            if (controls.UI_RIGHT_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelect += 1;
                if (curSelect >= noteArray.length) {
                    curSelect = 0;
                }
            } else if (controls.UI_LEFT_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelect -= 1;
                if (curSelect < 0) {
                    curSelect = noteArray.length-1;
                }
            }
            if (controls.UI_UP_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelectY -= 1;
                if (curSelectY < 0) {
                    curSelectY = 2;
                }
            } else if (controls.UI_DOWN_P) {
                FlxG.sound.play(Paths.sound('scrollMenu'));
                curSelectY += 1;
                if (curSelectY > 2) {
                    curSelectY = 0;
                }
            }
            txtRed.color = 0xffffff;
            txtGreen.color = 0xffffff;
            txtBlue.color = 0xffffff;
        }
        hoverNote.x = noteArray.members[curSelect].x;
        hoverNoteY.y = noteArrayY.members[curSelectY].y;
        for (i in 0...ClientPrefs.arrowRGB.length) {
            noteArray.members[i].RGBPalette.r = FlxColor.fromRGB(ClientPrefs.arrowRGB[i][0][0], ClientPrefs.arrowRGB[i][0][1], ClientPrefs.arrowRGB[i][0][2]);
            noteArray.members[i].RGBPalette.g = FlxColor.fromRGB(ClientPrefs.arrowRGB[i][1][0], ClientPrefs.arrowRGB[i][1][1], ClientPrefs.arrowRGB[i][1][2]);
            noteArray.members[i].RGBPalette.b = FlxColor.fromRGB(ClientPrefs.arrowRGB[i][2][0], ClientPrefs.arrowRGB[i][2][1], ClientPrefs.arrowRGB[i][2][2]);
        }
        for (i in 0...noteArrayY.length) {
            noteArrayY.members[i].animation.play(Std.string(curSelect));
            if (i == 0) {
                noteArrayY.members[i].RGBPalette.r = noteArray.members[curSelect].RGBPalette.r;
                noteArrayY.members[i].RGBPalette.g = 0x000000;
                noteArrayY.members[i].RGBPalette.b = 0x000000;
            }
            if (i == 1) {
                noteArrayY.members[i].RGBPalette.r = 0x000000;
                noteArrayY.members[i].RGBPalette.g = noteArray.members[curSelect].RGBPalette.g;
                noteArrayY.members[i].RGBPalette.b = 0x000000;
            }
            if (i == 2) {
                noteArrayY.members[i].RGBPalette.r = 0x000000;
                noteArrayY.members[i].RGBPalette.g = 0x000000;
                noteArrayY.members[i].RGBPalette.b = noteArray.members[curSelect].RGBPalette.b;
            }
        }
        txtRed.text = "Red " + ClientPrefs.arrowRGB[curSelect][curSelectY][0];
        txtGreen.text = "Green " + ClientPrefs.arrowRGB[curSelect][curSelectY][1];
        txtBlue.text = "Blue " + ClientPrefs.arrowRGB[curSelect][curSelectY][2];
        if (coolDo > 0) {
            coolDo -= 1;
        }
        super.update(e);
    }
}