package editors;

import dge.obj.mobile.VirtualButton;
import dge.obj.mobile.ToggleButton;
import dge.backend.CacheTools;
#if desktop
import Discord.DiscordClient;
#end
import flash.geom.Rectangle;
import haxe.Json;
import haxe.Timer;
import haxe.format.JsonParser;
import haxe.io.Bytes;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUISlider;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import lime.media.AudioBuffer;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;

using StringTools;
#if sys
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
#end


@:access(flixel.system.FlxSound._sound)
@:access(openfl.media.Sound.__buffer)

class ChartingState extends MusicBeatState
{
	public var animAssets:Array<String> = [ "Left", 'Down', 'Up', 'Right' ];
	private var optChar:FlxSprite;
	private var plyChar:FlxSprite;
	public static var noteTypeList:Array<String> = //Used for backwards compatibility with 0.1 - 0.3.2 charts, though, you should add your hardcoded custom note types here too.
	[
		'',
		'Alt Animation',
		'Hey!',
		'Hurt Note',
		'GF Sing',
		'No Animation',
		'GF Sing Force Opponent',
		'Auto Press',
		"GF Sing Auto Press",
		"Flip Scroll",
		"Fake No Hit",
		"Snap Note",
		"Snap Note X",
		"Snap Note Y",
		"Multi Press"
	];
	private var noteTypeIntMap:Map<Int, String> = new Map<Int, String>();
	private var noteTypeMap:Map<String, Null<Int>> = new Map<String, Null<Int>>();
	public var ignoreWarnings = false;
	var undos = [];
	var redos = [];
	var eventStuff:Array<Dynamic> =
	[
		['', "Nothing. Yep, that's right."],
		['Dadbattle Spotlight', "Used in Dad Battle,\nValue 1: 0/1 = ON/OFF,\n2 = Target Dad\n3 = Target BF"],
		['Hey!', "Plays the \"Hey!\" animation from Bopeebo,\nValue 1: BF = Only Boyfriend, GF = Only Girlfriend,\nSomething else = Both.\nValue 2: Custom animation duration,\nleave it blank for 0.6s"],
		['Set GF Speed', "Sets GF head bopping speed,\nValue 1: 1 = Normal speed,\n2 = 1/2 speed, 4 = 1/4 speed etc.\nUsed on Fresh during the beatbox parts.\n\nWarning: Value must be integer!"],
		['Philly Glow', "Exclusive to Week 3\nValue 1: 0/1/2 = OFF/ON/Reset Gradient\n \nNo, i won't add it to other weeks."],
		['Kill Henchmen', "For Mom's songs, don't use this please, i love them :("],
		['Add Camera Zoom', "Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
		['BG Freaks Expression', "Should be used only in \"school\" Stage!"],
		['Trigger BG Ghouls', "Should be used only in \"schoolEvil\" Stage!"],
		['Play Animation', "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"],
		['Camera Follow Pos', "Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."],
		['Alt Idle Animation', "Sets a specified suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"],
		['Screen Shake', "Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."],
		['Change Character', "Value 1: Character to change (Dad, BF, GF)\nValue 2: New character's name"],
		['Change Scroll Speed', "Value 1: Scroll Speed Multiplier (1 is default)\nValue 2: Time it takes to change fully in seconds."],
		['Set Property', "Value 1: Variable name\nValue 2: New value"],
		['Change Gamemode', "Value 1: Name of gamemode to change.\nValue 2: transition(1 = true 0 = false)"],
		['Change Second Strums', "Value 1: should use 2nd strums mode(1 = true 0 = false).\nValue 2: transition(1 is true 0 is false)\n\nexample: \"1, 0\". the first number(1) is a transition for\nplayer side. The second number(0) is a disable\nopponent strums transition"],
		['Alert', "Value1: content of alert.\nValue2: title of alert."]
	];

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	public static var goToPlayState:Bool = false;
	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public static var curSec:Int = 0;
	public static var lastSection:Int = 0;
	private static var lastSong:String = '';

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var quant:AttachedSprite;
	var strumLineNotes:FlxTypedGroup<StrumNote>;
	var curSong:String = 'Test';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;
	var CAM_OFFSET:Int = 360+(GRID_SIZE*4);

	var dummyArrow:FlxSprite;
	
	var prevRenderedNotes:FlxTypedGroup<Note>;
	var prevRenderedSustains:FlxTypedGroup<Note>;

	var curRenderedSustains:FlxTypedGroup<Note>;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedNoteType:FlxTypedGroup<FlxText>;

	var nextRenderedSustains:FlxTypedGroup<Note>;
	var nextRenderedNotes:FlxTypedGroup<Note>;

	var prevGridBG:FlxSprite;
	var gridBG:FlxSprite;
	var nextGridBG:FlxSprite;

	var daquantspot = 0;
	var curEventSelected:Int = 0;
	var curUndoIndex = 0;
	var curRedoIndex = 0;
	var _song:SwagSong;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic> = null;

	var tempBpm:Float = 0;
	var playbackSpeed:Float = 1;

	var vocals:FlxSound = null;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var gfIcon:HealthIcon;

	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var currentSongName:String;

	var zoomTxt:FlxText;

	var zoomList:Array<Float> = [
		0.25,
		0.5,
		1,
		2,
		3,
		4,
		6,
		8,
		12,
		16,
		24,
		//more zoom variant!
		32,
		48,
		64,
		96,
		128,
		192,
		256,
		384,
		512//do you wamt make spam track with this!?!
	];
	var curZoom:Int = 2;

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileTypingOnStepper:Array<FlxUINumericStepper> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	var waveformSprite:FlxSprite;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	public static var quantization:Int = 16;
	public static var curQuant = 3;

	public var quantizations:Array<Int> = [
		4,
		8,
		12,
		16,
		20,
		24,
		32,
		48,
		64,
		96,
		192
	];



	var text:String = "";
	public static var vortex:Bool = false;
	public var mouseQuant:Bool = false;

	//mobile
	private var handButton:ToggleButton;
	private var enterButton:VirtualButton;
	private var backButton:VirtualButton;
	private var shiftButton:VirtualButton;
	private var spaceButton:VirtualButton;
	private var leftButton:VirtualButton;
	private var rightButton:VirtualButton;
	private var upButton:VirtualButton;
	private var downButton:VirtualButton;
	private var xButton:VirtualButton;
	private var zButton:VirtualButton;
	private var leftBracketButton:VirtualButton;
	private var rightBracketButton:VirtualButton;
	private var altButton:VirtualButton;
	private var ctrlButton:VirtualButton;
	override function create()
	{
		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();

			_song = {
				song: 'Test',
				notes: [],
				events: [],
				bpm: 150.0,
				needsVoices: true,
				secOpt: false,
				arrowSkin: '',
				splashSkin: 'noteSplashes',//idk it would crash if i didn't
				arrowSkinOpt: '',
				splashSkinOpt: 'noteSplashes',
				arrowSkinSec: '',
				splashSkinSec: 'noteSplashes',
				player1: 'bf',
				player2: 'dad',
				gfVersion: 'gf',
				speed: 1,
				stage: 'stage',
				validScore: false
			};
			addSection();
			PlayState.SONG = _song;
		}
		//convert old to new format(affected when save)
		for (i in _song.notes) {
			for (j in i.sectionNotes) {
				while (j.length > 4) {//remove extra data(cuz without it might crash)(cuz i found in Dracobot Chart, bruh)
					j.remove(j[4]);
				}
				if (!Std.isOfType(j[3], String)) {
					j[3] = noteTypeList[j[3] ? 1 : 0];
					if (j.length > 3 && (j[3] == null || j[3].length < 1)) {
						j.remove(j[3]);
					}
				}
			}
		}

		// Paths.clearMemory();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chart Editor", StringTools.replace(_song.song, '-', ' '));
		#end

		vortex = FlxG.save.data.chart_vortex;
		ignoreWarnings = FlxG.save.data.ignoreWarnings;
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
		bg.scrollFactor.set();
		bg.color = 0xFF505050;
		add(bg);
		CoolUtil.fitBackground(bg);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		waveformSprite = new FlxSprite(GRID_SIZE, 0).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);

		
		prevRenderedNotes = new FlxTypedGroup<Note>();
		prevRenderedSustains = new FlxTypedGroup<Note>();

		
		curRenderedSustains = new FlxTypedGroup<Note>();
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedNoteType = new FlxTypedGroup<FlxText>();

		nextRenderedSustains = new FlxTypedGroup<Note>();
		nextRenderedNotes = new FlxTypedGroup<Note>();

		if(curSec >= _song.notes.length) curSec = _song.notes.length - 1;

