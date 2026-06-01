package dge.states;
//only for android build

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import dge.obj.ui.AlphabetPath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import sys.FileSystem as Synths;
import sys.io.File as Kali;
import dge.backend.StorageManager;
using StringTools;
import dge.obj.ui.StorageIcon;

#if mobile
import dge.obj.mobile.VirtualButton;
#end

class FilePickerState extends MusicBeatSubstate
{
    public var filePath:String = #if android StorageManager.getAndroidStorage() #else Synths.absolutePath('./') #end;
    var grpFileList:FlxTypedGroup<AlphabetPath>;
    var grpIconList:FlxTypedGroup<StorageIcon>;
    var pathText:FlxText;
    var curSelect:Int = 0;
    public var callback:Void->Void;
    var textLoad:FlxText;
    #if android
    var curNest:Int = 0;
    private var touch:TouchUtil = new TouchUtil();
    private var leftButton:VirtualButton;
    private var enterButton:VirtualButton;
    private var quitButton:VirtualButton;
    #end
    var antiSpamTimer:Float = 0.2;//prevent accident press when enter state

    public function new() {
        super();
    }

    override function create() {
        super.create();
        if (FlxG.save.data.lastPathPick != null && Synths.exists(FlxG.save.data.lastPickPath)) {
            filePath = FlxG.save.data.lastPickPath;
        }
        curNest = filePath.split('/').length - #if android StorageManager.getAndroidStorage() #else Synths.absolutePath('./') #end.split('/').length;
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        CoolUtil.fitBackground(bg);
        bg.color = 0xff800000;
        add(bg);
        grpFileList = new FlxTypedGroup<AlphabetPath>();
        add(grpFileList);
        grpIconList = new FlxTypedGroup<StorageIcon>();
        add(grpIconList);
        pathText = new FlxText(0, 0, FlxG.width, "", 50);
        pathText.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, LEFT);
        add(pathText);
        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);
        textLoad = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "% Item Loaded", 16);
		textLoad.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		add(textLoad);
        reloadList();
        #if mobile
        leftButton = new VirtualButton(0, FlxG.height-(125+16), 'left');
        leftButton.screenCenter(X);
        leftButton.x -= 125;
        add(leftButton);
        enterButton = new VirtualButton(leftButton.x+125, leftButton.y, 'enter');
        add(enterButton);
        quitButton = new VirtualButton(enterButton.x+125, enterButton.y, 'back');
        add(quitButton);
        #end
    }

    override function update(e:Float) {
        super.update(e);
        if (antiSpamTimer > 0) {
            antiSpamTimer -= e;
            if (antiSpamTimer < 0) antiSpamTimer = 0;
        }
        if (antiSpamTimer <=0) {//i just found it has chance to press double
            if (FlxG.keys.justPressed.ENTER #if mobile || enterButton.justPressed #end) enterPath();
            if (FlxG.keys.justPressed.LEFT #if mobile || leftButton.justPressed #end) backPath();
            if (FlxG.keys.justPressed.ESCAPE #if mobile || quitButton.justPressed #end) close();
        }
        //there "essentially" for navigation
        if (controls.UI_UP_P) {
            changeSelect(-1);
        }
        if (controls.UI_DOWN_P) {
            changeSelect(1);
        }
        if(FlxG.mouse.wheel != 0)
            {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
            changeSelect(-FlxG.mouse.wheel, false);
        }
        #if mobile
        var swipeWheel = touch.scrollSwipe();
        if(swipeWheel != 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
            changeSelect(-swipeWheel, false);
        }
        #end
    }

    function backPath() {
        #if android if (curNest > 0) {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            curNest--; #end
            var arrayPath:Array<String> = filePath.split('/');
            arrayPath.pop();
            var newPath = arrayPath.join('/');
            filePath = newPath;
            reloadList();
            antiSpamTimer = 0.2;//prevent accidental double press
        #if android } #end
    }

    function enterPath() {
        if (grpFileList.length > 0) {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            #if android curNest++; #end
            var tempPath = filePath;
            filePath += '/' + grpFileList.members[curSelect].text;
            if (Synths.exists(filePath)) {//i know what your doing, a experiement user
                if (grpFileList.members[curSelect].isFile) {
                    if (callback != null) callback();
                    FlxG.save.data.lastPickPath = tempPath;
                    FlxG.save.flush();
                    close();
                } else {
                    reloadList();
                }
            } else {
                lime.app.Application.current.window.alert('Missing file: ' + filePath + '.' + (FlxG.random.bool(0.1) ? ' .Are you deleted the file after load?' : ''), 'File Picker');
                filePath = tempPath;
                curNest--;//cancel
                reloadList();
            }
            antiSpamTimer = 0.2;//prevent accidental double press
        }
    }

    function changeSelect(num:Int = 0, playSound:Bool = true) {
        if (playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
        if (num == 0 || grpFileList.length < 1) return;
        curSelect += num;
        if (curSelect < 0) curSelect = grpFileList.length - 1;
        if (curSelect >= grpFileList.length) curSelect = 0;
        var uiArr:Int = 0;
        for (item in grpFileList.members) {
            item.targetY = uiArr - curSelect;
            uiArr++;
            item.alpha = 0.6;
            if (item.targetY == 0) item.alpha = 1;
        }
    }

    function reloadList():Void {
        curSelect = 0;
        while (grpFileList.length > 0) {
            var obj = grpFileList.members[0];
            obj.destroy();
            grpFileList.remove(obj, true);
        }
        while (grpIconList.length > 0) {
            var obj = grpIconList.members[0];
            obj.destroy();
            grpIconList.remove(obj, true);
        }
        pathText.text = filePath.replace('/', '>');
        if (Synths.exists(filePath)) {
            try {
                var fileList =  Synths.readDirectory(filePath);
                if (fileList.length > 0) {
                    fileList.sort(function(a, b) {
                        //uhh idk how this sort work
                        var aIsDir = Synths.isDirectory(filePath + '/' + a);
                        var bIsDir = Synths.isDirectory(filePath + '/' + b);
                        if (aIsDir && !bIsDir) return -1;
                        if (!aIsDir && bIsDir) return 1;
                        return Reflect.compare(a.toLowerCase(), b.toLowerCase());
                    });
                    for (file in 0...fileList.length) {
                        var fullPath = filePath + '/' + fileList[file];
                        var makeText = new AlphabetPath(30, 320, fileList[file], true, !Synths.isDirectory(fullPath));
                        makeText.isMenuItem = true;
                        makeText.targetY = file - curSelect;
                        grpFileList.add(makeText);
                        var maxWidth = 980*(FlxG.width/1280);//adapt any resolution ig
                        if (makeText.width > maxWidth)
                        {
                            makeText.scaleX = maxWidth / makeText.width;
                        }
                        //makeText.snapToPosition();
                        //icon
                        var icon = new StorageIcon(fullPath);
                        icon.sprTracker = makeText;
                        icon.snapIconToSprTracker();
                        grpIconList.add(icon);
                    }
                    var uiArr:Int = 0;
                    for (item in grpFileList.members) {
                        item.targetY = uiArr - curSelect;
                        uiArr++;
                        item.alpha = 0.6;
                        if (item.targetY == 0) item.alpha = 1;
                    }
                }
                textLoad.text = fileList.length + ' Item Loaded';
            } catch (e:Dynamic) {
                trace('error occured try access file path.(' + e + ')');
                lime.app.Application.current.window.alert('cannot access "' + filePath + '" path. (' + e + ').', 'File Picker');
                filePath = #if android StorageManager.getAndroidStorage() #else Synths.absolutePath('./') #end;
                curNest--;
                reloadList();
            }
        }
    }
}