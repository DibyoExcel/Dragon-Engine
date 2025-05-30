package;

import flixel.FlxSprite;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var winIcon:Bool = false;
	public var isCustom:Bool = false;//enable this if you want custom change icon system to your own
	public var fullIcon(default, set):Bool = false;



	public function new(char:String = 'bf', isPlayer:Bool = false, full:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char, full);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 12, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	private var iconOffsets:Array<Float> = [0, 0];
	public function changeIcon(char:String, full:Bool = false) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			loadGraphic(file); //Load stupidly first for getting the file size
			if (!full) {

				var frameArray:Array<Int> = [];
				var flipbook:Int = Math.round(width/height);//basicly flipbook from minecraft texture pack
				loadGraphic(file, true, Math.floor(width / flipbook), Math.floor(height)); //Then load it fr
				for (i in 0...flipbook) {
					frameArray.push(i);
				}
				iconOffsets[0] = (width - 150) / flipbook;
				iconOffsets[1] = (width - 150) / flipbook;
				updateHitbox();
				animation.add(char, frameArray, 0, false, isPlayer);
				animation.play(char);
				if (flipbook >= 3) {//for win icon //and when more than 3 you might can make weird stuff...but required lua
					this.winIcon = true;
				} else {
					this.winIcon = false;
				}
			}
			this.char = char;

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) {
				antialiasing = false;
			}
		}
	}

	override function updateHitbox()
	{
		super.updateHitbox();
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function getCharacter():String {
		return char;
	}

	function set_fullIcon(value:Bool):Bool {
		if (fullIcon != value) {
			fullIcon = value;
			changeIcon(char, value);
		}
		return value;
	}
}