		FlxG.mouse.visible = true;
		//FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		currentSongName = Paths.formatToSongPath(_song.song);
		loadSong();
		reloadGridLayer();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(10, 0, 0, "", 16);
		bpmTxt.y = FlxG.height - (bpmTxt.height+10);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 13), 4);
		add(strumLine);

		quant = new AttachedSprite('chart_quant','chart_quant');
		quant.animation.addByPrefix('q','chart_quant',0,false);
		quant.animation.play('q', true, false, 0);
		quant.sprTracker = strumLine;
		quant.xAdd = -32;
		quant.yAdd = 8;
		add(quant);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		for (i in 0...12){
			var note:StrumNote = new StrumNote(GRID_SIZE * (i+1), strumLine.y, i % 4, 0);
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.playAnim('static', true);
			strumLineNotes.add(note);
			note.scrollFactor.set(1, 1);
		}
		add(strumLineNotes);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'},
			{name: "Charting", label: 'Charting'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 550);
		UI_box.x = (FlxG.width / 2) + GRID_SIZE / 2;
		UI_box.y = 25;
		UI_box.scrollFactor.set();

		text =
		"When Use Has 2nd Strum, it only work GF Sing Notetype
		W/S or Mouse Wheel - Change Conductor's strum time
		A/D - Go to the previous/next section
		Left/Right - Change Snap
		Up/Down - Change Conductor's Strum Time with Snapping
		Left Bracket / Right Bracket - Change Song Playback Rate (SHIFT to go Faster)
		ALT + Left Bracket / Right Bracket - Reset Song Playback Rate
		Hold Shift to move 4x faster
		Hold Control and click on an arrow to select it
		Z/X - Zoom in/out
		Esc - Test your chart inside Chart Editor
		Enter - Play your chart
		Q/E - Decrease/Increase Note Sustain Length
		Space - Stop/Resume song
		 Control+ ALT - Multiplace Notes";

		var tipText:FlxText = new FlxText((UI_box.x+UI_box.width)+10, UI_box.y, Std.int(300*(FlxG.width/1280)), text, 15);
		tipText.setFormat(Paths.font('vcr.ttf'), 15, FlxColor.WHITE, LEFT/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		//tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);
		add(UI_box);

		add(prevRenderedNotes);
		add(prevRenderedSustains);
		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedNoteType);
		add(nextRenderedSustains);
		add(nextRenderedNotes);

		var eventIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('eventArrow'));
		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		gfIcon = new HealthIcon('gf');
		eventIcon.scrollFactor.set(1, 0);
		leftIcon.scrollFactor.set(1, 0);
		gfIcon.scrollFactor.set(1, 0);
		rightIcon.scrollFactor.set(1, 0);

		eventIcon.setGraphicSize(0, 30);
		leftIcon.setGraphicSize(0, 45);
		gfIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(eventIcon);
		add(leftIcon);
		add(gfIcon);
		add(rightIcon);

		eventIcon.setPosition((-GRID_SIZE - 5), 7.5);
		leftIcon.setPosition((GRID_SIZE + 10), 0);
		rightIcon.setPosition((GRID_SIZE * 5.2), 0);
		gfIcon.setPosition((GRID_SIZE * 5.2)+(GRID_SIZE*4), 0);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		addChartingUI();
		updateHeads();
		updateWaveform();
		//UI_box.selected_tab = 4;


		if(lastSong != currentSongName) {
			changeSection();
		}
		lastSong = currentSongName;

		zoomTxt = new FlxText(10, 0, 0, "Zoom: 1 / 1", 16);
		zoomTxt.y = bpmTxt.y - (zoomTxt.height+10);
		zoomTxt.scrollFactor.set();
		add(zoomTxt);

		updateGrid();
		optChar = new FlxSprite(0, 0);
		optChar.frames = Paths.getSparrowAtlas("characters/MintEnderDragon");
		optChar.animation.addByPrefix("idle", "MintEnderDragon Idle", true);
		for (i in 0...animAssets.length) {
			optChar.animation.addByPrefix("sing" + animAssets[i].toUpperCase(), "MintEnderDragon " + animAssets[i], false);
		}
		optChar.animation.play("idle");
		optChar.scale.set(0.1, 0.1);
		optChar.updateHitbox();
		optChar.x = GRID_SIZE*13;
		//optChar.scrollFactor.set(0, 0);
		add(optChar);
		plyChar = new FlxSprite(0, 0);
		plyChar.frames = Paths.getSparrowAtlas("characters/DubEnderDragon");
		plyChar.animation.addByPrefix("idle", "DubEnderDragon Idle", true);
		for (i in 0...animAssets.length) {
			plyChar.animation.addByPrefix("sing" + animAssets[i].toUpperCase(), "DubEnderDragon " + animAssets[i], false);
		}
		plyChar.animation.play("idle");
		plyChar.scale.set(0.1, 0.1);
		plyChar.updateHitbox();
		plyChar.flipX = true;
		plyChar.x = optChar.x+200;
		//plyChar.scrollFactor.set(0, 0);
		add(plyChar);
		#if mobile
		//left ui
		handButton = new ToggleButton(0, FlxG.height-125, 'hand');
		add(handButton);
		//right ui
		enterButton = new VirtualButton(FlxG.width-125, FlxG.height-125, 'enter');
		add(enterButton);
		backButton = new VirtualButton(FlxG.width-250, FlxG.height-125, 'back');
		add(backButton);
		spaceButton  = new VirtualButton(FlxG.width-125, FlxG.height-250, 'space');
		add(spaceButton);
		leftButton = new VirtualButton(FlxG.width-250, FlxG.height-375, 'left');
		add(leftButton);
		shiftButton  = new VirtualButton(FlxG.width-250, FlxG.height-250, 'shift');
		add(shiftButton);
		altButton  = new VirtualButton(FlxG.width-375, FlxG.height-250, 'alt');
		add(altButton);
		rightButton = new VirtualButton(FlxG.width-125, FlxG.height-375, 'right');
		add(rightButton);
		downButton = new VirtualButton(FlxG.width-375, FlxG.height-375, 'down');
		add(downButton);
		upButton = new VirtualButton(FlxG.width-375, FlxG.height-500, 'up');
		add(upButton);
		xButton = new VirtualButton(FlxG.width-375, FlxG.height-125, 'x');
		add(xButton);
		zButton = new VirtualButton(FlxG.width-500, FlxG.height-125, 'z');
		add(zButton);
		leftBracketButton = new VirtualButton(FlxG.width-250, FlxG.height-500, 'left_bracket');
		add(leftBracketButton);
		rightBracketButton = new VirtualButton(FlxG.width-125, FlxG.height-500, 'right_bracket');
		add(rightBracketButton);
		ctrlButton  = new VirtualButton(FlxG.width-500, FlxG.height-250, 'ctrl');
		add(ctrlButton);
		#end
		super.create();
	}

	var check_mute_inst:FlxUICheckBox = null;
	var check_vortex:FlxUICheckBox = null;
	var check_warnings:FlxUICheckBox = null;
	var playSoundBf:FlxUICheckBox = null;
	var playSoundDad:FlxUICheckBox = null;
	var UI_songTitle:FlxUIInputText;
	var noteSkinInputText:FlxUIInputText;
	var noteSplashesInputText:FlxUIInputText;
	var noteSkinInputTextOpt:FlxUIInputText;
	var noteSplashesInputTextOpt:FlxUIInputText;
	var noteSkinInputTextSec:FlxUIInputText;
	var noteSplashesInputTextSec:FlxUIInputText;
	var stageDropDown:FlxUIDropDownMenuCustom;
	var sliderRate:FlxUISlider;
	function addSongUI():Void
	{
		UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			//trace('CHECKED!');
		};
		var secOptStrum = new FlxUICheckBox(10, 45, null, null, "Has 2nd Strums", 100);
		secOptStrum.checked = _song.secOpt;
		// _song.needsVoices = secOptStrum.checked;
		secOptStrum.callback = function()
		{
			_song.secOpt = secOptStrum.checked;
			//trace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + 90, saveButton.y, "Reload Audio", function()
		{
			currentSongName = Paths.formatToSongPath(UI_songTitle.text);
			loadSong();
			updateWaveform();
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){
				loadJson(_song.song.toLowerCase()); }, null,ignoreWarnings));
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', function()
		{
			PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
			MusicBeatState.resetState();
		});

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{

			var songName:String = Paths.formatToSongPath(_song.song);
			var file:String = Paths.externalFilesPath(Paths.json(songName + '/events'));
			#if sys
			if (#if MODS_ALLOWED FileSystem.exists(Paths.modsJson(songName + '/events')) || #end FileSystem.exists(file))
			#else
			if (OpenFlAssets.exists(file))
			#end
			{
				clearEvents();
				var events:SwagSong = Song.loadFromJson('events', songName);
				_song.events = events.events;
				changeSection(curSec);
			}
		});

		var saveEvents:FlxButton = new FlxButton(110, reloadSongJson.y, 'Save Events', function ()
		{
			saveEvents();
		});

		var clear_events:FlxButton = new FlxButton(0, (UI_box.height)+10, 'Clear events', function()
			{
				openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, clearEvents, null,ignoreWarnings));
			});
		clear_events.color = FlxColor.RED;
		clear_events.label.color = FlxColor.WHITE;

		var clear_notes:FlxButton = new FlxButton(0, clear_events.y + 30, 'Clear notes', function()
			{
				clearNotes();

			});
		clear_notes.color = FlxColor.RED;
		clear_notes.label.color = FlxColor.WHITE;

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 75, 1, 1, 1, 400, 3);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		blockPressWhileTypingOnStepper.push(stepperBPM);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, stepperBPM.y + 35, 0.1, 1, -1000, 1000, 5);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		blockPressWhileTypingOnStepper.push(stepperSpeed);
		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.externalPreloadPath('characters/')];
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/characters/'));
		#else
		var directories:Array<String> = [Paths.getPreloadPath('characters/')];
		#end

		var tempMap:Map<String, Bool> = new Map<String, Bool>();
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.externalFilesPath(Paths.txt('characterList')));
		for (i in 0...characters.length) {
			tempMap.set(characters[i], true);
		}

		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charToCheck.endsWith('-dead') && !tempMap.exists(charToCheck)) {
							tempMap.set(charToCheck, true);
							characters.push(charToCheck);
						}
					}
				}
			}
		}
		#end

		var player1DropDown = new FlxUIDropDownMenuCustom(10, stepperSpeed.y + 45, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		var gfVersionDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, player1DropDown.y + 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.gfVersion = characters[Std.parseInt(character)];
			updateHeads();
		});
		gfVersionDropDown.selectedLabel = _song.gfVersion;
		blockPressWhileScrolling.push(gfVersionDropDown);

		var player2DropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, gfVersionDropDown.y + 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods('stages/'), Paths.mods(Paths.currentModDirectory + '/stages/'), Paths.externalPreloadPath('stages/')];
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/stages/'));
		#else
		var directories:Array<String> = [Paths.getPreloadPath('stages/')];
		#end

		tempMap.clear();
		var stageFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		var stages:Array<String> = [];
		for (i in 0...stageFile.length) { //Prevent duplicates
			var stageToCheck:String = stageFile[i];
			if(!tempMap.exists(stageToCheck)) {
				stages.push(stageToCheck);
			}
			tempMap.set(stageToCheck, true);
		}
		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var stageToCheck:String = file.substr(0, file.length - 5);
						if(!tempMap.exists(stageToCheck)) {
							tempMap.set(stageToCheck, true);
							stages.push(stageToCheck);
						}
					}
				}
			}
		}
		#end

		if(stages.length < 1) stages.push('stage');

		stageDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x + 140, player1DropDown.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(character:String)
		{
			_song.stage = stages[Std.parseInt(character)];
		});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var skin = PlayState.SONG.arrowSkin;
		var skinOpt = PlayState.SONG.arrowSkinOpt;
		var skinSec = PlayState.SONG.arrowSkinSec;
		if(skin == null) skin = '';
		if(skinOpt == null) skinOpt = '';
		if(skinSec == null) skinSec = '';
		noteSkinInputText = new FlxUIInputText(player2DropDown.x, player2DropDown.y + 50, 150, skin, 8);
		blockPressWhileTypingOn.push(noteSkinInputText);

		noteSplashesInputText = new FlxUIInputText(noteSkinInputText.x, noteSkinInputText.y + 35, 150, _song.splashSkin, 8);
		blockPressWhileTypingOn.push(noteSplashesInputText);

		noteSkinInputTextOpt = new FlxUIInputText(noteSplashesInputText.x, noteSplashesInputText.y + 35, 150, skinOpt, 8);
		blockPressWhileTypingOn.push(noteSkinInputTextOpt);

		noteSplashesInputTextOpt = new FlxUIInputText(noteSkinInputTextOpt.x, noteSkinInputTextOpt.y + 35, 150, _song.splashSkinOpt, 8);
		blockPressWhileTypingOn.push(noteSplashesInputTextOpt);

		noteSkinInputTextSec = new FlxUIInputText(noteSplashesInputTextOpt.x, noteSplashesInputTextOpt.y + 35, 150, skinSec, 8);
		blockPressWhileTypingOn.push(noteSkinInputTextSec);

		noteSplashesInputTextSec = new FlxUIInputText(noteSkinInputTextSec.x, noteSkinInputTextSec.y + 35, 150, _song.splashSkinSec, 8);
		blockPressWhileTypingOn.push(noteSplashesInputTextSec);

		var reloadNotesButton:FlxButton = new FlxButton(noteSplashesInputTextSec.x + 5, noteSplashesInputTextSec.y + (20+5), 'Change Notes', function() {
			_song.arrowSkin = noteSkinInputText.text;
			_song.arrowSkinOpt = noteSkinInputTextOpt.text;
			_song.arrowSkinSec = noteSkinInputTextSec.text;
			updateGrid();
		});

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(secOptStrum);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvents);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(reloadNotesButton);
		tab_group_song.add(noteSkinInputText);
		tab_group_song.add(noteSplashesInputText);
		tab_group_song.add(noteSkinInputTextOpt);
		tab_group_song.add(noteSplashesInputTextOpt);
		tab_group_song.add(noteSkinInputTextSec);
		tab_group_song.add(noteSplashesInputTextSec);
		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, 'Song BPM:'));
		tab_group_song.add(new FlxText(stepperBPM.x + 100, stepperBPM.y - 15, 0, 'Song Offset:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(new FlxText(gfVersionDropDown.x, gfVersionDropDown.y - 15, 0, 'Girlfriend:'));
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(new FlxText(noteSkinInputText.x, noteSkinInputText.y - 15, 0, 'Note Texture(Player):'));
		tab_group_song.add(new FlxText(noteSplashesInputText.x, noteSplashesInputText.y - 15, 0, 'Note Splashes Texture(Player):'));
		tab_group_song.add(new FlxText(noteSkinInputTextOpt.x, noteSkinInputTextOpt.y - 15, 0, 'Note Texture(Opponent):'));
		tab_group_song.add(new FlxText(noteSplashesInputTextOpt.x, noteSplashesInputTextOpt.y - 15, 0, 'Note Splashes Texture(Opponent):'));
		tab_group_song.add(new FlxText(noteSkinInputTextSec.x, noteSkinInputTextSec.y - 15, 0, 'Note Texture(Second Opponent):'));
		tab_group_song.add(new FlxText(noteSplashesInputTextSec.x, noteSplashesInputTextSec.y - 15, 0, 'Note Splashes Texture(Second Opponent):'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(gfVersionDropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);

		FlxG.camera.follow(camPos);
	}

	var stepperBeats:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_gfSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		check_mustHitSection = new FlxUICheckBox(10, 15, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[curSec].mustHitSection;

		check_gfSection = new FlxUICheckBox(10, check_mustHitSection.y + 22, null, null, "GF section", 100);
		check_gfSection.name = 'check_gf';
		check_gfSection.checked = _song.notes[curSec].gfSection;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(check_gfSection.x + 120, check_gfSection.y, null, null, "Alt Animation", 100);
		check_altAnim.checked = _song.notes[curSec].altAnim;

		stepperBeats = new FlxUINumericStepper(10, 100, 1, 4, 1, 6, 2);
		stepperBeats.value = getSectionBeats();
		stepperBeats.name = 'section_beats';
		blockPressWhileTypingOnStepper.push(stepperBeats);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, stepperBeats.y + 30, null, null, 'Change BPM', 100);
		check_changeBPM.checked = _song.notes[curSec].changeBPM;
		check_changeBPM.name = 'check_changeBPM';

		stepperSectionBPM = new FlxUINumericStepper(10, check_changeBPM.y + 20, 1, Conductor.bpm, 0, 999, 1);
		if(check_changeBPM.checked) {
			stepperSectionBPM.value = _song.notes[curSec].bpm;
		} else {
			stepperSectionBPM.value = Conductor.bpm;
		}
		stepperSectionBPM.name = 'section_bpm';
		blockPressWhileTypingOnStepper.push(stepperSectionBPM);

		var check_eventsSec:FlxUICheckBox = null;
		var check_notesSec:FlxUICheckBox = null;
		var copyButton:FlxButton = new FlxButton(10, 190, "Copy Section", function()
		{
			copySection();
		});

		var pasteButton:FlxButton = new FlxButton(copyButton.x + 100, copyButton.y, "Paste Section", function()
		{
			pasteSection(check_notesSec.checked, check_eventsSec.checked);
		});

		var clearSectionButton:FlxButton = new FlxButton(pasteButton.x + 100, pasteButton.y, "Clear", function()
		{
			clearSec(check_notesSec.checked, check_eventsSec.checked);
			
		});
		clearSectionButton.color = FlxColor.RED;
		clearSectionButton.label.color = FlxColor.WHITE;
		
		check_notesSec = new FlxUICheckBox(10, clearSectionButton.y + 25, null, null, "Notes", 100);
		check_notesSec.checked = true;
		check_eventsSec = new FlxUICheckBox(check_notesSec.x + 100, check_notesSec.y, null, null, "Events", 100);
		check_eventsSec.checked = true;

		var swapSection:FlxButton = new FlxButton(10, check_notesSec.y + 40, "Swap section", function()
		{
			for (i in 0..._song.notes[curSec].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSec].sectionNotes[i];
				note[1] = (note[1] + 4) % 12;
				_song.notes[curSec].sectionNotes[i] = note;
			}
			updateGrid();
		});

		var stepperCopy:FlxUINumericStepper = null;
		var copyLastButton:FlxButton = new FlxButton(10, swapSection.y + 30, "Copy last section", function()
		{
			var value:Int = Std.int(stepperCopy.value);
			if(value == 0) return;

			var daSec = FlxMath.maxInt(curSec, value);

			for (note in _song.notes[daSec - value].sectionNotes)
			{
				var strum = note[0] + Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);


				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}

			var startThing:Float = sectionStartTime(-value);
			var endThing:Float = sectionStartTime(-value + 1);
			for (event in _song.events)
			{
				var strumTime:Float = event[0];
				if(endThing > event[0] && event[0] >= startThing)
				{
					strumTime += Conductor.stepCrochet * (getSectionBeats(daSec) * 4 * value);
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...event[1].length)
					{
						var eventToPush:Array<Dynamic> = event[1][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					_song.events.push([strumTime, copiedEventArray]);
				}
			}
			updateGrid();
		});
		copyLastButton.setGraphicSize(80, 30);
		copyLastButton.updateHitbox();
		
		stepperCopy = new FlxUINumericStepper(copyLastButton.x + 100, copyLastButton.y, 1, 1, -999, 999, 0);
		blockPressWhileTypingOnStepper.push(stepperCopy);

		var duetButton:FlxButton = new FlxButton(10, copyLastButton.y + 45, "Duet Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];
			for (note in _song.notes[curSec].sectionNotes)
			{
				var boob = note[1];
				if (boob>3){
					boob -= 4;
				}else{
					boob += 4;
				}

				var copiedNote:Array<Dynamic> = [note[0], boob, note[2], note[3]];
				duetNotes.push(copiedNote);
			}

			for (i in duetNotes){
			_song.notes[curSec].sectionNotes.push(i);

			}

			updateGrid();
		});
		var mirrorButton:FlxButton = new FlxButton(duetButton.x + 100, duetButton.y, "Mirror Notes", function()
		{
			var duetNotes:Array<Array<Dynamic>> = [];
			for (note in _song.notes[curSec].sectionNotes)
			{
				var boob = note[1]%4;
				boob = 3 - boob;
				if (note[1] > 3) boob += 4;
				if (note[1] > 7) boob += 4;

				note[1] = boob;
				var copiedNote:Array<Dynamic> = [note[0], boob, note[2], note[3]];
				//duetNotes.push(copiedNote);
			}

			for (i in duetNotes){
			//_song.notes[curSec].sectionNotes.push(i);

			}

			updateGrid();
		});

		tab_group_section.add(new FlxText(stepperBeats.x, stepperBeats.y - 15, 0, 'Beats per Section:'));
		tab_group_section.add(stepperBeats);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_gfSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(pasteButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(check_notesSec);
		tab_group_section.add(check_eventsSec);
		tab_group_section.add(swapSection);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyLastButton);
		tab_group_section.add(duetButton);
		tab_group_section.add(mirrorButton);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; //I wanted to use a stepper but we can't scale these as far as i know :(
	var noteTypeDropDown:FlxUIDropDownMenuCustom;
	var currentType:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 64);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		blockPressWhileTypingOnStepper.push(stepperSusLength);

		strumTimeInputText = new FlxUIInputText(10, 65, 180, "0");
		tab_group_note.add(strumTimeInputText);
		blockPressWhileTypingOn.push(strumTimeInputText);

		var key:Int = 0;
		var displayNameList:Array<String> = [];
		while (key < noteTypeList.length) {
			displayNameList.push(noteTypeList[key]);
			noteTypeMap.set(noteTypeList[key], key);
			noteTypeIntMap.set(key, noteTypeList[key]);
			key++;
		}

		#if LUA_ALLOWED
		var directories:Array<String> = [];

		#if MODS_ALLOWED
		directories.push(Paths.mods('custom_notetypes/'));
		directories.push(Paths.mods(Paths.currentModDirectory + '/custom_notetypes/'));
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/custom_notetypes/'));
		#end

		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.lua')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!noteTypeMap.exists(fileToCheck)) {
							displayNameList.push(fileToCheck);
							noteTypeMap.set(fileToCheck, key);
							noteTypeIntMap.set(key, fileToCheck);
							key++;
						}
					}
					if (!FileSystem.isDirectory(path) && file.endsWith('.json') && file != 'all.json') {//'all' note type should not exits as json(use lua if want add notetype name 'all')
						var fileToCheck:String = file.substr(0, file.length - 5);
						if(!noteTypeMap.exists(fileToCheck)) {
							displayNameList.push(fileToCheck);
							noteTypeMap.set(fileToCheck, key);
							noteTypeIntMap.set(key, fileToCheck);
							key++;
						}
					}
				}
			}
		}
		#end

		for (i in 1...displayNameList.length) {
			displayNameList[i] = i + '. ' + displayNameList[i];
		}

		noteTypeDropDown = new FlxUIDropDownMenuCustom(10, 105, FlxUIDropDownMenuCustom.makeStrIdLabelArray(displayNameList, true), function(character:String)
		{
			currentType = Std.parseInt(character);
			if(curSelectedNote != null && curSelectedNote[1] > -1) {
				curSelectedNote[3] = noteTypeIntMap.get(currentType);
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(noteTypeDropDown);

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(10, 50, 0, 'Strum time (in miliseconds):'));
		tab_group_note.add(new FlxText(10, 90, 0, 'Note type:'));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(strumTimeInputText);
		tab_group_note.add(noteTypeDropDown);

		UI_box.addGroup(tab_group_note);
	}

	var eventDropDown:FlxUIDropDownMenuCustom;
	var descText:FlxText;
	var selectedEventText:FlxText;
	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		#if LUA_ALLOWED
		var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
		var directories:Array<String> = [];

		#if MODS_ALLOWED
		directories.push(Paths.mods('custom_events/'));
		directories.push(Paths.mods(Paths.currentModDirectory + '/custom_events/'));
		for(mod in Paths.getGlobalMods())
			directories.push(Paths.mods(mod + '/custom_events/'));
		#end

		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file != 'readme.txt' && file.endsWith('.txt')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!eventPushedMap.exists(fileToCheck)) {
							eventPushedMap.set(fileToCheck, true);
							eventStuff.push([fileToCheck, File.getContent(path)]);
						}
					}
				}
			}
		}
		eventPushedMap.clear();
		eventPushedMap = null;
		#end

		descText = new FlxText(20, 200, 0, eventStuff[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventStuff.length) {
			leEvents.push(eventStuff[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenuCustom(20, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(leEvents, true), function(pressed:String) {
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventStuff[selectedEvent][1];
				if (curSelectedNote != null &&  eventStuff != null) {
				if (curSelectedNote != null && curSelectedNote[2] == null){
				curSelectedNote[1][curEventSelected][0] = eventStuff[selectedEvent][0];

				}
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		// New event buttons
		var removeButton:FlxButton = new FlxButton(eventDropDown.x + eventDropDown.width + 10, eventDropDown.y, '-', function()
		{
			if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
			{
				if(curSelectedNote[1].length < 2)
				{
					_song.events.remove(curSelectedNote);
					curSelectedNote = null;
				}
				else
				{
					curSelectedNote[1].remove(curSelectedNote[1][curEventSelected]);
				}

				var eventsGroup:Array<Dynamic>;
				--curEventSelected;
				if(curEventSelected < 0) curEventSelected = 0;
				else if(curSelectedNote != null && curEventSelected >= (eventsGroup = curSelectedNote[1]).length) curEventSelected = eventsGroup.length - 1;

				changeEventSelected();
				updateGrid();
			}
		});
		removeButton.setGraphicSize(Std.int(removeButton.height), Std.int(removeButton.height));
		removeButton.updateHitbox();
		removeButton.color = FlxColor.RED;
		removeButton.label.color = FlxColor.WHITE;
		removeButton.label.size = 12;
		setAllLabelsOffset(removeButton, -30, 0);
		tab_group_event.add(removeButton);

		var addButton:FlxButton = new FlxButton(removeButton.x + removeButton.width + 10, removeButton.y, '+', function()
		{
			if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
			{
				var eventsGroup:Array<Dynamic> = curSelectedNote[1];
				eventsGroup.push(['', '', '']);

				changeEventSelected(1);
				updateGrid();
			}
		});
		addButton.setGraphicSize(Std.int(removeButton.width), Std.int(removeButton.height));
		addButton.updateHitbox();
		addButton.color = FlxColor.GREEN;
		addButton.label.color = FlxColor.WHITE;
		addButton.label.size = 12;
		setAllLabelsOffset(addButton, -30, 0);
		tab_group_event.add(addButton);

		var moveLeftButton:FlxButton = new FlxButton(addButton.x + addButton.width + 20, addButton.y, '<', function()
		{
			changeEventSelected(-1);
		});
		moveLeftButton.setGraphicSize(Std.int(addButton.width), Std.int(addButton.height));
		moveLeftButton.updateHitbox();
		moveLeftButton.label.size = 12;
		setAllLabelsOffset(moveLeftButton, -30, 0);
		tab_group_event.add(moveLeftButton);

		var moveRightButton:FlxButton = new FlxButton(moveLeftButton.x + moveLeftButton.width + 10, moveLeftButton.y, '>', function()
		{
			changeEventSelected(1);
		});
		moveRightButton.setGraphicSize(Std.int(moveLeftButton.width), Std.int(moveLeftButton.height));
		moveRightButton.updateHitbox();
		moveRightButton.label.size = 12;
		setAllLabelsOffset(moveRightButton, -30, 0);
		tab_group_event.add(moveRightButton);

		selectedEventText = new FlxText(addButton.x - 100, addButton.y + addButton.height + 6, (moveRightButton.x - addButton.x) + 186, 'Selected Event: None');
		selectedEventText.alignment = CENTER;
		tab_group_event.add(selectedEventText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	function changeEventSelected(change:Int = 0)
	{
		if(curSelectedNote != null && curSelectedNote[2] == null) //Is event note
		{
			curEventSelected += change;
			if(curEventSelected < 0) curEventSelected = Std.int(curSelectedNote[1].length) - 1;
			else if(curEventSelected >= curSelectedNote[1].length) curEventSelected = 0;
			selectedEventText.text = 'Selected Event: ' + (curEventSelected + 1) + ' / ' + curSelectedNote[1].length;
		}
		else
		{
			curEventSelected = 0;
			selectedEventText.text = 'Selected Event: None';
		}
		updateNoteUI();
	}

	function setAllLabelsOffset(button:FlxButton, x:Float, y:Float)
	{
		for (point in button.labelOffsets)
		{
			point.set(x, y);
		}
	}

	var metronome:FlxUICheckBox;
	var mouseScrollingQuant:FlxUICheckBox;
	var metronomeStepper:FlxUINumericStepper;
	var metronomeOffsetStepper:FlxUINumericStepper;
	var disableAutoScrolling:FlxUICheckBox;
	var waveformUseInstrumental:FlxUICheckBox;
	var waveformUseVoices:FlxUICheckBox;
	var instVolume:FlxUINumericStepper;
	var voicesVolume:FlxUINumericStepper;
	function addChartingUI() {
		var tab_group_chart = new FlxUI(null, UI_box);
		tab_group_chart.name = 'Charting';

		if (FlxG.save.data.chart_waveformInst == null) FlxG.save.data.chart_waveformInst = false;
		if (FlxG.save.data.chart_waveformVoices == null) FlxG.save.data.chart_waveformVoices = false;

		waveformUseInstrumental = new FlxUICheckBox(10, 90, null, null, "Waveform for Instrumental", 100);
		waveformUseInstrumental.checked = FlxG.save.data.chart_waveformInst;
		waveformUseInstrumental.callback = function()
		{
			waveformUseVoices.checked = false;
			FlxG.save.data.chart_waveformVoices = false;
			FlxG.save.data.chart_waveformInst = waveformUseInstrumental.checked;
			updateWaveform();
		};

		waveformUseVoices = new FlxUICheckBox(waveformUseInstrumental.x + 120, waveformUseInstrumental.y, null, null, "Waveform for Voices", 100);
		waveformUseVoices.checked = FlxG.save.data.chart_waveformVoices;
		waveformUseVoices.callback = function()
		{
			waveformUseInstrumental.checked = false;
			FlxG.save.data.chart_waveformInst = false;
			FlxG.save.data.chart_waveformVoices = waveformUseVoices.checked;
			updateWaveform();
		};

		check_mute_inst = new FlxUICheckBox(10, 310, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};
		mouseScrollingQuant = new FlxUICheckBox(10, 180, null, null, "Mouse Scrolling Quantization", 100);
		if (FlxG.save.data.mouseScrollingQuant == null) FlxG.save.data.mouseScrollingQuant = false;
		mouseScrollingQuant.checked = FlxG.save.data.mouseScrollingQuant;

		mouseScrollingQuant.callback = function()
		{
			FlxG.save.data.mouseScrollingQuant = mouseScrollingQuant.checked;
			mouseQuant = FlxG.save.data.mouseScrollingQuant;
		};

		check_vortex = new FlxUICheckBox(10, 150, null, null, "Vortex Editor (BETA)", 100);
		if (FlxG.save.data.chart_vortex == null) FlxG.save.data.chart_vortex = false;
		check_vortex.checked = FlxG.save.data.chart_vortex;

		check_vortex.callback = function()
		{
			FlxG.save.data.chart_vortex = check_vortex.checked;
			vortex = FlxG.save.data.chart_vortex;
			reloadGridLayer();
		};


		check_warnings = new FlxUICheckBox(10, 120, null, null, "Ignore Progress Warnings", 100);
		if (FlxG.save.data.ignoreWarnings == null) FlxG.save.data.ignoreWarnings = false;
		check_warnings.checked = FlxG.save.data.ignoreWarnings;

		check_warnings.callback = function()
		{
			FlxG.save.data.ignoreWarnings = check_warnings.checked;
			ignoreWarnings = FlxG.save.data.ignoreWarnings;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if(vocals != null) {
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};

		playSoundBf = new FlxUICheckBox(check_mute_inst.x, check_mute_vocals.y + 30, null, null, 'Play Sound (Boyfriend notes)', 100,
			function() {
				FlxG.save.data.chart_playSoundBf = playSoundBf.checked;
			}
		);
		if (FlxG.save.data.chart_playSoundBf == null) FlxG.save.data.chart_playSoundBf = false;
		playSoundBf.checked = FlxG.save.data.chart_playSoundBf;

		playSoundDad = new FlxUICheckBox(check_mute_inst.x + 120, playSoundBf.y, null, null, 'Play Sound (Opponent notes)', 100,
			function() {
				FlxG.save.data.chart_playSoundDad = playSoundDad.checked;
			}
		);
		if (FlxG.save.data.chart_playSoundDad == null) FlxG.save.data.chart_playSoundDad = false;
		playSoundDad.checked = FlxG.save.data.chart_playSoundDad;

		metronome = new FlxUICheckBox(10, 15, null, null, "Metronome Enabled", 100,
			function() {
				FlxG.save.data.chart_metronome = metronome.checked;
			}
		);
		if (FlxG.save.data.chart_metronome == null) FlxG.save.data.chart_metronome = false;
		metronome.checked = FlxG.save.data.chart_metronome;

		metronomeStepper = new FlxUINumericStepper(15, 55, 5, _song.bpm, 1, 1500, 1);
		metronomeOffsetStepper = new FlxUINumericStepper(metronomeStepper.x + 100, metronomeStepper.y, 25, 0, 0, 1000, 1);
		blockPressWhileTypingOnStepper.push(metronomeStepper);
		blockPressWhileTypingOnStepper.push(metronomeOffsetStepper);

		disableAutoScrolling = new FlxUICheckBox(metronome.x + 120, metronome.y, null, null, "Disable Autoscroll (Not Recommended)", 120,
			function() {
				FlxG.save.data.chart_noAutoScroll = disableAutoScrolling.checked;
			}
		);
		if (FlxG.save.data.chart_noAutoScroll == null) FlxG.save.data.chart_noAutoScroll = false;
		disableAutoScrolling.checked = FlxG.save.data.chart_noAutoScroll;

		instVolume = new FlxUINumericStepper(metronomeStepper.x, 270, 0.1, 1, 0, 1, 1);
		instVolume.value = FlxG.sound.music.volume;
		instVolume.name = 'inst_volume';
		blockPressWhileTypingOnStepper.push(instVolume);

		voicesVolume = new FlxUINumericStepper(instVolume.x + 100, instVolume.y, 0.1, 1, 0, 1, 1);
		voicesVolume.value = vocals.volume;
		voicesVolume.name = 'voices_volume';
		blockPressWhileTypingOnStepper.push(voicesVolume);
		
		#if !html5
		sliderRate = new FlxUISlider(this, 'playbackSpeed', 120, 120, 0.5, 3, 150, null, 5, FlxColor.WHITE, FlxColor.BLACK);
		sliderRate.nameLabel.text = 'Playback Rate';
		tab_group_chart.add(sliderRate);
		#end

		tab_group_chart.add(new FlxText(metronomeStepper.x, metronomeStepper.y - 15, 0, 'BPM:'));
		tab_group_chart.add(new FlxText(metronomeOffsetStepper.x, metronomeOffsetStepper.y - 15, 0, 'Offset (ms):'));
		tab_group_chart.add(new FlxText(instVolume.x, instVolume.y - 15, 0, 'Inst Volume'));
		tab_group_chart.add(new FlxText(voicesVolume.x, voicesVolume.y - 15, 0, 'Voices Volume'));
		tab_group_chart.add(metronome);
		tab_group_chart.add(disableAutoScrolling);
		tab_group_chart.add(metronomeStepper);
		tab_group_chart.add(metronomeOffsetStepper);
		tab_group_chart.add(waveformUseInstrumental);
		tab_group_chart.add(waveformUseVoices);
		tab_group_chart.add(instVolume);
		tab_group_chart.add(voicesVolume);
		tab_group_chart.add(check_mute_inst);
		tab_group_chart.add(check_mute_vocals);
		tab_group_chart.add(check_vortex);
		tab_group_chart.add(mouseScrollingQuant);
		tab_group_chart.add(check_warnings);
		tab_group_chart.add(playSoundBf);
		tab_group_chart.add(playSoundDad);
		UI_box.addGroup(tab_group_chart);
	}

	function loadSong():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		var file:Dynamic = Paths.voices(currentSongName);
		vocals = new FlxSound();
		if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file)) {
			vocals.loadEmbedded(file);
			FlxG.sound.list.add(vocals);
		}
		generateSong();
		FlxG.sound.music.pause();
		Conductor.songPosition = sectionStartTime();
		FlxG.sound.music.time = Conductor.songPosition;
	}

	function generateSong() {
		FlxG.sound.playMusic(Paths.inst(currentSongName), 0.6/*, false*/);
		if (instVolume != null) FlxG.sound.music.volume = instVolume.value;
		if (check_mute_inst != null && check_mute_inst.checked) FlxG.sound.music.volume = 0;

		FlxG.sound.music.onComplete = function()
		{
			FlxG.sound.music.pause();
			Conductor.songPosition = 0;
			if(vocals != null) {
				vocals.pause();
				vocals.time = 0;
			}
			changeSection();
			curSec = 0;
			updateGrid();
			updateSectionUI();
			vocals.play();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSec].mustHitSection = check.checked;

					updateGrid();
					updateHeads();

				case 'GF section':
					_song.notes[curSec].gfSection = check.checked;

					updateGrid();
					updateHeads();

				case 'Change BPM':
					_song.notes[curSec].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSec].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_beats')
			{
				_song.notes[curSec].sectionBeats = nums.value;
				reloadGridLayer();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				if(curSelectedNote != null && curSelectedNote[2] != null) {
					curSelectedNote[2] = nums.value;
					updateGrid();
				}
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSec].bpm = nums.value;
				updateGrid();
			}
			else if (wname == 'inst_volume')
			{
				FlxG.sound.music.volume = nums.value;
			}
			else if (wname == 'voices_volume')
			{
				vocals.volume = nums.value;
			}
		}
		else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == noteSplashesInputText) {
				_song.splashSkin = noteSplashesInputText.text;
			}
			if(sender == noteSplashesInputTextOpt) {
				_song.splashSkinOpt = noteSplashesInputTextOpt.text;
			}
			if(sender == noteSplashesInputTextSec) {
				_song.splashSkinSec = noteSplashesInputTextSec.text;
			}
			else if(curSelectedNote != null)
			{
				if(sender == value1InputText) {
					if(curSelectedNote[1][curEventSelected] != null)
					{
						curSelectedNote[1][curEventSelected][1] = value1InputText.text;
						updateGrid();
					}
				}
				else if(sender == value2InputText) {
					if(curSelectedNote[1][curEventSelected] != null)
					{
						curSelectedNote[1][curEventSelected][2] = value2InputText.text;
						updateGrid();
					}
				}
				else if(sender == strumTimeInputText) {
					var value:Float = Std.parseFloat(strumTimeInputText.text);
					if(Math.isNaN(value)) value = 0;
					curSelectedNote[0] = value;
					updateGrid();
				}
			}
		}
		else if (id == FlxUISlider.CHANGE_EVENT && (sender is FlxUISlider))
		{
			switch (sender)
			{
				case 'playbackSpeed':
					playbackSpeed = Std.int(sliderRate.value);
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSec + add)
		{
			if(_song.notes[i] != null)
			{
				if (_song.notes[i].changeBPM)
				{
					daBPM = _song.notes[i].bpm;
				}
				daPos += getSectionBeats(i) * (1000 * 60 / daBPM);
			}
		}
		return daPos;
	}

	var lastConductorPos:Float;
	var colorSine:Float = 0;
	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if(FlxG.sound.music.time < 0) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = UI_songTitle.text;

		strumLineUpdateY();
		for (i in 0...12){
			strumLineNotes.members[i].y = strumLine.y;
		}
		FlxG.mouse.visible = true;
		//cause reasons. trust me
		camPos.y = strumLine.y;
		if(!disableAutoScrolling.checked) {
			if (Math.ceil(strumLine.y) >= gridBG.height)
			{
				if (_song.notes[curSec + 1] == null)
				{
					addSection();
				}

				changeSection(curSec + 1, false);
			} else if(strumLine.y < -10) {
				changeSection(curSec - 1, false);
			}
		}
		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		#if !mobile
		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
		{
			dummyArrow.visible = true;
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end))
				dummyArrow.y = FlxG.mouse.y;
			else
			{
				var gridmult = GRID_SIZE / (quantization / 16);
				dummyArrow.y = Math.floor(FlxG.mouse.y / gridmult) * gridmult;
			}
		} else {
			dummyArrow.visible = false;
		}

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes) && !((FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end) && (FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end)))//alt + ctrl for multiplace notes
			{
				curRenderedNotes.forEachAlive(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if ((FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end))
							{
								selectNote(note);
							}
							else if ((FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end))
							{
								selectNote(note);
								curSelectedNote[3] = noteTypeIntMap.get(currentType);
								updateGrid();
							}
							else
							{
								//trace('tryin to delete note...');
								deleteNote(note);
							}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
				{
					FlxG.log.add('added note');
					addNote(null, null, null, FlxG.mouse.x);
				}
			}
		}
		#else
		if (!handButton.enable) {//not accident press
			for (i in FlxG.touches.list) {
				if (i.x > gridBG.x
					&& i.x < gridBG.x + gridBG.width
					&& i.y > gridBG.y
					&& i.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
				{
					dummyArrow.visible = true;
					dummyArrow.x = Math.floor(i.x / GRID_SIZE) * GRID_SIZE;
					if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end))
						dummyArrow.y = i.y;
					else
					{
						var gridmult = GRID_SIZE / (quantization / 16);
						dummyArrow.y = Math.floor(i.y / gridmult) * gridmult;
					}
				} else {
					dummyArrow.visible = false;
				}
				if (i.justReleased)
				{
					if (i.overlaps(curRenderedNotes) && !((FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end) && (FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end)))//alt + ctrl for multiplace notes
					{
						curRenderedNotes.forEachAlive(function(note:Note)
						{
							if (i.overlaps(note))
							{
								if ((FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end))
									{
										selectNote(note);
									}
									else if ((FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end))
									{
										selectNote(note);
										curSelectedNote[3] = noteTypeIntMap.get(currentType);
										updateGrid();
									}
									else
									{
										//trace('tryin to delete note...');
										deleteNote(note);
									}
							}
						});
					}
					else
					{
						if (i.x > gridBG.x
							&& i.x < gridBG.x + gridBG.width
							&& i.y > gridBG.y
							&& i.y < gridBG.y + (GRID_SIZE * getSectionBeats() * 4) * zoomList[curZoom])
						{
							FlxG.log.add('added note');
							addNote(null, null, null, i.x);
						}
					}
				}
			}
		}
		#end

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}

		if(!blockInput) {
			for (stepper in blockPressWhileTypingOnStepper) {
				@:privateAccess
				var leText:Dynamic = stepper.text_field;
				var leText:FlxUIInputText = leText;
				if(leText.hasFocus) {
					FlxG.sound.muteKeys = [];
					FlxG.sound.volumeDownKeys = [];
					FlxG.sound.volumeUpKeys = [];
					blockInput = true;
					break;
				}
			}
		}

		if(!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			for (dropDownMenu in blockPressWhileScrolling) {
				if(dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justPressed.BACK #end)
			{
				autosaveSong();
				LoadingState.loadAndSwitchState(new editors.EditorPlayState(sectionStartTime()));
			}
			if (FlxG.keys.justPressed.ENTER #if mobile || enterButton.justPressed #end)
			{
				autosaveSong();
				FlxG.mouse.visible = false;
				PlayState.SONG = _song;
				FlxG.sound.music.stop();
				if(vocals != null) vocals.stop();

				//if(_song.stage == null) _song.stage = stageDropDown.selectedLabel;
				StageData.loadDirectory(_song);
				LoadingState.loadAndSwitchState(new PlayState());
			}

			if(curSelectedNote != null && curSelectedNote[1] > -1) {
				if (FlxG.keys.justPressed.E #if mobile || downButton.justPressed #end)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q #if mobile || upButton.justPressed #end)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
			}


			if (FlxG.keys.justPressed.BACKSPACE #if mobile || backButton.justPressed #end) {
				PlayState.chartingMode = false;
				MusicBeatState.switchState(new editors.MasterEditorMenu());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				FlxG.mouse.visible = false;
				return;
			}

			if((FlxG.keys.justPressed.Z #if mobile || zButton.justPressed #end) && (FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end)) {
				undo();
			}



			if((FlxG.keys.justPressed.Z #if mobile || zButton.justPressed #end) && curZoom > 0 && !(FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end)) {
				--curZoom;
				updateZoom();
			}
			if((FlxG.keys.justPressed.X #if mobile || xButton.justPressed #end) && curZoom < zoomList.length-1) {
				curZoom++;
				updateZoom();
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end))
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

			if (FlxG.keys.justPressed.SPACE  #if mobile || spaceButton.justPressed #end)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if(vocals != null) vocals.pause();
				}
				else
				{
					if(vocals != null) {
						vocals.play();
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
						vocals.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (!(FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end) && FlxG.keys.justPressed.R)
			{
				if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end))
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				if (!mouseQuant)
					FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet*0.8);
				else
					{
						var time:Float = FlxG.sound.music.time;
						var beat:Float = curDecBeat;
						var snap:Float = quantization / 4;
						var increase:Float = 1 / snap;
						if (FlxG.mouse.wheel > 0)
						{
							var fuck:Float = CoolUtil.quantize(beat, snap) - increase;
							FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
						}else{
							var fuck:Float = CoolUtil.quantize(beat, snap) + increase;
							FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
						}
					}
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
			}
			#if mobile
			if (handButton.enable) {
				var wheelRange = dge.backend.TouchUtil.scrollSwipe(0.5);
				if (wheelRange != 0)
				{
					FlxG.sound.music.pause();
					if (!mouseQuant)
						FlxG.sound.music.time -= (wheelRange * Conductor.stepCrochet*0.8);
					else
						{
							var time:Float = FlxG.sound.music.time;
							var beat:Float = curDecBeat;
							var snap:Float = quantization / 4;
							var increase:Float = 1 / snap;
							if (wheelRange > 0)
							{
								var fuck:Float = CoolUtil.quantize(beat, snap) - increase;
								FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
							}else{
								var fuck:Float = CoolUtil.quantize(beat, snap) + increase;
								FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
							}
						}
					if(vocals != null) {
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
					}
				}
			}
			#end

			//ARROW VORTEX SHIT NO DEADASS



			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FlxG.sound.music.pause();

				var holdingShift:Float = 1;
				if ((FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end)) holdingShift = 0.25;
				else if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end)) holdingShift = 4;

				var daTime:Float = 700 * FlxG.elapsed * holdingShift;

				if (FlxG.keys.pressed.W)
				{
					FlxG.sound.music.time -= daTime;
				}
				else
					FlxG.sound.music.time += daTime;

				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
			}

			if(!vortex){
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN  )
				{
					FlxG.sound.music.pause();
					updateCurStep();
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;
					if (FlxG.keys.pressed.UP)
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) - increase; //(Math.floor((beat+snap) / snap) * snap);
						FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
					}else{
						var fuck:Float = CoolUtil.quantize(beat, snap) + increase; //(Math.floor((beat+snap) / snap) * snap);
						FlxG.sound.music.time = Conductor.beatToSeconds(fuck);
					}
				}
			}

			var style = currentType;

			if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end)){
				style = 3;
			}

			var conductorTime = Conductor.songPosition; //+ sectionStartTime();Conductor.songPosition / Conductor.stepCrochet;

			//AWW YOU MADE IT SEXY <3333 THX SHADMAR

			if(!blockInput){
				if(FlxG.keys.justPressed.RIGHT #if mobile || rightButton.justPressed #end){
					curQuant++;
					if(curQuant>quantizations.length-1)
						curQuant = 0;

					quantization = quantizations[curQuant];
				}

				if(FlxG.keys.justPressed.LEFT #if mobile || leftButton.justPressed #end){
					curQuant--;
					if(curQuant<0)
						curQuant = quantizations.length-1;

					quantization = quantizations[curQuant];
				}
				quant.animation.play('q', true, false, curQuant);
			}
			if(vortex && !blockInput){
				var controlArray:Array<Bool> = [FlxG.keys.justPressed.ONE, FlxG.keys.justPressed.TWO, FlxG.keys.justPressed.THREE, FlxG.keys.justPressed.FOUR,
											   FlxG.keys.justPressed.FIVE, FlxG.keys.justPressed.SIX, FlxG.keys.justPressed.SEVEN, FlxG.keys.justPressed.EIGHT];

				if(controlArray.contains(true))
				{
					for (i in 0...controlArray.length)
					{
						if(controlArray[i])
							doANoteThing(conductorTime, i, style);
					}
				}

				var feces:Float;
				if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN  )
				{
					FlxG.sound.music.pause();


					updateCurStep();
					//FlxG.sound.music.time = (Math.round(curStep/quants[curQuant])*quants[curQuant]) * Conductor.stepCrochet;

						//(Math.floor((curStep+quants[curQuant]*1.5/(quants[curQuant]/2))/quants[curQuant])*quants[curQuant]) * Conductor.stepCrochet;//snap into quantization
					var time:Float = FlxG.sound.music.time;
					var beat:Float = curDecBeat;
					var snap:Float = quantization / 4;
					var increase:Float = 1 / snap;
					if (FlxG.keys.pressed.UP)
					{
						var fuck:Float = CoolUtil.quantize(beat, snap) - increase;
						feces = Conductor.beatToSeconds(fuck);
					}else{
						var fuck:Float = CoolUtil.quantize(beat, snap) + increase; //(Math.floor((beat+snap) / snap) * snap);
						feces = Conductor.beatToSeconds(fuck);
					}
					FlxTween.tween(FlxG.sound.music, {time:feces}, 0.1, {ease:FlxEase.circOut});
					if(vocals != null) {
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
					}

					var dastrum = 0;

					if (curSelectedNote != null){
						dastrum = curSelectedNote[0];
					}

					var secStart:Float = sectionStartTime();
					var datime = (feces - secStart) - (dastrum - secStart); //idk math find out why it doesn't work on any other section other than 0
					if (curSelectedNote != null)
					{
						var controlArray:Array<Bool> = [FlxG.keys.pressed.ONE, FlxG.keys.pressed.TWO, FlxG.keys.pressed.THREE, FlxG.keys.pressed.FOUR,
													   FlxG.keys.pressed.FIVE, FlxG.keys.pressed.SIX, FlxG.keys.pressed.SEVEN, FlxG.keys.pressed.EIGHT];

						if(controlArray.contains(true))
						{

							for (i in 0...controlArray.length)
							{
								if(controlArray[i])
									if(curSelectedNote[1] == i) curSelectedNote[2] += datime - curSelectedNote[2] - Conductor.stepCrochet;
							}
							updateGrid();
							updateNoteUI();
						}
					}
				}
			}
			var shiftThing:Int = 1;
			if ((FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end))
				shiftThing = 4;

			if (FlxG.keys.justPressed.D)
				changeSection(curSec + shiftThing);
			if (FlxG.keys.justPressed.A) {
				if(curSec <= 0) {
					changeSection(_song.notes.length-1);
				} else {
					changeSection(curSec - shiftThing);
				}
			}
		} else if (FlxG.keys.justPressed.ENTER  #if mobile || enterButton.justPressed #end) {
			for (i in 0...blockPressWhileTypingOn.length) {
				if(blockPressWhileTypingOn[i].hasFocus) {
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		_song.bpm = tempBpm;

		strumLineNotes.visible = quant.visible = vortex;

		if(FlxG.sound.music.time < 0) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		strumLineUpdateY();
		camPos.y = strumLine.y;
		for (i in 0...12){
			strumLineNotes.members[i].y = strumLine.y;
			strumLineNotes.members[i].alpha = FlxG.sound.music.playing ? 1 : 0.35;
		}

		// PLAYBACK SPEED CONTROLS //
		var holdingShift = (FlxG.keys.pressed.SHIFT #if mobile || shiftButton.pressed #end);
		var holdingLB = FlxG.keys.pressed.LBRACKET #if mobile || leftBracketButton.pressed #end;
		var holdingRB = FlxG.keys.pressed.RBRACKET #if mobile || rightBracketButton.pressed #end;
		var pressedLB = FlxG.keys.justPressed.LBRACKET #if mobile || leftBracketButton.justPressed #end;
		var pressedRB = FlxG.keys.justPressed.RBRACKET #if mobile || rightBracketButton.justPressed #end;

		if (!holdingShift && pressedLB || holdingShift && holdingLB)
			playbackSpeed -= 0.01;
		if (!holdingShift && pressedRB || holdingShift && holdingRB)
			playbackSpeed += 0.01;
		if ((FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end) && (pressedLB || pressedRB || holdingLB || holdingRB))
			playbackSpeed = 1;
		//

		if (playbackSpeed <= 0.5)
			playbackSpeed = 0.5;
		if (playbackSpeed >= 3)
			playbackSpeed = 3;

		FlxG.sound.music.pitch = playbackSpeed;
		vocals.pitch = playbackSpeed;

		bpmTxt.text =
		Std.string(Math.floor((Conductor.songPosition/1000)/60)) + ":" + Std.string(FlxMath.roundDecimal((Math.floor((Conductor.songPosition/1000) * 100) / 100) % 60, 2)) + " / " + Std.string(Math.floor((FlxG.sound.music.length/1000)/60)) + ":" + Std.string(FlxMath.roundDecimal((Math.floor((FlxG.sound.music.length/1000) * 100) / 100) % 60, 2)) +
		"\n\nSection: " + curSec +
		"\n\nBeat: " + Std.string(curDecBeat).substring(0,4) +
		"\n\nStep: " + curStep +
		"\n\nBeat Snap: " + quantization + "th";
		bpmTxt.y = FlxG.height - (bpmTxt.height+10);
		zoomTxt.y = bpmTxt.y - (zoomTxt.height+10);

		var playedSound:Array<Bool> = [false, false, false, false]; //Prevents ouchy GF sex sounds
		if (curSec > 0) {

			prevRenderedNotes.forEachAlive(function(note:Note) {
				note.alpha = 1;
				if(curSelectedNote != null) {
					var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
					var noteDataToCheck:Int = actualNoteData;
	
					if (curSelectedNote[0] == note.strumTime && ((curSelectedNote[2] == null && noteDataToCheck < 0) || (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
					{
						colorSine += elapsed;
						var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
						note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
					}
				}
	
				if(note.strumTime <= Conductor.songPosition) {
					note.alpha = 0.4;
					if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1) {
						var data:Int = note.noteData % 4;
						var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
						var noteDataToCheck:Int = actualNoteData;
						if (!note.ignoreNote) {
							if (!note.noAnimation) {
								if (!note.mustPress) {
									optChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
								} else {
									plyChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
								}
							}
							if (note.playStrumAnim && !note.fakeNoHit) {
								strumLineNotes.members[noteDataToCheck].playAnim(note.animConfirm.length == 0 ? 'confirm' : note.animConfirm, true);
								strumLineNotes.members[noteDataToCheck].resetAnim = 0.15;
							}
							if(!playedSound[data]) {
								if((((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)) && !note.hitsoundDisabled) || note.forceHitsound){
									var soundToPlay = note.hitsound;
									if(_song.player1 == 'gf') { //Easter egg
										soundToPlay = 'GF_' + Std.string(data + 1);
									}
		
									FlxG.sound.play(Paths.sound(soundToPlay)).pan = note.noteData < 4? -0.3 : 0.3; //would be coolio
									playedSound[data] = true;
								}
		
								data = note.noteData;
								if(note.mustPress != _song.notes[curSec-1].mustHitSection)
								{
									data += 4;
								}
							}
						}
					}
				}
			});
			prevRenderedSustains.forEachAlive(function(note:Note) {
				note.alpha = 1;
				if(curSelectedNote != null) {
					var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
					var noteDataToCheck:Int = actualNoteData;
	
					if (curSelectedNote[0] == note.strumTime && ((curSelectedNote[2] == null && noteDataToCheck < 0) || (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
					{
						colorSine += elapsed;
						var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
						note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
					}
				}
	
				if(note.strumTime <= Conductor.songPosition) {
					note.alpha = 0.4;
					if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1) {
						var data:Int = note.noteData % 4;
						var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
						var noteDataToCheck:Int = actualNoteData;
						if (!note.ignoreNote) {

							if (!note.noAnimation) {
								if (!note.mustPress) {
									optChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
								} else {
									plyChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
								}
							}
							if (note.playStrumAnim && !note.fakeNoHit) {
								strumLineNotes.members[noteDataToCheck].playAnim(note.animConfirm.length == 0 ? 'confirm' : note.animConfirm, true);
								strumLineNotes.members[noteDataToCheck].resetAnim = 0.15;
							}
							if(!playedSound[data]) {
								if((((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)) && !note.hitsoundDisabled) || note.forceHitsound){
									var soundToPlay = note.hitsound;
									if(_song.player1 == 'gf') { //Easter egg
										soundToPlay = 'GF_' + Std.string(data + 1);
									}
		
									FlxG.sound.play(Paths.sound(soundToPlay)).pan = note.noteData < 4? -0.3 : 0.3; //would be coolio
									playedSound[data] = true;
								}
		
								data = note.noteData;
								if(note.mustPress != _song.notes[curSec-1].mustHitSection)
								{
									data += 4;
								}
							}
						}
					}
				}
			});
		}
		curRenderedNotes.forEachAlive(function(note:Note) {
			note.alpha = 1;
			if(curSelectedNote != null) {
				var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
				var noteDataToCheck:Int = actualNoteData;

				if (curSelectedNote[0] == note.strumTime && ((curSelectedNote[2] == null && noteDataToCheck < 0) || (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}

			if(note.strumTime <= Conductor.songPosition) {
				note.alpha = 0.4;
				if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1) {
					var data:Int = note.noteData % 4;
					var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
					var noteDataToCheck:Int = actualNoteData;
					if (!note.ignoreNote) {

						if (!note.noAnimation) {
							if (!note.mustPress) {
								optChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
							} else {
								plyChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
							}
						}
						if (note.playStrumAnim && !note.fakeNoHit) {
							strumLineNotes.members[noteDataToCheck].playAnim(note.animConfirm.length == 0 ? 'confirm' : note.animConfirm, true);
							strumLineNotes.members[noteDataToCheck].resetAnim = 0.15;
						}
						if(!playedSound[data]) {
							if((((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)) && !note.hitsoundDisabled) || note.forceHitsound){
								var soundToPlay = note.hitsound;
								if(_song.player1 == 'gf') { //Easter egg
									soundToPlay = 'GF_' + Std.string(data + 1);
								}
	
								FlxG.sound.play(Paths.sound(soundToPlay)).pan = note.noteData < 4? -0.3 : 0.3; //would be coolio
								playedSound[data] = true;
							}
	
							data = note.noteData;
							if(note.mustPress != _song.notes[curSec].mustHitSection)
							{
								data += 4;
							}
						}
					}
				}
			}
		});
		curRenderedSustains.forEachAlive(function(note:Note) {
			note.alpha = 1;
			if(curSelectedNote != null) {
				var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
				var noteDataToCheck:Int = actualNoteData;

				if (curSelectedNote[0] == note.strumTime && ((curSelectedNote[2] == null && noteDataToCheck < 0) || (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck)))
				{
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}

			if(note.strumTime <= Conductor.songPosition) {
				note.alpha = 0.4;
				if(note.strumTime > lastConductorPos && FlxG.sound.music.playing && note.noteData > -1) {
					var data:Int = note.noteData % 4;
					var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
					var noteDataToCheck:Int = actualNoteData;
					if (!note.ignoreNote) {

						if (!note.noAnimation) {
							if (!note.mustPress) {
								optChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
							} else {
								plyChar.animation.play("sing"+animAssets[note.noteData].toUpperCase(), true);
							}
						}
						if (note.playStrumAnim && !note.fakeNoHit) {
							strumLineNotes.members[noteDataToCheck].playAnim(note.animConfirm.length == 0 ? 'confirm' : note.animConfirm, true);
							strumLineNotes.members[noteDataToCheck].resetAnim = 0.15;
						}
						if(!playedSound[data]) {
							if((((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)) && !note.hitsoundDisabled) || note.forceHitsound){
								var soundToPlay = note.hitsound;
								if(_song.player1 == 'gf') { //Easter egg
									soundToPlay = 'GF_' + Std.string(data + 1);
								}
	
								FlxG.sound.play(Paths.sound(soundToPlay)).pan = note.noteData < 4? -0.3 : 0.3; //would be coolio
								playedSound[data] = true;
							}
	
							data = note.noteData;
							if(note.mustPress != _song.notes[curSec].mustHitSection)
							{
								data += 4;
							}
						}
					}
				}
			}
		});

		if(metronome.checked && lastConductorPos != Conductor.songPosition) {
			var metroInterval:Float = 60 / metronomeStepper.value;
			var metroStep:Int = Math.floor(((Conductor.songPosition + metronomeOffsetStepper.value) / metroInterval) / 1000);
			var lastMetroStep:Int = Math.floor(((lastConductorPos + metronomeOffsetStepper.value) / metroInterval) / 1000);
			if(metroStep != lastMetroStep) {
				FlxG.sound.play(Paths.sound('Metronome_Tick'));
				//trace('Ticked');
			}
		}
		optChar.y = strumLine.y+(FlxG.height/2)-(optChar.height);
		plyChar.y = strumLine.y+(FlxG.height/2)-(plyChar.height);
		if (plyChar.animation.finished && plyChar.animation.curAnim.name != 'idle') {
			plyChar.animation.play('idle');
		}
		if (optChar.animation.finished && optChar.animation.curAnim.name != 'idle') {
			optChar.animation.play('idle');
		}
		lastConductorPos = Conductor.songPosition;
		super.update(elapsed);
	}

	function updateZoom() {
		var daZoom:Float = zoomList[curZoom];
		var zoomThing:String = '1 / ' + daZoom;
		if(daZoom < 1) zoomThing = Math.round(1 / daZoom) + ' / 1';
		zoomTxt.text = 'Zoom: ' + zoomThing;
		reloadGridLayer();
	}

	/*
	function loadAudioBuffer() {
		if(audioBuffers[0] != null) {
			audioBuffers[0].dispose();
		}
		audioBuffers[0] = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders('songs/' + currentSongName + '/Inst.ogg'))) {
			audioBuffers[0] = AudioBuffer.fromFile(Paths.modFolders('songs/' + currentSongName + '/Inst.ogg'));
			//trace('Custom vocals found');
		}
		else { #end
			var leVocals:String = Paths.getPath(currentSongName + '/Inst.' + Paths.SOUND_EXT, SOUND, 'songs');
			if (OpenFlAssets.exists(leVocals)) { //Vanilla inst
				audioBuffers[0] = AudioBuffer.fromFile('./' + leVocals.substr(6));
				//trace('Inst found');
			}
		#if MODS_ALLOWED
		}
		#end

		if(audioBuffers[1] != null) {
			audioBuffers[1].dispose();
		}
		audioBuffers[1] = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders('songs/' + currentSongName + '/Voices.ogg'))) {
			audioBuffers[1] = AudioBuffer.fromFile(Paths.modFolders('songs/' + currentSongName + '/Voices.ogg'));
			//trace('Custom vocals found');
		} else { #end
			var leVocals:String = Paths.getPath(currentSongName + '/Voices.' + Paths.SOUND_EXT, SOUND, 'songs');
			if (OpenFlAssets.exists(leVocals)) { //Vanilla voices
				audioBuffers[1] = AudioBuffer.fromFile('./' + leVocals.substr(6));
				//trace('Voices found, LETS FUCKING GOOOO');
			}
		#if MODS_ALLOWED
		}
		#end
	}
	*/

	var lastSecBeats:Float = 0;
	var lastSecBeatsNext:Float = 0;
	function reloadGridLayer() {
		gridLayer.clear();
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 13, Std.int(GRID_SIZE * getSectionBeats() * 4 * zoomList[curZoom]), true , (ClientPrefs.darkmode ? 0xff000000 : 0xffffffff), (ClientPrefs.darkmode ? 0xff202020 : 0xffcccccc));
		prevGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 13, Std.int(GRID_SIZE * getSectionBeats(curSec - 1) * 4 * zoomList[curZoom]), true , (ClientPrefs.darkmode ? 0xff000000 : 0xffffffff), (ClientPrefs.darkmode ? 0xff202020 : 0xffcccccc));
		prevGridBG.y = -prevGridBG.height;
		prevGridBG.alpha = 0.4;

		if(FlxG.save.data.chart_waveformInst || FlxG.save.data.chart_waveformVoices) {
			updateWaveform();
		}

		var leHeight:Int = Std.int(gridBG.height);
		var foundNextSec:Bool = false;
		if(sectionStartTime(1) <= FlxG.sound.music.length)
		{
			nextGridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 13, Std.int(GRID_SIZE * getSectionBeats(curSec + 1) * 4 * zoomList[curZoom]), true , (ClientPrefs.darkmode ? 0xff000000 : 0xffe7e6e6), (ClientPrefs.darkmode ? 0xff202020 : 0xffd9d5d5));
			leHeight = Std.int(gridBG.height + nextGridBG.height);
			foundNextSec = true;
		}
		else nextGridBG = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
		nextGridBG.y = gridBG.height;
		
		gridLayer.add(prevGridBG);
		gridLayer.add(nextGridBG);
		gridLayer.add(gridBG);

		if(foundNextSec)
		{
			var gridBlack:FlxSprite = new FlxSprite(0, gridBG.height).makeGraphic(Std.int(GRID_SIZE * 13), Std.int(nextGridBG.height), FlxColor.BLACK);
			gridBlack.alpha = 0.4;
			gridLayer.add(gridBlack);
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, leHeight, FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		for (i in 1...4) {
			var beatsep1:FlxSprite = new FlxSprite(gridBG.x, (GRID_SIZE * (4 * curZoom)) * i).makeGraphic(Std.int(gridBG.width), 1, 0x44FF0000);
			if(vortex)
			{
				gridLayer.add(beatsep1);
			}
		}

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, leHeight, FlxColor.BLACK);
		gridLayer.add(gridBlackLine);
		updateGrid();

		lastSecBeats = getSectionBeats();
		if(sectionStartTime(1) > FlxG.sound.music.length) lastSecBeatsNext = 0;
		else getSectionBeats(curSec + 1);
	}

	function strumLineUpdateY()
	{
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * 16)) / (getSectionBeats() / 4);
	}

	var waveformPrinted:Bool = true;
	var wavData:Array<Array<Array<Float>>> = [[[0], [0]], [[0], [0]]];
	function updateWaveform() {
		if(waveformPrinted) {
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * 8), Std.int(gridBG.height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, gridBG.width, gridBG.height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		if(!FlxG.save.data.chart_waveformInst && !FlxG.save.data.chart_waveformVoices) {
			//trace('Epic fail on the waveform lol');
			return;
		}

		wavData[0][0] = [];
		wavData[0][1] = [];
		wavData[1][0] = [];
		wavData[1][1] = [];

		var steps:Int = Math.round(getSectionBeats() * 4);
		var st:Float = sectionStartTime();
		var et:Float = st + (Conductor.stepCrochet * steps);

		if (FlxG.save.data.chart_waveformInst) {
			var sound:FlxSound = FlxG.sound.music;
			if (sound._sound != null && sound._sound.__buffer != null) {
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(
					sound._sound.__buffer,
					bytes,
					st,
					et,
					1,
					wavData,
					Std.int(gridBG.height)
				);
			}
		}

		if (FlxG.save.data.chart_waveformVoices) {
			var sound:FlxSound = vocals;
			if (sound._sound != null && sound._sound.__buffer != null) {
				var bytes:Bytes = sound._sound.__buffer.data.toBytes();

				wavData = waveformData(
					sound._sound.__buffer,
					bytes,
					st,
					et,
					1,
					wavData,
					Std.int(gridBG.height)
				);
			}
		}

		// Draws
		var gSize:Int = Std.int(GRID_SIZE * 8);
		var hSize:Int = Std.int(gSize / 2);

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var size:Float = 1;

		var leftLength:Int = (
			wavData[0][0].length > wavData[0][1].length ? wavData[0][0].length : wavData[0][1].length
		);

		var rightLength:Int = (
			wavData[1][0].length > wavData[1][1].length ? wavData[1][0].length : wavData[1][1].length
		);

		var length:Int = leftLength > rightLength ? leftLength : rightLength;

		var index:Int;
		for (i in 0...length) {
			index = i;

			lmin = FlxMath.bound(((index < wavData[0][0].length && index >= 0) ? wavData[0][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			lmax = FlxMath.bound(((index < wavData[0][1].length && index >= 0) ? wavData[0][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			rmin = FlxMath.bound(((index < wavData[1][0].length && index >= 0) ? wavData[1][0][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;
			rmax = FlxMath.bound(((index < wavData[1][1].length && index >= 0) ? wavData[1][1][index] : 0) * (gSize / 1.12), -hSize, hSize) / 2;

			waveformSprite.pixels.fillRect(new Rectangle(hSize - (lmin + rmin), i * size, (lmin + rmin) + (lmax + rmax), size), FlxColor.BLUE);
		}

		waveformPrinted = true;
	}

	function waveformData(buffer:AudioBuffer, bytes:Bytes, time:Float, endTime:Float, multiply:Float = 1, ?array:Array<Array<Array<Float>>>, ?steps:Float):Array<Array<Array<Float>>>
	{
		#if (lime_cffi && !macro)
		if (buffer == null || buffer.data == null) return [[[0], [0]], [[0], [0]]];

		var khz:Float = (buffer.sampleRate / 1000);
		var channels:Int = buffer.channels;

		var index:Int = Std.int(time * khz);

		var samples:Float = ((endTime - time) * khz);

		if (steps == null) steps = 1280;

		var samplesPerRow:Float = samples / steps;
		var samplesPerRowI:Int = Std.int(samplesPerRow);

		var gotIndex:Int = 0;

		var lmin:Float = 0;
		var lmax:Float = 0;

		var rmin:Float = 0;
		var rmax:Float = 0;

		var rows:Float = 0;

		var simpleSample:Bool = true;//samples > 17200;
		var v1:Bool = false;

		if (array == null) array = [[[0], [0]], [[0], [0]]];

		while (index < (bytes.length - 1)) {
			if (index >= 0) {
				var byte:Int = bytes.getUInt16(index * channels * 2);

				if (byte > 65535 / 2) byte -= 65535;

				var sample:Float = (byte / 65535);

				if (sample > 0) {
					if (sample > lmax) lmax = sample;
				} else if (sample < 0) {
					if (sample < lmin) lmin = sample;
				}

				if (channels >= 2) {
					byte = bytes.getUInt16((index * channels * 2) + 2);

					if (byte > 65535 / 2) byte -= 65535;

					sample = (byte / 65535);

					if (sample > 0) {
						if (sample > rmax) rmax = sample;
					} else if (sample < 0) {
						if (sample < rmin) rmin = sample;
					}
				}
			}

			v1 = samplesPerRowI > 0 ? (index % samplesPerRowI == 0) : false;
			while (simpleSample ? v1 : rows >= samplesPerRow) {
				v1 = false;
				rows -= samplesPerRow;

				gotIndex++;

				var lRMin:Float = Math.abs(lmin) * multiply;
				var lRMax:Float = lmax * multiply;

				var rRMin:Float = Math.abs(rmin) * multiply;
				var rRMax:Float = rmax * multiply;

				if (gotIndex > array[0][0].length) array[0][0].push(lRMin);
					else array[0][0][gotIndex - 1] = array[0][0][gotIndex - 1] + lRMin;

				if (gotIndex > array[0][1].length) array[0][1].push(lRMax);
					else array[0][1][gotIndex - 1] = array[0][1][gotIndex - 1] + lRMax;

				if (channels >= 2) {
					if (gotIndex > array[1][0].length) array[1][0].push(rRMin);
						else array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + rRMin;

					if (gotIndex > array[1][1].length) array[1][1].push(rRMax);
						else array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + rRMax;
				}
				else {
					if (gotIndex > array[1][0].length) array[1][0].push(lRMin);
						else array[1][0][gotIndex - 1] = array[1][0][gotIndex - 1] + lRMin;

					if (gotIndex > array[1][1].length) array[1][1].push(lRMax);
						else array[1][1][gotIndex - 1] = array[1][1][gotIndex - 1] + lRMax;
				}

				lmin = 0;
				lmax = 0;

				rmin = 0;
				rmax = 0;
			}

			index++;
			rows++;
			if(gotIndex > steps) break;
		}

		return array;
		#else
		return [[[0], [0]], [[0], [0]]];
		#end
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps(add:Float = 0):Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime + add) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSec = 0;
		}

		if(vocals != null) {
			vocals.pause();
			vocals.time = FlxG.sound.music.time;
		}
		updateCurStep();

		updateGrid();
		updateSectionUI();
		updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSec = sec;
			if (updateMusic)
			{
				FlxG.sound.music.pause();

				FlxG.sound.music.time = sectionStartTime();
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
				updateCurStep();
			}

			var blah1:Float = getSectionBeats();
			var blah2:Float = getSectionBeats(curSec + 1);
			if(sectionStartTime(1) > FlxG.sound.music.length) blah2 = 0;
	
			if(blah1 != lastSecBeats || blah2 != lastSecBeatsNext)
			{
				reloadGridLayer();
			}
			else
			{
				updateGrid();
			}
			updateSectionUI();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		updateWaveform();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSec];

		stepperBeats.value = getSectionBeats();
		check_mustHitSection.checked = sec.mustHitSection;
		check_gfSection.checked = sec.gfSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		var healthIconP1:String = loadHealthIconFromCharacter(_song.player1);
		var healthIconP2:String = loadHealthIconFromCharacter(_song.player2);
		var healthIconP3:String = loadHealthIconFromCharacter(_song.gfVersion);
		if (healthIconP3 == null) {
			healthIconP3 = 'gf';//backup icon
		}
		if (_song.notes[curSec].gfSection) {
			if (_song.notes[curSec].mustHitSection) {
				leftIcon.changeIcon(healthIconP3);
				rightIcon.changeIcon(healthIconP2);
				gfIcon.changeIcon(healthIconP1);
			} else {
				leftIcon.changeIcon(healthIconP3);
				rightIcon.changeIcon(healthIconP1);
				gfIcon.changeIcon(healthIconP2);
			}
		} else {
			if (_song.notes[curSec].mustHitSection)
			{
				leftIcon.changeIcon(healthIconP1);
				rightIcon.changeIcon(healthIconP2);
				gfIcon.changeIcon(healthIconP3);
			}
			else
			{
				leftIcon.changeIcon(healthIconP2);
				rightIcon.changeIcon(healthIconP1);
				gfIcon.changeIcon(healthIconP3);
			}
		}
	}

	function loadHealthIconFromCharacter(char:String) {
		var characterPath:String = 'characters/' + char + '.json';
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path)) {
			path = Paths.externalPreloadPath(characterPath);
		}

		if (!FileSystem.exists(path))
		#else
		var path:String = Paths.getPreloadPath(characterPath);
		if (!OpenFlAssets.exists(path))
		#end
		{
			path = Paths.externalPreloadPath('characters/' + Character.DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
		}

		#if MODS_ALLOWED
		var rawJson = File.getContent(path);
		#else
		var rawJson = OpenFlAssets.getText(path);
		#end

		var json:Character.CharacterFile = cast Json.parse(rawJson);
		return json.healthicon;
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null) {
			if(curSelectedNote[2] != null) {
				stepperSusLength.value = curSelectedNote[2];
				if(curSelectedNote[3] != null) {
					currentType = noteTypeMap.get(curSelectedNote[3]);
					if(currentType <= 0) {
						noteTypeDropDown.selectedLabel = '';
					} else {
						noteTypeDropDown.selectedLabel = currentType + '. ' + curSelectedNote[3];
					}
				}
			} else {
				eventDropDown.selectedLabel = curSelectedNote[1][curEventSelected][0];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if(selected > 0 && selected < eventStuff.length) {
					descText.text = eventStuff[selected][1];
				}
				value1InputText.text = curSelectedNote[1][curEventSelected][1];
				value2InputText.text = curSelectedNote[1][curEventSelected][2];
			}
			strumTimeInputText.text = '' + curSelectedNote[0];
		}
	}

	function updateGrid():Void
	{
		while (prevRenderedNotes.length > 0) {
			var member = prevRenderedNotes.members[0];
			if (member != null) {
				prevRenderedNotes.remove(member, true);
				member.destroy();
			}
		}
		while (prevRenderedSustains.length > 0) {
			var member = prevRenderedSustains.members[0];
			if (member != null) {
				prevRenderedSustains.remove(member, true);
				member.destroy();
			}
		}
		while (curRenderedNotes.length > 0) {
			var member = curRenderedNotes.members[0];
			if (member != null) {
				curRenderedNotes.remove(member, true);
				member.destroy();
			}
		}
		while (curRenderedSustains.length > 0) {
			var member = curRenderedSustains.members[0];
			if (member != null) {
				curRenderedSustains.remove(member, true);
				member.destroy();
			}
		}
		while (curRenderedNoteType.length > 0) {
			var member = curRenderedNoteType.members[0];
			if (member != null) {
				curRenderedNoteType.remove(member, true);
				member.destroy();
			}
		}
		while (nextRenderedNotes.length > 0) {
			var member = nextRenderedNotes.members[0];
			if (member != null) {
				nextRenderedNotes.remove(member, true);
				member.destroy();
			}
		}
		while (nextRenderedSustains.length > 0) {
			var member = nextRenderedSustains.members[0];
			if (member != null) {
				nextRenderedSustains.remove(member, true);
				member.destroy();
			}
		}

		if (_song.notes[curSec].changeBPM && _song.notes[curSec].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSec].bpm);
			//trace('BPM of this section:');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSec)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		// prev SECTION
		if (curSec > 0) {
			var beats:Float = getSectionBeats(-1);
			for (i in _song.notes[curSec-1].sectionNotes)
			{
				var note:Note = setupNoteData(i, false, true);
				prevRenderedNotes.add(note);
				if (note.sustainLength > 0)
				{
					var susLength:Float = note.sustainLength;
					susLength = susLength / Conductor.stepCrochet;
					var floorSus:Int = Math.floor(susLength);
					var susNoteType:Note;
					if (floorSus > 0) {
						for (i in 0...floorSus+1) {
							prevRenderedSustains.add(setupSustainNote((note.strumTime + (Conductor.stepCrochet * i))+Conductor.stepCrochet, i, note, floorSus));
						}
					}
				}
			}
		}
		for (i in _song.notes[curSec].sectionNotes)
		{
			var note:Note = setupNoteData(i, false);
			curRenderedNotes.add(note);
			if (note.sustainLength > 0)
			{
				var susLength:Float = note.sustainLength;
				susLength = susLength / Conductor.stepCrochet;
				var floorSus:Int = Math.floor(susLength);
				var susNoteType:Note;
				if (floorSus > 0) {
					for (i in 0...floorSus+1) {
						curRenderedSustains.add(setupSustainNote((note.strumTime + (Conductor.stepCrochet * i))+Conductor.stepCrochet, i, note, floorSus));
					}
				}
			}

			if(i[3] != null && note.noteType != null && note.noteType.length > 0) {
				var typeInt:Null<Int> = noteTypeMap.get(i[3]);
				var theType:String = '' + typeInt;
				if(typeInt == null) theType = '?';

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 100, theType, 24);
				daText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				daText.xAdd = -32;
				daText.yAdd = 6;
				daText.borderSize = 1;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
			}
		}

		// CURRENT EVENTS
		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);
		for (i in _song.events)
		{
			if(endThing > i[0] && i[0] >= startThing)
			{
				var note:Note = setupNoteData(i, false);
				curRenderedNotes.add(note);

				var text:String = 'Event: ' + note.eventName + ' (' + Math.floor(note.strumTime) + ' ms)' + '\nValue 1: ' + note.eventVal1 + '\nValue 2: ' + note.eventVal2;
				if(note.eventLength > 1) text = note.eventLength + ' Events:\n' + note.eventName;

				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, text, 12);
				daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE_FAST, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;
				if(note.eventLength > 1) daText.yAdd += 8;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
				//trace('test: ' + i[0], 'startThing: ' + startThing, 'endThing: ' + endThing);
			}
		}

		// NEXT SECTION
		var beats:Float = getSectionBeats(1);
		if(curSec < _song.notes.length-1) {
			for (i in _song.notes[curSec+1].sectionNotes)
			{
				var note:Note = setupNoteData(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
				if (note.sustainLength > 0)
				{
					var susLength:Float = note.sustainLength;
					susLength = susLength / Conductor.stepCrochet;
					var floorSus:Int = Math.floor(susLength);
					var susNoteType:Note;
					if (floorSus > 0) {
						for (i in 0...floorSus+1) {
							nextRenderedSustains.add(setupSustainNote((note.strumTime + (Conductor.stepCrochet * i))+Conductor.stepCrochet, i, note, floorSus));
						}
					}
				}
			}
		}

		// NEXT EVENTS
		var startThing:Float = sectionStartTime(1);
		var endThing:Float = sectionStartTime(2);
		for (i in _song.events)
		{
			if(endThing > i[0] && i[0] >= startThing)
			{
				var note:Note = setupNoteData(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
			}
		}
	}

	function setupNoteData(i:Array<Dynamic>, isNextSection:Bool, isPrevSection:Bool = false, isGfSec:Bool = false):Note
	{
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus:Dynamic = i[2];

		var gfType = (i[3] != null && (i[3].indexOf('-gf') != -1) ? true : (_song.notes[curSec+(isNextSection ? 1 : isPrevSection ? -1 : 0)].gfSection ? (daNoteInfo > -1 && daNoteInfo < 4) : (daNoteInfo > 7 && daNoteInfo < 12)));
		var playerType = ((i[3] != null && i[3] == 'GF Sing Force Opponent') || (i[3] != null && i[3].indexOf('-opponent') != -1) ? false : ((i[3] != null && i[3].indexOf('-player') != -1) ? true : _song.notes[curSec+(isNextSection ? 1 : isPrevSection ? -1 : 0)].mustHitSection ? ((daNoteInfo >-1 && daNoteInfo <4) || (daNoteInfo > 7 && daNoteInfo < 12)) : ((daNoteInfo >3 && daNoteInfo <8))));

		var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, null, true, playerType, gfType);
		if(daSus != null) { //Common note
			note.sustainLength = daSus;
			note.noteType = i[3];
		} else { //Event note
			note.loadGraphic(Paths.image('eventArrow'));
			note.eventName = getEventName(i[1]);
			note.eventLength = i[1].length;
			if(i[1].length < 2)
			{
				note.eventVal1 = i[1][0][1];
				note.eventVal2 = i[1][0][2];
			}
			note.noteData = -1;
			daNoteInfo = -1;
		}
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = (Math.floor(daNoteInfo * GRID_SIZE) + GRID_SIZE);
		//freaking confused to do
		if (isPrevSection) {
			//so many logic bruhh
			if (_song.notes[curSec-1].mustHitSection != _song.notes[curSec].mustHitSection) {
				if (_song.notes[curSec-1].gfSection == _song.notes[curSec].gfSection) {
					if (_song.notes[curSec].gfSection) {
						if (daNoteInfo >3 && daNoteInfo < 8) {
							note.x += GRID_SIZE * 4;
						} else if (daNoteInfo >7 && daNoteInfo < 12) {
							note.x -= GRID_SIZE * 4;
						}
					} else {
						if (daNoteInfo >3 && daNoteInfo < 8) {
							note.x -= GRID_SIZE * 4;
						} else if (daNoteInfo >-1 && daNoteInfo < 4) {
							note.x += GRID_SIZE * 4;
						}
					}
				} else {
					if (_song.notes[curSec].gfSection) {
						if (daNoteInfo >-1 && daNoteInfo < 8) {
							note.x += GRID_SIZE*4;
						} else {
							note.x -= GRID_SIZE*8;
						}
					} else {
						if (daNoteInfo >3 && daNoteInfo < 12) {
							note.x -= GRID_SIZE*4;
						} else {
							note.x += GRID_SIZE*8;
						}
					}
				}
			} else {
				if (_song.notes[curSec-1].gfSection != _song.notes[curSec].gfSection) {
					if (daNoteInfo >-1 && daNoteInfo < 4) {
						note.x += GRID_SIZE * 8;
					} else if (daNoteInfo > 7 && daNoteInfo < 12) {
						note.x -= GRID_SIZE * 8;
					}
				}
			}
		}
		if (isNextSection) {
			//so many logic bruhh
			if (_song.notes[curSec+1].mustHitSection != _song.notes[curSec].mustHitSection) {
				if (_song.notes[curSec+1].gfSection == _song.notes[curSec].gfSection) {
					if (_song.notes[curSec].gfSection) {
						if (daNoteInfo >3 && daNoteInfo < 8) {
							note.x += GRID_SIZE * 4;
						} else if (daNoteInfo >7 && daNoteInfo < 12) {
							note.x -= GRID_SIZE * 4;
						}
					} else {
						if (daNoteInfo >3 && daNoteInfo < 8) {
							note.x -= GRID_SIZE * 4;
						} else if (daNoteInfo >-1 && daNoteInfo < 4) {
							note.x += GRID_SIZE * 4;
						}
					}
				} else {
					if (_song.notes[curSec].gfSection) {
						if (daNoteInfo >-1 && daNoteInfo < 8) {
							note.x += GRID_SIZE*4;
						} else {
							note.x -= GRID_SIZE*8;
						}
					} else {
						if (daNoteInfo >3 && daNoteInfo < 12) {
							note.x -= GRID_SIZE*4;
						} else {
							note.x += GRID_SIZE*8;
						}
					}
				}
			} else {
				if (_song.notes[curSec+1].gfSection != _song.notes[curSec].gfSection) {
					if (daNoteInfo >-1 && daNoteInfo < 4) {
						note.x += GRID_SIZE * 8;
					} else if (daNoteInfo > 7 && daNoteInfo < 12) {
						note.x -= GRID_SIZE * 8;
					}
				}
			}
		}

		var beats:Float = getSectionBeats(isNextSection ? 1 : isPrevSection ? -1 : 0);
		note.y = getYfromStrumNotes(daStrumTime - sectionStartTime(), beats);
		//if(isNextSection) note.y += gridBG.height;
		//if(note.y < -150) note.y = -150;
		return note;
	}

	function getEventName(names:Array<Dynamic>):String
	{
		var retStr:String = '';
		var addedOne:Bool = false;
		for (i in 0...names.length)
		{
			if(addedOne) retStr += ', ';
			retStr += names[i][0];
			addedOne = true;
		}
		return retStr;
	}

	function setupSusNote(note:Note, beats:Float):Note {
		//now this is useless
		
		return note;
	}

	function setupSustainNote(strumTime:Float, susNote, note:Note, tail:Int):Note {
		var susNoteType:Note = new Note(strumTime, note.noteData, null, true, true, note.mustPress, note.gfNote, note.noteType, susNote == tail);
		susNoteType.x = note.x+((GRID_SIZE-(GRID_SIZE*0.25))/2);
		susNoteType.y = note.y + (susNote*(GRID_SIZE*zoomList[curZoom]));
		susNoteType.setGraphicSize(Std.int(GRID_SIZE*0.25), Std.int(GRID_SIZE*zoomList[curZoom]));
		susNoteType.updateHitbox();
		return susNoteType;
	}

	private function addSection(sectionBeats:Float = 4):Void
	{
		var sec:SwagSection = {
			sectionBeats: sectionBeats,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			gfSection: false,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var actualNoteData:Int = Math.floor(note.x/GRID_SIZE)-1;
		var noteDataToCheck:Int = actualNoteData;

		if(noteDataToCheck > -1)
		{
			for (i in _song.notes[curSec].sectionNotes)
			{
				if (i != curSelectedNote && i.length > 2 && i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					curSelectedNote = i;
					break;
				}
			}
		}
		else
		{
			for (i in _song.events)
			{
				if(i != curSelectedNote && i[0] == note.strumTime)
				{
					curSelectedNote = i;
					curEventSelected = Std.int(curSelectedNote[1].length) - 1;
					break;
				}
			}
		}
		changeEventSelected();

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var actualNoteData:Int = (Math.floor(note.x/GRID_SIZE))-1;
		var noteDataToCheck:Int = actualNoteData;
		trace(noteDataToCheck);

		if(note.noteData > -1) //Normal Notes
		{
			for (i in _song.notes[curSec].sectionNotes)
			{
				if (i[0] == note.strumTime && i[1] == noteDataToCheck)
				{
					if(i == curSelectedNote) curSelectedNote = null;
					//FlxG.log.add('FOUND EVIL NOTE');
					_song.notes[curSec].sectionNotes.remove(i);
					break;
				}
			}
		}
		else //Events
		{
			for (i in _song.events)
			{
				if(i[0] == note.strumTime)
				{
					if(i == curSelectedNote)
					{
						curSelectedNote = null;
						changeEventSelected();
					}
					//FlxG.log.add('FOUND EVIL EVENT');
					_song.events.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	public function doANoteThing(cs, d, style){
		var delnote = false;
		if(strumLineNotes.members[d].overlaps(curRenderedNotes))
		{
			curRenderedNotes.forEachAlive(function(note:Note)
			{
				if (note.overlapsPoint(new FlxPoint(strumLineNotes.members[d].x + 1,strumLine.y+1)) && note.noteData == d%4)
				{
						//trace('tryin to delete note...');
						if(!delnote) deleteNote(note);
						delnote = true;
				}
			});
		}

		if (!delnote){
			addNote(cs, d, style, FlxG.mouse.x);
		}
	}
	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(strum:Null<Float> = null, data:Null<Int> = null, type:Null<Int> = null, pos:Float = 0):Void
	{
		//curUndoIndex++;
		//var newsong = _song.notes;
		//	undos.push(newsong);
		var noteStrum = getStrumTime(dummyArrow.y * (getSectionBeats() / 4), false) + sectionStartTime();
		var noteData = Math.floor(((pos) - GRID_SIZE) / GRID_SIZE);
		trace(noteData);
		var noteSus = 0;
		var daAlt = false;
		var daType = currentType;

		if (strum != null) noteStrum = strum;
		if (data != null) noteData = data;
		if (type != null) daType = type;

		if(noteData > -1)
		{
			_song.notes[curSec].sectionNotes.push([noteStrum, noteData, noteSus, noteTypeIntMap.get(daType)]);
			curSelectedNote = _song.notes[curSec].sectionNotes[_song.notes[curSec].sectionNotes.length - 1];
		}
		else
		{
			var event = eventStuff[Std.parseInt(eventDropDown.selectedId)][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			_song.events.push([noteStrum, [[event, text1, text2]]]);
			curSelectedNote = _song.events[_song.events.length - 1];
			curEventSelected = 0;
		}
		changeEventSelected();

		if (((FlxG.keys.pressed.CONTROL #if mobile || ctrlButton.pressed #end) && !(FlxG.keys.pressed.ALT #if mobile || altButton.pressed #end)) && noteData > -1)//prevent both place when hold alt
		{
			_song.notes[curSec].sectionNotes.push([noteStrum, (noteData + 4) % 12, noteSus, noteTypeIntMap.get(daType)]);
		}

		//trace(noteData + ', ' + noteStrum + ', ' + curSec);
		strumTimeInputText.text = '' + curSelectedNote[0];

		updateGrid();
		updateNoteUI();
	}

	// will figure this out l8r
	function redo()
	{
		//_song = redos[curRedoIndex];
	}

	function undo()
	{
		//redos.push(_song);
		undos.pop();
		//_song.notes = undos[undos.length - 1];
		///trace(_song.notes);
		//updateGrid();
	}

	function getStrumTime(yPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if(!doZoomCalc) leZoom = 1;
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height * leZoom, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if(!doZoomCalc) leZoom = 1;
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height * leZoom);
	}
	
	function getYfromStrumNotes(strumTime:Float, beats:Float):Float
	{
		var value:Float = strumTime / (beats * 4 * Conductor.stepCrochet);
		return GRID_SIZE * beats * 4 * zoomList[curZoom] * value + gridBG.y;
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		//shitty null fix, i fucking hate it when this happens
		//make it look sexier if possible
		if (CoolUtil.difficulties[PlayState.storyDifficulty] != CoolUtil.defaultDifficulty) {
			if(CoolUtil.difficulties[PlayState.storyDifficulty] == null){
				var songData = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
				if (songData != null) {
					PlayState.SONG = songData;
				}
			}else{
				var songData = Song.loadFromJson(song.toLowerCase() + "-" + CoolUtil.difficulties[PlayState.storyDifficulty], song.toLowerCase());
				if (songData != null) {
					PlayState.SONG = songData;
				}
			}
		}else{
		var songData = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		if (songData != null) {
			PlayState.SONG = songData;
		}
		}
		MusicBeatState.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function clearEvents() {
		_song.events = [];
		updateGrid();
	}

	private function saveLevel()
	{
		if(_song.events != null && _song.events.length > 1) _song.events.sort(sortByTime);
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, (ClientPrefs.minEditorJson ? null : "\t"));

		if ((data != null) && (data.length > 0))
		{
			#if !android
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), Paths.formatToSongPath(_song.song) + ".json");
			#else
			if (!FileSystem.exists(Paths.externalFilesPath('saves/chart/' + _song.song + '/'))) {
				FileSystem.createDirectory(Paths.externalFilesPath('saves/chart/' + _song.song + '/'));
			}
			File.saveContent(Paths.externalFilesPath('saves/chart/' + _song.song + '/' + Paths.formatToSongPath(_song.song) + ".json"), data.trim());
			lime.app.Application.current.window.alert('Chart has been save in ' + Paths.externalFilesPath('saves/chart/' + _song.song + '/' + Paths.formatToSongPath(_song.song) + ".json"), 'Chart Editor');
			#end
		}
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0], Obj2[0]);
	}

	private function saveEvents()
	{
		if(_song.events != null && _song.events.length > 1) _song.events.sort(sortByTime);
		var eventsSong:Dynamic = {
			events: _song.events
		};
		var json = {
			"song": eventsSong
		}

		var data:String = Json.stringify(json, (ClientPrefs.minEditorJson ? null : "\t"));

		if ((data != null) && (data.length > 0))
		{
			#if !android
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
			#else
			if (!FileSystem.exists(Paths.externalFilesPath('saves/chart/' + _song.song + '/'))) {
				FileSystem.createDirectory(Paths.externalFilesPath('saves/chart/' + _song.song + '/'));
			}
			File.saveContent(Paths.externalFilesPath('saves/chart/' + _song.song + "/events.json"), data.trim());
			lime.app.Application.current.window.alert('Event has been save in ' + Paths.externalFilesPath('saves/chart/' + _song.song + "/events.json"), 'Chart Editor');
			#end
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}

	function getSectionBeats(?section:Null<Int> = null)
	{
		if (section == null) section = curSec;
		var val:Null<Float> = null;
		
		if(_song.notes[section] != null) val = _song.notes[section].sectionBeats;
		return val != null ? val : 4;
	}
	private function copySection() {
		notesCopied = [];
		sectionToCopy = curSec;
		for (i in 0..._song.notes[curSec].sectionNotes.length)
		{
			var note:Array<Dynamic> = _song.notes[curSec].sectionNotes[i];
			notesCopied.push(note);
		}

		var startThing:Float = sectionStartTime();
		var endThing:Float = sectionStartTime(1);
		for (event in _song.events)
		{
			var strumTime:Float = event[0];
			if (endThing > event[0] && event[0] >= startThing)
			{
				var copiedEventArray:Array<Dynamic> = [];
				for (i in 0...event[1].length)
				{
					var eventToPush:Array<Dynamic> = event[1][i];
					copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
				}
				notesCopied.push([strumTime, -1, copiedEventArray]);
			}
		}
	}
	private function pasteSection(notesT:Bool = false, eventsT:Bool = false) {
		if(notesCopied == null || notesCopied.length < 1)
		{
			return;
		}

		var addToTime:Float = Conductor.stepCrochet * (getSectionBeats() * 4 * (curSec - sectionToCopy));
		// trace('Time to add: ' + addToTime);

		for (note in notesCopied)
		{
			var copiedNote:Array<Dynamic> = [];
			var newStrumTime:Float = note[0] + addToTime;
			if (note[1] < 0)
			{
				if (eventsT)
				{
					var copiedEventArray:Array<Dynamic> = [];
					for (i in 0...note[2].length)
					{
						var eventToPush:Array<Dynamic> = note[2][i];
						copiedEventArray.push([eventToPush[0], eventToPush[1], eventToPush[2]]);
					}
					_song.events.push([newStrumTime, copiedEventArray]);
				}
			}
			else
			{
				if (notesT)
				{
					if (note[4] != null)
					{
						copiedNote = [newStrumTime, note[1], note[2], note[3], note[4]];
					}
					else
					{
						copiedNote = [newStrumTime, note[1], note[2], note[3]];
					}
					_song.notes[curSec].sectionNotes.push(copiedNote);
				}
			}
		}
		updateGrid();
	}
	private function clearSec(notesT:Bool = false, eventsT:Bool = false) {
		if(notesT)
		{
			_song.notes[curSec].sectionNotes = [];
		}

		if (eventsT)
		{
			var i:Int = _song.events.length - 1;
			var startThing:Float = sectionStartTime();
			var endThing:Float = sectionStartTime(1);
			while (i > -1)
			{
				var event:Array<Dynamic> = _song.events[i];
				if (event != null && endThing > event[0] && event[0] >= startThing)
				{
					_song.events.remove(event);
				}
				--i;
			}
		}
		updateGrid();
	}
	private function clearNotes() {
		openSubState(new Prompt('This action will clear current progress.\n\nProceed?', 0, function(){
			for (sec in 0..._song.notes.length) {
				_song.notes[sec].sectionNotes = [];
			}
			updateGrid();
	}, null,ignoreWarnings));
	}
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
	override public function destroy() {
		CacheTools.clearCache();
		super.destroy();
	}
}
