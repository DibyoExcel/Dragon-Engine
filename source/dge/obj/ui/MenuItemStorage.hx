package dge.obj.ui;
//menu item for file picker thing

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import dge.obj.ui.StorageIcon;

class MenuItemStorage extends FlxSpriteGroup {
    //panel bg
    var iconPanel:NinesliceSprite;
    var songPanel:NinesliceSprite;
    //front
    var icon:StorageIcon;
    var songName:FlxText;
    public var startPoint:FlxPoint = new FlxPoint(0, 0);
    public var distancePerItem:FlxPoint = new FlxPoint(0, 200);
    public var targetY:Int = 0;
    public var isFile:Bool = false;
    public var textPath:String = '';
    
    
    public function new(x:Float, y:Float, title:String = '?????', icon:String, texture:String, isFile:Bool = false) {
        super(0, 0);
        startPoint.x = x;
        startPoint.y = y;
        iconPanel = new NinesliceSprite(0, 0, 150, 150, texture);
        add(iconPanel);
        songPanel = new NinesliceSprite(iconPanel.x + iconPanel.width + 25, 0, Std.int(870*(FlxG.width/1280)), 150, texture);
        add(songPanel);
        this.icon = new StorageIcon(icon);
        this.icon.setGraphicSize(105, 105);
        this.icon.updateHitbox();
        CoolUtil.alignItem(iconPanel, this.icon);
        add(this.icon);
        songName = new FlxText(0, 0, 0, title, 60);
        songName.setFormat(Paths.font('vcr.ttf'), 60, (ClientPrefs.darkmode ? FlxColor.WHITE : FlxColor.BLACK), LEFT);
        cutText(songName, title, songPanel.width-40);
        CoolUtil.alignItem(songPanel, songName, MIDDLE_LEFT);
        songName.x += 20;
        add(songName);
        this.isFile = isFile;
        textPath = title;
        snapToPosition();
    }
    function cutText(txt:FlxText, input:String, maxWidth:Float = 0):String {
        if (txt == null) return "...";
        if (maxWidth <= 0) {
            txt.text = input;
            return txt.text;
        } else {
            txt.text = input;
            if (txt.textField.textWidth <= maxWidth) {
                return txt.text;
            }
            var og = input;
            while (og.length > 0) {
                og = og.substr(0, og.length - 1);
                txt.text = og + "...";
                if (txt.textField.textWidth <= maxWidth) {
                    return txt.text;
                }
            }
        }
        return "...";
    }
    override function update(e:Float) {
        var lerpVal:Float = CoolUtil.boundTo(e * 9.6, 0, 1);
        x = FlxMath.lerp(x, ((-Math.abs(targetY)) * distancePerItem.x) + startPoint.x, lerpVal);
        y = FlxMath.lerp(y, (targetY * distancePerItem.y) + startPoint.y, lerpVal);
        super.update(e);
    }
    public function snapToPosition() {
        x = ((-Math.abs(targetY)) * distancePerItem.x) + startPoint.x;
        y = (targetY * distancePerItem.y) + startPoint.y;
    }
}