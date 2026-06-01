package dge.obj.ui;

import flixel.FlxSprite;
import sys.FileSystem as Synths;
using StringTools;

class StorageIcon extends FlxSprite
{
    public var sprTracker:FlxSprite;
    //i would like show image in thumbnail when png but is kinda bad idea when 1 folder has lot differ image(ram overload)
    //common only(hopefully can json customized)
   var spriteExtensions:Array<Array<String>>= [
        ['png', 'ui/picture'],
        ['jpg', 'ui/picture'],
        ['jpeg', 'ui/picture'],
        ['json', 'ui/json'],//it supposes name 'code' but i lazy to change name
        ['xml', 'ui/json'],
        ['lua', 'ui/json'],
        ['zip', 'ui/zip']
   ];

    public function new(fullPath:String = '') {
        super(0, 0);
        var image = 'ui/file';
        for (ext in spriteExtensions) {
            if (fullPath.toLowerCase().endsWith('.' + ext[0].toLowerCase())) {
                image = ext[1];
                break;
            }
        }
        loadGraphic(Paths.image(!Synths.isDirectory(fullPath) ? image : 'ui/folder'));
        setGraphicSize(150, 150);
        updateHitbox();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if (sprTracker != null) {
            setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
            alpha = sprTracker.alpha;
        }
    }
    public function snapIconToSprTracker() {//instant snap to sprTracker
        if (sprTracker != null) {
            setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
            alpha = sprTracker.alpha;
        }
    }
}