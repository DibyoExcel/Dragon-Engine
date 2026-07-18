package;

import flixel.FlxSprite;
import flixel.FlxG;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

typedef IconConfig = {
	//cool icon animation config lols
	//using Null<> because haxe didt like check if this value is null or not:/
	netral:Null<StateObject>,
	lose:Null<StateObject>,//optional, if not set, it will be the same as netral
	win:Null<StateObject>//optional, if not set, it will nothing to do(aka netral icon
};

typedef StateObject = {
	xmlName:String,
	offset:Null<Array<Float>>,
	fps:Null<Int>,
	loop:Null<Bool>,
	flipX:Null<Bool>,
	flipY:Null<Bool>
}


class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	private var char:String = '';
	public var winIcon:Bool = false;
	public var isCustom:Bool = false;//enable this if you want custom change icon system to your own
	public var spriteSheet:Bool = false;//becareful set this or else it break icon
	private var offsetMap:Map<String, Array<Float>> = new Map<String, Array<Float>>();
	public var danceEveryNumBeats:Int = 2;//dance every 2 beats by default



	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
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
	public function changeIcon(char:String) {
		if (char == null || char.length < 1) char = 'face';
		if(this.char != char) {
			//reset
			offsetMap = new Map<String, Array<Float>>();
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			if (Paths.fileExists('images/' + name + '.json', TEXT)) spriteSheet = true; else spriteSheet = false;
			if (!spriteSheet) {
				var file:Dynamic = Paths.image(name);
	
				loadGraphic(file); //Load stupidly first for getting the file size
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
			} else {
				//fun fact: the animated icon inspired from RetroSpecter P2(again from this mods) in Catastrofiend song(also is my fav song). and i forgot to put this comment here lol
				//also this enable "if" has json same name besides(idk why i added this comment even though is already in documentation web before this comment)
				var json:String = Paths.getTextFromFile('images/' + name + '.json');
				var data:IconConfig = initJsonLoad(json);//init json data(is already check missing field)
				frames = Paths.getSparrowAtlas(name);
				initFrames(data);//idk but whatever
				animation.play('netral');/*default animation(please dont judge me for this)*/
				iconOffsets[0] = data.netral.offset[0];
				iconOffsets[1] = data.netral.offset[1];
				offsetMap.set('netral', data.netral.offset);
				offsetMap.set('lose', data.lose.offset);
				if (data.win != null) { 
					this.winIcon = true;
					offsetMap.set('win', data.win.offset);
				} else {
					this.winIcon = false;
				}
				updateHitbox();//again to set offset
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
		changeOffsets();
	}

	public function updateHitboxNoOffset()//uh i wonfer if i put super.super.updateHitbox() it will work or not(joke)
	{
		super.updateHitbox();
	}

	public function getCharacter():String {
		return char;
	}
	function initJsonLoad(jsonRaw:String):IconConfig {
		var jsonDataRaw:Dynamic = haxe.Json.parse(jsonRaw);
		var jsonData:IconConfig = cast jsonDataRaw;
		//too much
		if (jsonData.netral == null) {
			//dude why ever create an icon json without netral animation? its required for backup and stuff
			jsonData.netral = {
				xmlName: 'netral',
				offset: [0, 0],
				fps: 24,
				loop: true,
				flipX: false,
				flipY: false
			};
		} else {
			if (jsonData.netral.xmlName == null) jsonData.netral.xmlName = 'netral';
			if (jsonData.netral.offset == null || jsonData.netral.offset.length < 2) jsonData.netral.offset = (jsonData.netral.offset != null && jsonData.netral.offset.length == 1) ? [jsonData.netral.offset[0], jsonData.netral.offset[0]] : [0, 0];//lmao inline abused
			if (jsonData.netral.fps == null) jsonData.netral.fps = 24;
			if (jsonData.netral.loop == null) jsonData.netral.loop = true;
			if (jsonData.netral.flipX == null) jsonData.netral.flipX = false;
			if (jsonData.netral.flipY == null) jsonData.netral.flipY = false;
		}
		if (jsonData.lose == null) {
			jsonData.lose = jsonData.netral;
		} else {
			if (jsonData.lose.xmlName == null) jsonData.lose.xmlName = 'lose';
			if (jsonData.lose.offset == null || jsonData.lose.offset.length < 2) jsonData.lose.offset = (jsonData.lose.offset != null && jsonData.lose.offset.length == 1) ? [jsonData.lose.offset[0], jsonData.lose.offset[0]] : [0, 0];//lmao inline abused
			if (jsonData.lose.fps == null) jsonData.lose.fps = 24;
			if (jsonData.lose.loop == null) jsonData.lose.loop = true;
			if (jsonData.lose.flipX == null) jsonData.lose.flipX = false;
			if (jsonData.lose.flipY == null) jsonData.lose.flipY = false;
		}
		if (jsonData.win != null) {//fix crash when added win field(sowwy)
			if (jsonData.win.xmlName == null) jsonData.win.xmlName = 'win';
			if (jsonData.win.offset == null || jsonData.win.offset.length < 2) jsonData.win.offset = (jsonData.win.offset != null && jsonData.win.offset.length == 1) ? [jsonData.win.offset[0], jsonData.win.offset[0]] : [0, 0];//lmao inline abused
			if (jsonData.win.fps == null) jsonData.win.fps = 24;
			if (jsonData.win.loop == null) jsonData.win.loop = true;
			if (jsonData.win.flipX == null) jsonData.win.flipX = false;
			if (jsonData.win.flipY == null) jsonData.win.flipY = false;
		}
		return jsonData;
	}
	function initFrames(Data:IconConfig):Void {
		var isFlip = isPlayer;
		if (Data.netral.flipX) {
			isFlip = !isFlip;
		}
		animation.addByPrefix('netral', Data.netral.xmlName, Data.netral.fps, (FlxG.state is PlayState ? Data.netral.loop : true), isFlip, Data.netral.flipY);
		var isFlip = isPlayer;
		if (Data.lose.flipX) {
			isFlip = !isFlip;
		}
		animation.addByPrefix('lose', Data.lose.xmlName, Data.lose.fps, (FlxG.state is PlayState ? Data.lose.loop : true), isFlip, Data.lose.flipY);
		if (Data.win != null) {
			var isFlip = isPlayer;
			if (Data.win.flipX) {
				isFlip = !isFlip;
			}
			animation.addByPrefix('win', Data.win.xmlName, Data.win.fps, (FlxG.state is PlayState ? Data.win.loop : true), isFlip, Data.win.flipY);
		}
		updateHitbox();
	}
	public function playAnim(name:String, force:Bool = false) {
		if (spriteSheet && animation != null && animation.curAnim != null && animation.curAnim.name != name || force) {
			var currentFrame = animation.curAnim.curFrame;//idk this work or not(?)
			var frameLength = animation.getByName(name) != null ? animation.getByName(name).frames.length : 0;
			animation.play(name, true);
			if (frameLength > 0 && currentFrame <= frameLength-1) {
				animation.curAnim.curFrame = currentFrame;//prevents animation reset when change anim(i think)
			} else if (currentFrame > frameLength - 1 && frameLength > 0) {
				animation.curAnim.curFrame = frameLength - 1;
			} else {
				animation.curAnim.curFrame = 0;
			}
			if (offsetMap.exists(name)) {
				iconOffsets[0] = offsetMap.get(name)[0];
				iconOffsets[1] = offsetMap.get(name)[1];
			} else if (offsetMap.exists('netral')) {//backup
				iconOffsets[0] = offsetMap.get('netral')[0];
				iconOffsets[1] = offsetMap.get('netral')[1];
			} else {
				iconOffsets[0] = 0;
				iconOffsets[1] = 0;
			}
			changeOffsets();
		}
	}
	private function changeOffsets() {
		offset.x = iconOffsets[0];
		offset.y = iconOffsets[1];
	}

	public function danceIcon(state:String = 'netral') {
		if (animation == null) return;
		animation.play(state, false);
	}
}
