package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class ClientPrefs {
	public static var downScroll:Bool = false;
	public static var arrowRGB:Array<Array<Array<Int>>> = [
		//R(RGB), G(RGB), B(RGB)
		[ [ 194, 75,  153 ], [ 255, 255, 255 ], [ 60, 31, 86 ] ],
		[ [ 0, 255, 255 ], [ 255, 255, 255 ], [ 21, 66, 183 ] ],
		[ [ 18, 250, 5 ], [ 255, 255, 255 ], [ 10, 68, 71 ] ],
		[ [ 249, 57, 63 ], [ 255, 255, 255 ], [ 101, 16, 56 ] ] 
	];
	public static var limitSpawn:Bool = false;
	public static var limitSpawnNotes:Int = 50;//ummmm
	public static var startPause:Bool = false;
	public static var disableOGCredit:Bool = false;
	public static var keyStrokeAlpha:Float = 1;
	public static var extUI:Bool = false;
	public static var autopause:Bool = true;
	public static var dragonW:Bool = false;
	public static var darkmode:Bool = false;
	public static var ofhb:Bool = false;
	public static var dflnoteskin:String = 'NOTE_assets';
	public static var longNoteAlpha:Float = 0.6;
	public static var strumsize:Float = 0.7;
	public static var clsstrum:Bool = false;
	public static var fpsStrumAnim:Int = 24;
	public static var noteSplashAlpha:Float = 0.6;
	public static var middleScroll:Bool = false;
	public static var opponentStrums:Bool = true;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var shaders:Bool = true;
	public static var framerate:Int = 60;
	public static var cursing:Bool = true;
	public static var violence:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var ghostTapping:Bool = true;
	public static var timeBarType:String = 'Time Left';
	public static var scoreZoom:Bool = true;
	public static var noReset:Bool = false;
	public static var healthBarAlpha:Float = 1;
	public static var controllerMode:Bool = false;
	public static var hitsoundVolume:Float = 0;
	public static var pauseMusic:String = 'Tea Time';
	public static var checkForUpdates:Bool = true;
	public static var comboStacking = true;
	public static var noteSplashesOpt:Bool = true;
	public static var notesStrum:Bool = false;
	public static var gameplaySettings:Map<String, Dynamic> = [
		'scrollspeed' => 1.0,
		'scrolltype' => 'multiplicative', 
		// anyone reading this, amod is multiplicative speed mod, cmod is constant speed mod, and xmod is bpm based speed mod.
		// an amod example would be chartSpeed * multiplier
		// cmod would just be constantSpeed = chartSpeed
		// and xmod basically works by basing the speed on the bpm.
		// iirc (beatsPerSecond * (conductorToNoteDifference / 1000)) * noteSize (110 or something like that depending on it, prolly just use note.height)
		// bps is calculated by bpm / 60
		// oh yeah and you'd have to actually convert the difference to seconds which I already do, because this is based on beats and stuff. but it should work
		// just fine. but I wont implement it because I don't know how you handle sustains and other stuff like that.
		// oh yeah when you calculate the bps divide it by the songSpeed or rate because it wont scroll correctly when speeds exist.
		'songspeed' => 1.0,
		'healthgain' => 1.0,
		'healthloss' => 1.0,
		'instakill' => false,
		'practice' => false,
		'botplay' => false,
		'opponentplay' => false,
		'notekey' => 4,
		'multNote' => 1,
		'gamemode' => 'none',
		'modcharttype' => 'none',
		'disableLuaSong' => false,//Song folder with lua
	 	'disableLuaScript' => false,//Scripts folder
	 	'disableLuaStage' => false,//Stage lua
		'disableLuaEvent' => false,
		'opponent' => false
	];

	public static var comboOffset:Array<Int> = [0, 0, 0, 0];
	public static var ratingOffset:Int = 0;
	public static var sickWindow:Int = 45;
	public static var goodWindow:Int = 90;
	public static var badWindow:Int = 135;
	public static var safeFrames:Float = 10;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_up'		=> [W, UP],
		'note_right'	=> [D, RIGHT],
		//2 for opponent( bothside >.<)
		'note_left_2'	=> [J, LEFT],
		'note_down_2'	=> [K, DOWN],
		'note_up_2'		=> [I, UP],
		'note_right_2'	=> [L, RIGHT],

		//2nd notes
		'note_left_OPT'		=> [A, LEFT],
		'note_down_OPT'		=> [S, DOWN],
		'note_up_OPT'		=> [W, UP],
		'note_right_OPT'	=> [D, RIGHT],
		'note_left_OPT2'	=> [J, LEFT],
		'note_down_OPT2'	=> [K, DOWN],
		'note_up_OPT2'		=> [I, UP],
		'note_right_OPT2'	=> [L, RIGHT],

		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_up'			=> [W, UP],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R, NONE],
		
		'volume_mute'	=> [ZERO, NONE],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN, NONE],
		'debug_2'		=> [EIGHT, NONE]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;

	public static function loadDefaultKeys() {
		defaultKeys = keyBinds.copy();
		//trace(defaultKeys);
	}

	public static function saveSettings() {
		FlxG.save.data.arrowRGB = arrowRGB;
		FlxG.save.data.notesStrum = notesStrum;
		FlxG.save.data.limitSpawn = limitSpawn;
		FlxG.save.data.limitSpawnNotes = limitSpawnNotes;
		FlxG.save.data.startPause = startPause;
		FlxG.save.data.disableOGCredit = disableOGCredit;
		FlxG.save.data.keyStrokeAlpha = keyStrokeAlpha;
		FlxG.save.data.autopause = autopause;
		FlxG.save.data.extUI = extUI;
		FlxG.save.data.darkmode = darkmode;
		FlxG.save.data.dragonW = dragonW;
		FlxG.save.data.ofhb = ofhb;
		FlxG.save.data.strumsize = strumsize;
		FlxG.save.data.dflnoteskin = dflnoteskin;
		FlxG.save.data.clsstrum = clsstrum;
		FlxG.save.data.longNoteAlpha = longNoteAlpha;
		FlxG.save.data.noteSplashAlpha = noteSplashAlpha;
		FlxG.save.data.fpsStrumAnim = fpsStrumAnim;
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.opponentStrums = opponentStrums;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.noteSplashesOpt = noteSplashesOpt;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.framerate = framerate;
		//FlxG.save.data.cursing = cursing;
		//FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.timeBarType = timeBarType;
		FlxG.save.data.scoreZoom = scoreZoom;
		FlxG.save.data.noReset = noReset;
		FlxG.save.data.healthBarAlpha = healthBarAlpha;
		FlxG.save.data.comboOffset = comboOffset;
		FlxG.save.data.achievementsMap = Achievements.achievementsMap;
		FlxG.save.data.henchmenDeath = Achievements.henchmenDeath;

		FlxG.save.data.ratingOffset = ratingOffset;
		FlxG.save.data.sickWindow = sickWindow;
		FlxG.save.data.goodWindow = goodWindow;
		FlxG.save.data.badWindow = badWindow;
		FlxG.save.data.safeFrames = safeFrames;
		FlxG.save.data.gameplaySettings = gameplaySettings;
		FlxG.save.data.controllerMode = controllerMode;
		FlxG.save.data.hitsoundVolume = hitsoundVolume;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.checkForUpdates = checkForUpdates;
		FlxG.save.data.comboStacking = comboStacking;
	
		FlxG.save.flush();

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = keyBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.arrowRGB != null) {
			arrowRGB = FlxG.save.data.arrowRGB;
		}
		if(FlxG.save.data.limitSpawn != null) {
			limitSpawn = FlxG.save.data.limitSpawn;
		}
		if(FlxG.save.data.limitSpawnNotes != null) {
			limitSpawnNotes = FlxG.save.data.limitSpawnNotes;
		}
		if(FlxG.save.data.notesStrum != null) {
			notesStrum = FlxG.save.data.notesStrum;
		}
		if(FlxG.save.data.startPause != null) {
			startPause = FlxG.save.data.startPause;
		}
		if (FlxG.save.data.disableOGCredit != null) {
			disableOGCredit = FlxG.save.data.disableOGCredit;
		}
		if(FlxG.save.data.autopause != null) {
			autopause = FlxG.save.data.autopause;
		}
		if(FlxG.save.data.keyStrokeAlpha != null) {
			keyStrokeAlpha = FlxG.save.data.keyStrokeAlpha;
		}
		if(FlxG.save.data.extUI != null) {
			extUI = FlxG.save.data.extUI;
		}
		if(FlxG.save.data.darkmode != null) {
			darkmode = FlxG.save.data.darkmode;
		}
		if(FlxG.save.data.dragonW != null) {
			dragonW = FlxG.save.data.dragonW;
		}
		if(FlxG.save.data.ofhb != null) {
			ofhb = FlxG.save.data.ofhb;
		}
		if(FlxG.save.data.dflnoteskin != null) {
			dflnoteskin = FlxG.save.data.dflnoteskin;
		}
		if(FlxG.save.data.strumsize != null) {
			strumsize = FlxG.save.data.strumsize;
		}
		if(FlxG.save.data.longNoteAlpha != null) {
			longNoteAlpha = FlxG.save.data.longNoteAlpha;
		}
		if(FlxG.save.data.clsstrum != null) {
			clsstrum = FlxG.save.data.clsstrum;
		}
		if(FlxG.save.data.noteSplashAlpha != null) {
			noteSplashAlpha = FlxG.save.data.noteSplashAlpha;
		}
		if(FlxG.save.data.fpsStrumAnim != null) {
			fpsStrumAnim = FlxG.save.data.fpsStrumAnim;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.opponentStrums != null) {
			opponentStrums = FlxG.save.data.opponentStrums;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.noteSplashesOpt != null) {
			noteSplashesOpt = FlxG.save.data.noteSplashesOpt;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.shaders != null) {
			shaders = FlxG.save.data.shaders;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		/*if(FlxG.save.data.cursing != null) {
			cursing = FlxG.save.data.cursing;
		}
		if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.timeBarType != null) {
			timeBarType = FlxG.save.data.timeBarType;
		}
		if(FlxG.save.data.scoreZoom != null) {
			scoreZoom = FlxG.save.data.scoreZoom;
		}
		if(FlxG.save.data.noReset != null) {
			noReset = FlxG.save.data.noReset;
		}
		if(FlxG.save.data.healthBarAlpha != null) {
			healthBarAlpha = FlxG.save.data.healthBarAlpha;
		}
		if(FlxG.save.data.comboOffset != null) {
			comboOffset = FlxG.save.data.comboOffset;
		}
		
		if(FlxG.save.data.ratingOffset != null) {
			ratingOffset = FlxG.save.data.ratingOffset;
		}
		if(FlxG.save.data.sickWindow != null) {
			sickWindow = FlxG.save.data.sickWindow;
		}
		if(FlxG.save.data.goodWindow != null) {
			goodWindow = FlxG.save.data.goodWindow;
		}
		if(FlxG.save.data.badWindow != null) {
			badWindow = FlxG.save.data.badWindow;
		}
		if(FlxG.save.data.safeFrames != null) {
			safeFrames = FlxG.save.data.safeFrames;
		}
		if(FlxG.save.data.controllerMode != null) {
			controllerMode = FlxG.save.data.controllerMode;
		}
		if(FlxG.save.data.hitsoundVolume != null) {
			hitsoundVolume = FlxG.save.data.hitsoundVolume;
		}
		if(FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if(FlxG.save.data.gameplaySettings != null)
		{
			var savedMap:Map<String, Dynamic> = FlxG.save.data.gameplaySettings;
			for (name => value in savedMap)
			{
				gameplaySettings.set(name, value);
			}
		}
		
		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}
		if (FlxG.save.data.checkForUpdates != null)
		{
			checkForUpdates = FlxG.save.data.checkForUpdates;
		}
		if (FlxG.save.data.comboStacking != null)
			comboStacking = FlxG.save.data.comboStacking;

		var save:FlxSave = new FlxSave();
		save.bind('controls_v2', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			var loadedControls:Map<String, Array<FlxKey>> = save.data.customControls;
			for (control => keys in loadedControls) {
				keyBinds.set(control, keys);
			}
			reloadControls();
		}
	}

	inline public static function getGameplaySetting(name:String, defaultValue:Dynamic):Dynamic {
		return /*PlayState.isStoryMode ? defaultValue : */ (gameplaySettings.exists(name) ? gameplaySettings.get(name) : defaultValue);
	}

	public static function reloadControls() {
		PlayerSettings.player1.controls.setKeyboardScheme(KeyboardScheme.Solo);

		TitleState.muteKeys = copyKey(keyBinds.get('volume_mute'));
		TitleState.volumeDownKeys = copyKey(keyBinds.get('volume_down'));
		TitleState.volumeUpKeys = copyKey(keyBinds.get('volume_up'));
		FlxG.sound.muteKeys = TitleState.muteKeys;
		FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
		FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
	}
	public static function copyKey(arrayToCopy:Array<FlxKey>):Array<FlxKey> {
		var copiedArray:Array<FlxKey> = arrayToCopy.copy();
		var i:Int = 0;
		var len:Int = copiedArray.length;

		while (i < len) {
			if(copiedArray[i] == NONE) {
				copiedArray.remove(NONE);
				--i;
			}
			i++;
			len = copiedArray.length;
		}
		return copiedArray;
	}
}
