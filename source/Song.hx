package;

import flixel.FlxG;
import lime.app.Application;
import Section.SwagSection;
import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;

	var arrowSkin:String;
	var splashSkin:String;
	var arrowSkinOpt:String;
	var splashSkinOpt:String;
	var arrowSkinSec:String;
	var splashSkinSec:String;
	var validScore:Bool;
	var secOpt:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var events:Array<Dynamic>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var arrowSkin:String;
	public var splashSkin:String;
	public var arrowSkinOpt:String;
	public var splashSkinOpt:String;
	public var arrowSkinSec:String;
	public var splashSkinSec:String;
	public var speed:Float = 1;
	public var stage:String;
	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var secOpt:Bool = false;

	private static var eggs:Array<String> = [//easter egg msg for json song file no found
		'Json file went vacation.',
		'Json file is missing, probably hiding from you.',
		'Json file not found. Did it run away?',
		'Json file is playing hide and seek.',
		'Json file got stolen by dragon.',//HUH?
		'Json file is lost in the void.',
		'Json file got burned by a fire spell.',
		'Json file forgot the map.',
		'Json file is on a secret mission.',
		'Json file got abducted by aliens.',//GD?
		'Json file is missing, maybe check under the couch.'
	];

	private static function onLoadJson(songJson:Dynamic) // Convert old charts to newest format
	{
		if (songJson.secOpt == null)
		{
			songJson.secOpt = false;
		}
		if(songJson.gfVersion == null)
		{
			if (songJson.player3 != null) {
				songJson.gfVersion = songJson.player3;
				songJson.player3 = null;
			} else {
				songJson.gfVersion = "gf";
			}
		}


		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}
	}

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = null;
		
		var formattedFolder:String = Paths.formatToSongPath(folder);
		var formattedSong:String = Paths.formatToSongPath(jsonInput);
		#if MODS_ALLOWED
		var moddyFile:String = Paths.modsJson(formattedFolder + '/' + formattedSong);
		if(FileSystem.exists(moddyFile)) {
			rawJson = File.getContent(moddyFile).trim();
		}
		#end

		if(rawJson == null) {
			#if sys
			if (FileSystem.exists(Paths.externalFilesPath(Paths.json(formattedFolder + '/' + formattedSong)))) {
				rawJson = File.getContent(Paths.externalFilesPath(Paths.json(formattedFolder + '/' + formattedSong))).trim();
			} else {
				missingWarning(Paths.externalFilesPath(Paths.json(formattedFolder + '/' + formattedSong)));//anti crash
				return null;
			}
			#else
			if (Assets.exists(Paths.json(formattedFolder + '/' + formattedSong))) {
				rawJson = Assets.getText(Paths.json(formattedFolder + '/' + formattedSong)).trim();
			} else {
				missingWarning(Paths.json(formattedFolder + '/' + formattedSong));//anti crash
				return null;
			}
			#end
		}

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daBpm = songData.bpm; */

		var songJson:Dynamic = parseJSONshit(rawJson);
		if(jsonInput != 'events') StageData.loadDirectory(songJson);
		onLoadJson(songJson);
		return songJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
	//MORE ANTI CRASH
		try{
			var swagShit:SwagSong = cast Json.parse(rawJson).song;
			swagShit.validScore = true;
			return swagShit;
		} catch (e:Dynamic) {
			#if html5
			trace('Error parsing JSON data. The file may be corrupted or improperly formatted.(' + e + ')');
			#else
			Application.current.window.alert('Error parsing JSON data. The file may be corrupted or improperly formatted.(' + e + ')', 'JSON Parse Error');
			#end
		}
		return null;
	}
	public static function missingWarning(path:String) {
		#if html5
		if (FlxG.random.bool(0.1)) {
			var msg = FlxG.random.getObject(eggs);
			trace(msg + '(Json file not found: ' + path + ').');
		} else {
			trace('Json file not found: ' + path + '.');
		}
		#else
		if (FlxG.random.bool(0.1)) {
			var msg = FlxG.random.getObject(eggs);
			trace(msg + '(Json file not found: ' + path + ').');
			Application.current.window.alert(msg + ' (Json file not found: ' + path + ').', 'File Not Found');
		} else {
			trace('Json file not found: ' + path + '.');
			Application.current.window.alert('Json file not found: ' + path + '.', 'File Not Found');
		}
		#end
	}
}
