package;

import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;
import flash.media.Sound;
import dge.backend.CacheTools;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if MODS_ALLOWED
	public static var ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements',
		'gamemode'
	];
	#end

	public static function excludeAsset(key:String) {
		if (!dumpExclusions.contains(key))
			dumpExclusions.push(key);
	}

	public static var dumpExclusions:Array<String> =
	[
		'assets/music/freakyMenu.$SOUND_EXT',
		'assets/shared/music/breakfast.$SOUND_EXT',
		'assets/shared/music/tea-time.$SOUND_EXT',
	];
	/// haya I love you for the base cache dump I took to the max
	public static function clearUnusedMemory() {
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) {
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key)
				&& !dumpExclusions.contains(key)) {
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) {
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	// define the locally tracked assets
	public static var localTrackedAssets:Array<String> = [];
	public static function clearStoredMemory(?cleanUnused:Bool = false) {
		CacheTools.clearCache();
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key)) {
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys()) {
			if (!localTrackedAssets.contains(key)
			&& !dumpExclusions.contains(key) && key != null) {
				//trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		openfl.Assets.cache.clear("songs");
	}

	static public var currentModDirectory:String = '';
	static public var currentLevel:String;
	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var returnPath = '$library:assets/$library/$file';
		return returnPath;
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function shaderFragment(key:String, ?library:String)
	{
		return getPath('shaders/$key.frag', TEXT, library);
	}
	inline static public function shaderVertex(key:String, ?library:String)
	{
		return getPath('shaders/$key.vert', TEXT, library);
	}
	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Sound
	{
		var sound:Sound = returnSound('sounds', key, library);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey);
		return voices;
	}

	inline static public function inst(song:String):Any
	{
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey);
		return inst;
	}

	inline static public function image(key:String, ?library:String):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false, forceFromDisk:Bool = false):String
	{
		//info forceFromDisk will override cache existed text
		var keyName:String = key + (ignoreMods ? '_ignoreMods' : '');
		if (!CacheTools.cacheText.exists(keyName) || forceFromDisk) {
			#if sys
			#if MODS_ALLOWED
			if (!ignoreMods && FileSystem.exists(modFolders(key))) {
				var content = File.getContent(modFolders(key));
				CacheTools.cacheText.set(keyName, content);
				return content;
			}
			#end
	
			if (FileSystem.exists(externalPreloadPath(key))) {
				var content = File.getContent(externalPreloadPath(key));
				CacheTools.cacheText.set(keyName, content);
				return content;
			}
	
			if (currentLevel != null)
			{
				var levelPath:String = '';
				if(currentLevel != 'shared') {
					levelPath = getLibraryPathForce(key, currentLevel);
					if (FileSystem.exists(levelPath)) {
						var content = File.getContent(levelPath);
						CacheTools.cacheText.set(keyName, content);
						return content;
					}
				}
	
				levelPath = getLibraryPathForce(key, 'shared');
				if (FileSystem.exists(levelPath)) {
					var content = File.getContent(levelPath);
					CacheTools.cacheText.set(keyName, content);
					return content;
				}
			}
			#end
			var content = Assets.getText(getPath(key, TEXT));
			CacheTools.cacheText.set(keyName, content);
			return content;
		}
		return CacheTools.cacheText.get(keyName);
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		#end

		if(OpenFlAssets.exists(getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames
	{
		if (!CacheTools.cacheAtlas.exists(key)) {
			#if MODS_ALLOWED
			var imageLoaded:FlxGraphic = returnGraphic(key);
			var xmlExists:Bool = false;
			var pathXml:String = modsXml(key);
			if (FileSystem.exists(pathXml)) {
				xmlExists = true;
			} else {
				if(FileSystem.exists(externalPreloadPath('images/$key.xml'))) {
					pathXml = externalPreloadPath('images/$key.xml');
					xmlExists = true;
				}
			}
			var atlas = FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(pathXml) : file('images/$key.xml', library)));
			CacheTools.cacheAtlas.set(key, atlas);
			return atlas;
			#else
			var atlas =  FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
			CacheTools.cacheAtlas.set(key, atlas);
			return atlas;
			#end
		}
		return CacheTools.cacheAtlas.get(key);
	}


	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		if (!CacheTools.cachePackerAtlas.exists(key)) {
			#if MODS_ALLOWED
			var imageLoaded:FlxGraphic = returnGraphic(key);
			var txtExists:Bool = false;
			if(FileSystem.exists(modsTxt(key))) {
				txtExists = true;
			}
	
			var atlas = FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
			CacheTools.cachePackerAtlas.set(key, atlas);
			return atlas;
			#else
			var atlas = FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
			CacheTools.cachePackerAtlas.set(key, atlas);
			return atlas;
			#end
		}
		return CacheTools.cachePackerAtlas.get(key);
	}

	inline static public function formatToSongPath(path:String) {
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[.,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String) {
		if (!CacheTools.cacheImage.exists(key)) {
			#if MODS_ALLOWED
			var modKey:String = modsImages(key);
			if(FileSystem.exists(modKey)) {
				if(!currentTrackedAssets.exists(modKey)) {
					var newBitmap:BitmapData = BitmapData.fromFile(modKey);
					var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, modKey);
					newGraphic.persist = true;
					currentTrackedAssets.set(modKey, newGraphic);
				}
				localTrackedAssets.push(modKey);
				CacheTools.cacheImage.set(key, currentTrackedAssets.get(modKey));
				return currentTrackedAssets.get(modKey);
			}

			var preloadPath:String = externalPreloadPath('images/$key.png');
			if(FileSystem.exists(preloadPath)) {
				if(!currentTrackedAssets.exists(preloadPath)) {
					var newBitmap:BitmapData = BitmapData.fromFile(preloadPath);
					var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, preloadPath);
					newGraphic.persist = true;
					currentTrackedAssets.set(preloadPath, newGraphic);
				}
				localTrackedAssets.push(preloadPath);
				CacheTools.cacheImage.set(key, currentTrackedAssets.get(preloadPath));
				return currentTrackedAssets.get(preloadPath);
			}
			#end
	
			var path = getPath('images/$key.png', IMAGE, library);
			//trace(path);
			if (OpenFlAssets.exists(path, IMAGE)) {
				if(!currentTrackedAssets.exists(path)) {
					var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
					newGraphic.persist = true;
					currentTrackedAssets.set(path, newGraphic);
				}
				localTrackedAssets.push(path);
				CacheTools.cacheImage.set(key, currentTrackedAssets.get(path));
				return currentTrackedAssets.get(path);
			}
			trace('oh no its returning null NOOOO');
			CacheTools.cacheImage.set(key, null);
			return null;
		}
		return CacheTools.cacheImage.get(key);
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String) {
		if (!CacheTools.cacheSound.exists('$path/$key')) {
			#if MODS_ALLOWED
			var file:String = modsSounds(path, key);
			if(FileSystem.exists(file)) {
				if(!currentTrackedSounds.exists(file)) {
					currentTrackedSounds.set(file, Sound.fromFile(file));
				}
				localTrackedAssets.push(key);
				CacheTools.cacheSound.set('$path/$key', currentTrackedSounds.get(file));
				return currentTrackedSounds.get(file);
			}
			var external_file:String = externalPreloadPath('images/$key$SOUND_EXT');
			if(FileSystem.exists(external_file)) {
				if(!currentTrackedSounds.exists(external_file)) {
					currentTrackedSounds.set(external_file, Sound.fromFile(external_file));
				}
				localTrackedAssets.push(key);
				CacheTools.cacheSound.set('$path/$key', currentTrackedSounds.get(external_file));
				return currentTrackedSounds.get(external_file);
			}
			#end
			// I hate this so god damn much
			var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
			gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
			// trace(gottenPath);
			if(!currentTrackedSounds.exists(gottenPath))
			#if MODS_ALLOWED
				currentTrackedSounds.set(gottenPath, Sound.fromFile(externalFilesPath(gottenPath)));
			#else
			{
				var folder:String = '';
				if(path == 'songs') folder = 'songs:';
	
				currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
			}
			#end
			localTrackedAssets.push(gottenPath);
			CacheTools.cacheSound.set('$path/$key', currentTrackedSounds.get(gottenPath));
			return currentTrackedSounds.get(gottenPath);
		}
		return CacheTools.cacheSound.get('$path/$key');
	}

	#if MODS_ALLOWED
	inline static public function mods(key:String = '') {
		return externalFilesPath('mods/' + key);
	}

	inline static public function modsFont(key:String) {
		return modFolders('fonts/' + key);
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsSounds(path:String, key:String) {
		return modFolders(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	/* Goes unused for now

	inline static public function modsShaderFragment(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.frag');
	}
	inline static public function modsShaderVertex(key:String, ?library:String)
	{
		return modFolders('shaders/'+key+'.vert');
	}
	inline static public function modsAchievements(key:String) {
		return modFolders('achievements/' + key + '.json');
	}*/

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}

		for(mod in getGlobalMods()){
			var fileToCheck:String = mods(mod + '/' + key);
			if(FileSystem.exists(fileToCheck))
				return fileToCheck;

		}
		return externalFilesPath('mods/' + key);
	}

	public static var globalMods:Array<String> = [];

	static public function getGlobalMods()
		return globalMods;

	static public function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods = [];
		var path:String = Paths.externalFilesPath('modsList.txt');
		if(FileSystem.exists(path))
		{
			var list:Array<String> = CoolUtil.coolTextFile(path);
			for (i in list)
			{
				var dat = i.split("|");
				if (dat[1] == "1")
				{
					var folder = dat[0];
					var path = Paths.mods(folder + '/pack.json');
					if(FileSystem.exists(path)) {
						try{
							var rawJson:String = File.getContent(path);
							if(rawJson != null && rawJson.length > 0) {
								var stuff:Dynamic = Json.parse(rawJson);
								var global:Bool = Reflect.getProperty(stuff, "runsGlobally");
								if(global)globalMods.push(dat[0]);
							}
						} catch(e:Dynamic){
							trace(e);
						}
					}
				}
			}
		}
		return globalMods;
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
	public static function externalPreloadPath(file:String = '')
	{
		return externalFilesPath(getPreloadPath(file));
	}
	
	public static function externalFilesPath(file:String = '')
	{
		return StorageManager.getEngineDir() + file;
	}
}
