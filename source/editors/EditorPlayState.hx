package editors;
import dge.obj.mobile.Hitbox;
import dge.backend.CacheTools;

import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import Section.SwagSection;
import Song.SwagSong;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import FunkinLua;

using StringTools;

class EditorPlayState extends MusicBeatState
{
	// Yes, this is mostly a copy of PlayState, it's kinda dumb to make a direct copy of it but... ehhh
	private var strumLine:FlxSprite;
	private var comboGroup:FlxTypedGroup<FlxSprite>;
	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var gfStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	//gameplay changer shit
	public var gamemode:String = "none";
	public var colorOrder:Array<Int> = [ FlxColor.MAGENTA, FlxColor.CYAN, FlxColor.LIME, FlxColor.RED ];

	var generatedMusic:Bool = false;
	var vocals:FlxSound;

	var startOffset:Float = 0;
	var startPos:Float = 0;
	private var hitbox:FlxTypedGroup<Hitbox>;
	private var hitboxCam:FlxCamera;
	private var cacheRating:Map<String, FlxGraphic> = new Map();//cache rating(slighty better performance)

	public function new(startPos:Float) {
		this.startPos = startPos;
		Conductor.songPosition = startPos - startOffset;

		startOffset = Conductor.crochet;
		timerToStart = startOffset;
		super();
	}

	var scoreTxt:FlxText;
	var stepTxt:FlxText;
	var beatTxt:FlxText;
	var sectionTxt:FlxText;
	
	var timerToStart:Float = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	
	// Less laggy controls
	private var keysArray:Array<Dynamic>;

	public static var instance:EditorPlayState;

	override function create()
	{
		CacheTools.clearCache();
		Paths.clearStoredMemory();
		instance = this;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image((ClientPrefs.darkmode ? 'menuDesatDark' : 'menuDesat')));
		bg.scrollFactor.set();
		bg.color = FlxColor.fromHSB(FlxG.random.int(0, 359), FlxG.random.float(0, 0.8), FlxG.random.float(0.3, 1));
		CoolUtil.fitBackground(bg);
		add(bg);

		gamemode = ClientPrefs.getGameplaySetting('gamemode', "none");
		keysArray = [
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_left')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_down')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_up')),
			ClientPrefs.copyKey(ClientPrefs.keyBinds.get('note_right'))
		];
		
		strumLine = new FlxSprite(ClientPrefs.middleScroll ? PlayState.STRUM_X_MIDDLESCROLL : PlayState.STRUM_X, 50).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();
		
		comboGroup = new FlxTypedGroup<FlxSprite>();
		add(comboGroup);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		opponentStrums = new FlxTypedGroup<StrumNote>();
		gfStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		generateStaticArrows(0);
		generateStaticArrows(1);
		/*if(ClientPrefs.middleScroll) {
			opponentStrums.forEachAlive(function (note:StrumNote) {
				note.visible = false;
			});
		}*/
		
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.0;
		
		if (PlayState.SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		generateSong(PlayState.SONG.song);
		#if (LUA_ALLOWED && MODS_ALLOWED)
		for (notetype in noteTypeMap.keys()) {
			var luaToLoad:String = Paths.modFolders('custom_notetypes/' + notetype + '.lua');
			if(sys.FileSystem.exists(luaToLoad)) {
				var lua:editors.EditorLua = new editors.EditorLua(luaToLoad);
				new FlxTimer().start(0.1, function (tmr:FlxTimer) {
					lua.stop();
					lua = null;
				});
			}
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;

		scoreTxt = new FlxText(10, FlxG.height - 50, FlxG.width - 20, "Hits: 0 | Misses: 0", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		add(scoreTxt);
		
		sectionTxt = new FlxText(10, 580, FlxG.width - 20, "Section: 0", 20);
		sectionTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		sectionTxt.scrollFactor.set();
		sectionTxt.borderSize = 1.25;
		add(sectionTxt);
		
		beatTxt = new FlxText(10, sectionTxt.y + 30, FlxG.width - 20, "Beat: 0", 20);
		beatTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		beatTxt.scrollFactor.set();
		beatTxt.borderSize = 1.25;
		add(beatTxt);

		stepTxt = new FlxText(10, beatTxt.y + 30, FlxG.width - 20, "Step: 0", 20);
		stepTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		stepTxt.scrollFactor.set();
		stepTxt.borderSize = 1.25;
		add(stepTxt);

		var tipText:FlxText = new FlxText(10, FlxG.height - 24, 0, 'Press ESC to Go Back to Chart Editor', 16);
		tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		tipText.borderSize = 2;
		tipText.scrollFactor.set();
		add(tipText);
		FlxG.mouse.visible = false;

		//sayGo();
		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		hitbox = new FlxTypedGroup<Hitbox>();
		add(hitbox);
		hitboxCam = new FlxCamera();
		hitboxCam.bgColor.alpha = 0;
		FlxG.cameras.add(hitboxCam, false);
		#if mobile
		//hitbox.cameras = [hitboxCam];
		for (i in 0...keysArray.length) {
			var bruh = new Hitbox(i*Std.int(FlxG.width/keysArray.length), 0);
			bruh.color = colorOrder[i%colorOrder.length];
			bruh.cameras = [hitboxCam];
			bruh.sizeWidth = Std.int(FlxG.width/keysArray.length);
			bruh.sizeHeight = FlxG.height;
			bruh.updateHitbox();
			hitbox.add(bruh);
		}
		#end
		super.create();
		cachePopUpScore();
		Paths.clearUnusedMemory();
	}

	function sayGo() {
		var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('go'));
		go.scrollFactor.set();

		go.updateHitbox();

		go.screenCenter();
		go.antialiasing = ClientPrefs.globalAntialiasing;
		add(go);
		FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				go.destroy();
			}
		});
		FlxG.sound.play(Paths.sound('introGo'), 0.6);
	}

	//var songScore:Int = 0;
	var songHits:Int = 0;
	var songMisses:Int = 0;
	var startingSong:Bool = true;
	private function generateSong(dataPath:String):Void
	{
		FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0, false);
		FlxG.sound.music.pause();
		FlxG.sound.music.onComplete = endSong;
		vocals.pause();
		vocals.volume = 0;

		var songData = PlayState.SONG;
		Conductor.changeBPM(songData.bpm);
		
		notes = new FlxTypedGroup<Note>();
		add(notes);
		
		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) { //Real notes
					var daStrumTime:Float = songNotes[0];
					if(daStrumTime >= startPos) {
						var daNoteData:Int = Std.int(songNotes[1] % 4);

						var gottaHitNote:Bool = section.mustHitSection;

						if (songNotes[1] > 3 && songNotes[1] < 8)
						{
							gottaHitNote = !section.mustHitSection;
						}

						var oldNote:Note;
						if (unspawnNotes.length > 0)
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						else
							oldNote = null;

						var noteType = songNotes[3];
						if(!Std.isOfType(songNotes[3], String)) noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
						var check_opt = noteType;
						var should_opt:Int = -1;
						var check_ply = noteType;
						var should_ply:Int = -1;
						var check_gf = noteType;
						var should_gf:Int = -1;
						if (check_opt != null) {
							should_opt = noteType.indexOf("-opponent");
						}
						if (check_ply != null) {
							should_ply = noteType.indexOf("-player");
						}
						if (check_gf != null) {
							should_gf = noteType.indexOf("-gf");
						}
						var gfSec = (section.gfSection && (songNotes[1]<4) || should_gf != -1 || (!section.gfSection ? songNotes[1]>7 : false));
						var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, null, null, (songNotes[3] == "GF Sing Force Opponent"/**compatibility backward**/ || should_opt != -1 ? false : (should_ply != -1 ? true : gottaHitNote)), gfSec, noteType);
						swagNote.sustainLength = songNotes[2];
						swagNote.camTarget = '';//set to active cam;
						swagNote.noteSplashCam = '';//set to active cam;
						swagNote.scrollFactor.set();

						var susLength:Float = swagNote.sustainLength;

						susLength = susLength / Conductor.stepCrochet;
						unspawnNotes.push(swagNote);

						var floorSus:Int = Math.floor(susLength);
						if(floorSus > 0) {
							for (susNote in 0...floorSus+1)
							{
								oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

								var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal(PlayState.SONG.speed, 2)), daNoteData, oldNote, true, null, (songNotes[3] == "GF Sing Force Opponent"/**compatibility backward**/ || should_opt != -1 ? false : (should_ply != -1 ? true : gottaHitNote)), gfSec, swagNote.noteType, susNote == (floorSus));
								sustainNote.scrollFactor.set();
								sustainNote.camTarget = '';//set to active cam;
								sustainNote.noteSplashCam = '';//set to active cam;
								sustainNote.parent = swagNote;
								unspawnNotes.push(sustainNote);

								if (sustainNote.mustPress)
								{
									sustainNote.x += FlxG.width / 2; // general offset
								}
								else if(ClientPrefs.middleScroll)
								{
									sustainNote.x += 310;
									if(daNoteData > 1)
									{ //Up and Right
										sustainNote.x += FlxG.width / 2 + 25;
									}
								}
							}
						}

						if (swagNote.mustPress)
						{
							swagNote.x += FlxG.width / 2; // general offset
						}
						else if(ClientPrefs.middleScroll)
						{
							swagNote.x += 310;
							if(daNoteData > 1) //Up and Right
							{
								swagNote.x += FlxG.width / 2 + 25;
							}
						}
						
						if(!noteTypeMap.exists(swagNote.noteType)) {
							noteTypeMap.set(swagNote.noteType, true);
						}
					}
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function startSong():Void
	{
		startingSong = false;
		FlxG.sound.music.time = startPos;
		FlxG.sound.music.play();
		FlxG.sound.music.volume = 1;
		vocals.volume = 1;
		vocals.time = startPos;
		vocals.play();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, (Obj1.strumTime + Obj1.offsetStrumTime), (Obj2.strumTime + Obj2.offsetStrumTime));
	}

	private function endSong() {
		LoadingState.loadAndSwitchState(new editors.ChartingState());
	}

	public var noteKillOffset:Float = 350;
	public var spawnTime:Float = 2000;
	override function update(elapsed:Float) {
		if (FlxG.keys.justPressed.ESCAPE #if android || FlxG.android.justPressed.BACK #end)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			LoadingState.loadAndSwitchState(new editors.ChartingState());
		}

		if (startingSong) {
			timerToStart -= elapsed * 1000;
			Conductor.songPosition = startPos - timerToStart;
			if(timerToStart < 0) {
				startSong();
			}
		} else {
			Conductor.songPosition += elapsed * 1000;
		}

		for (i in 0...unspawnNotes.length) {
			if (unspawnNotes[i] != null)
			{
				var time:Float = spawnTime;
				if(PlayState.SONG.speed < 1) time /= PlayState.SONG.speed;
				if(unspawnNotes[i].multSpeed < 1) time /= unspawnNotes[i].multSpeed;
	
				if (unspawnNotes.length > 0 && (unspawnNotes[i].strumTime + unspawnNotes[i].offsetStrumTime) - Conductor.songPosition < time && (ClientPrefs.limitSpawn ? notes.length < ClientPrefs.limitSpawnNotes : true))
				{
					var dunceNote:Note = unspawnNotes[i];
					notes.insert(0, dunceNote);
					dunceNote.spawned=true;
					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
				}
			}
		}

		
		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / PlayState.SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				/*if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}*/

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAlpha:Float = 0;
				var strumGroup;
				if(daNote.mustPress) {
					strumGroup = playerStrums;
				} else {
					if (daNote.gfNote && PlayState.SONG.secOpt) {
						strumGroup = gfStrums;
					} else {
						strumGroup = opponentStrums;
					}
				}
				strumX = strumGroup.members[daNote.noteData].x;
				strumY = strumGroup.members[daNote.noteData].y;
				strumAlpha = strumGroup.members[daNote.noteData].alpha;

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				if (daNote.isSustainNote && daNote.parent != null) {
					switch(daNote.alignSustainNote) {
						case 'left':
							strumX += 0;//left the long notes from parent(0 cuz is already left align by default)
						case 'center':
							strumX += (daNote.parent.width/2)-(daNote.width/2);//center the long notes from parent
						case 'right':
							strumX += (daNote.parent.width)-(daNote.width);//right the long notes from parent
						default:
							strumX += (daNote.parent.width/2)-(daNote.width/2);//center the long notes from parent
					}
				}
				var center:Float = strumY + (strumGroup.members[daNote.noteData].height * strumGroup.members[daNote.noteData].sustainReducePoint);

				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha * daNote.multAlpha;
				}
				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyY) {
					if (ClientPrefs.downScroll) {
						daNote.y = (strumY + 0.45 * (Conductor.songPosition - (daNote.strumTime + daNote.offsetStrumTime)) * PlayState.SONG.speed);
						if (daNote.isSustainNote) {
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * PlayState.SONG.speed + (46 * (PlayState.SONG.speed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * PlayState.SONG.speed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (PlayState.SONG.speed - 1));
							daNote.y += 27.5 * ((PlayState.SONG.bpm / 100) - 1) * (PlayState.SONG.speed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					} else {
						daNote.y = (strumY - 0.45 * (Conductor.songPosition - (daNote.strumTime + daNote.offsetStrumTime)) * PlayState.SONG.speed);

						if(daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (daNote.isSustainNote) {
					daNote.flipY = ClientPrefs.downScroll;
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote)
				{
					if (PlayState.SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}
					if (!ClientPrefs.clsstrum) {
						StrumPlayAnim(true, Std.int(Math.abs(daNote.noteData)), time, daNote);
					}
					daNote.hitByOpponent = true;

					if (!daNote.isSustainNote)
					{
						if (!daNote.noteSplashDisabled && !ClientPrefs.clsstrum) {
							spawnNoteSplashOnNote(daNote, daNote.mustPress);
						}
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if (Conductor.songPosition > (noteKillOffset / Math.max(1.0, PlayState.SONG.speed)) + (daNote.strumTime + daNote.offsetStrumTime))
				{
					if (daNote.mustPress)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							//Dupe note remove
							notes.forEachAlive(function(note:Note) {
								if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs((daNote.strumTime + daNote.offsetStrumTime) - (note.strumTime + note.offsetStrumTime)) < 10) {
									note.kill();
									notes.remove(note, true);
									note.destroy();
								}
							});

							if(!daNote.ignoreNote) {
								songMisses++;
								vocals.volume = 0;
							}
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		keyShit();
		scoreTxt.text = 'Hits: ' + songHits + ' | Misses: ' + songMisses;
		sectionTxt.text = 'Beat: ' + curSection;
		beatTxt.text = 'Beat: ' + curBeat;
		stepTxt.text = 'Step: ' + curStep;
		#if mobile
		for (i in 0...hitbox.length) {
			if (hitbox.members[i].justPressed) {
				customKeyPress(i, true);
			}
			if (hitbox.members[i].justReleased) {
				customKeyRelease(i);
			}
		}
		#end
		super.update(elapsed);
	}
	
	override public function onFocus():Void
	{
		vocals.play();

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		vocals.pause();

		super.onFocusLost();
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
	private function onKeyPress(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		customKeyPress(key, FlxG.keys.checkStatus(eventKey, JUST_PRESSED));
		//trace('Pressed: ' + eventKey);

	}

	private function customKeyPress(key:Int, checkKey:Bool) {
		if (key > -1 && checkKey || ClientPrefs.controllerMode)
		{
			if(generatedMusic)
				{
					var spr:StrumNote = playerStrums.members[key];
				if(spr != null)
				{
					spr.playAnim('pressed');
					spr.resetAnim = 0;
				}
				//more accurate hit time for the ratings?
				var lastTime:Float = Conductor.songPosition;
				Conductor.songPosition = FlxG.sound.music.time;

				var canMiss:Bool = !ClientPrefs.ghostTapping;

				// heavily based on my own code LOL if it aint broke dont fix it
				var pressNotes:Array<Note> = [];
				//var notesDatas:Array<Int> = [];
				var notesStopped:Bool = false;

				//trace('test!');
				var sortedNotesList:Array<Note> = [];
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
					{
						if(daNote.noteData == key)
						{
							sortedNotesList.push(daNote);
							//notesDatas.push(daNote.noteData);
						}
						canMiss = true;
					}
				});
				sortedNotesList.sort(sortHitNotes);

				if (sortedNotesList.length > 0) {
					for (epicNote in sortedNotesList)
					{
						for (doubleNote in pressNotes) {
							if (Math.abs((doubleNote.strumTime + doubleNote.offsetStrumTime) - (epicNote.strumTime + epicNote.offsetStrumTime)) < 1) {
								doubleNote.kill();
								notes.remove(doubleNote, true);
								doubleNote.destroy();
							} else
								notesStopped = true;
						}

						// eee jack detection before was not super good
						if (!notesStopped) {
							goodNoteHit(epicNote);
							pressNotes.push(epicNote);
						}

					}
				}
				else if (canMiss && ClientPrefs.ghostTapping) {
					noteMiss();
				}

				//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
				Conductor.songPosition = lastTime;
			}

			
		}
	}

	function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, (a.strumTime + a.offsetStrumTime), (b.strumTime + b.offsetStrumTime));
	}

	private function onKeyRelease(event:KeyboardEvent):Void
	{
		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(eventKey);
		customKeyRelease(key);
		//trace('released: ' + controlArray);
	}

	private function customKeyRelease(key:Int) {
		if(key > -1)
		{
			var spr:StrumNote = playerStrums.members[key];
			if(spr != null)
			{
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		}
	}

	private function getKeyFromEvent(key:FlxKey):Int
	{
		if(key != NONE)
		{
			for (i in 0...keysArray.length)
			{
				for (j in 0...keysArray[i].length)
				{
					if(key == keysArray[i][j])
					{
						return i;
					}
				}
			}
		}
		return -1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.NOTE_UP;
		var right = controls.NOTE_RIGHT;
		var down = controls.NOTE_DOWN;
		var left = controls.NOTE_LEFT;
		var controlHoldArray:Array<Bool> = [left, down, up, right];
		#if mobile
		for (i in 0...hitbox.length) {
			if (!controlHoldArray[i]) {
				controlHoldArray[i] = hitbox.members[i].pressed;
			}
		}
		#end
		
		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyPress(new KeyboardEvent(KeyboardEvent.KEY_DOWN, true, true, -1, keysArray[i][0]));
				}
			}
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});
		}

		// TO DO: Find a better way to handle controller inputs, this should work for now
		if(ClientPrefs.controllerMode)
		{
			var controlArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];
			if(controlArray.contains(true))
			{
				for (i in 0...controlArray.length)
				{
					if(controlArray[i])
						onKeyRelease(new KeyboardEvent(KeyboardEvent.KEY_UP, true, true, -1, keysArray[i][0]));
				}
			}
		}
	}

	var combo:Int = 0;
	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			switch(note.noteType) {
				case 'Hurt Note': //Hurt note
					noteMiss();
					--songMisses;
					if(!note.isSustainNote) {
						if(!note.noteSplashDisabled && !ClientPrefs.clsstrum) {
							spawnNoteSplashOnNote(note, note.mustPress);
						}
					}

					note.wasGoodHit = true;
					vocals.volume = 0;

					if (!note.isSustainNote)
					{
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
					return;
			}

			if (!note.isSustainNote)
			{
				combo += 1;
				if(combo > 9999) combo = 9999;
				popUpScore(note);
				songHits++;
			}

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.playAnim((note.animConfirm.length < 1 ? spr.animConfirm : note.animConfirm), true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	function noteMiss():Void
	{
		combo = 0;

		//songScore -= 10;
		songMisses++;

		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		vocals.volume = 0;
	}

	var COMBO_X:Float = 400;
	var COMBO_Y:Float = 340;
	private function cachePopUpScore()
		{
			var pixelShitPart1:String = '';
			var pixelShitPart2:String = '';
			if (PlayState.isPixelStage)
			{
				pixelShitPart1 = 'pixelUI/';
				pixelShitPart2 = '-pixel';
			}
	
			var ratingTOCache = ['sick', 'good', 'bad', 'shit', 'combo'];
			for (i in ratingTOCache) {
				cacheRating.set(i, Paths.image(pixelShitPart1 + i + pixelShitPart2));
			}
			
			for (i in 0...10) {
				cacheRating.set(Std.string(i), Paths.image(pixelShitPart1 + 'num' + i + pixelShitPart2));
			}
		}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs((note.strumTime + note.offsetStrumTime) - Conductor.songPosition + ClientPrefs.ratingOffset);

		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.x = COMBO_X;
		coolText.y = COMBO_Y;
		//

		var rating:FlxSprite = new FlxSprite();
		//var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'shit';
			//score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';
			//score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			//score = 200;
		}

		if(daRating == 'sick' && !note.noteSplashDisabled && !ClientPrefs.clsstrum)
		{
			spawnNoteSplashOnNote(note, note.mustPress);
		}
		//songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
			*/


		rating.loadGraphic(cacheRating.get(daRating));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.visible = !ClientPrefs.hideHud;
		rating.x += ClientPrefs.comboOffset[0];
		rating.y -= ClientPrefs.comboOffset[1];

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(cacheRating.get('combo'));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.visible = !ClientPrefs.hideHud;
		comboSpr.x += ClientPrefs.comboOffset[0];
		comboSpr.y -= ClientPrefs.comboOffset[1];

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		comboGroup.add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * PlayState.daPixelZoom * 0.85));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * PlayState.daPixelZoom * 0.85));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(cacheRating.get(Std.string(i)));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.x += ClientPrefs.comboOffset[2];
			numScore.y -= ClientPrefs.comboOffset[3];

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * PlayState.daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			numScore.visible = !ClientPrefs.hideHud;

			insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
			*/

		coolText.text = Std.string(seperatedScore);
		// comboGroup.add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function generateStaticArrows(player:Int, t:Bool = true):Void
		{
			if (!PlayState.SONG.secOpt) {
				for (i in 0...4)
					{
						// FlxG.log.add(i);
			
						var babyArrow:StrumNote = new StrumNote(((ClientPrefs.middleScroll || gamemode == "bothside" ? FlxG.width / 2 : (player == 1 ? FlxG.width*0.75 : FlxG.width*0.25))-(Note.swagWidth*2))+(Note.swagWidth*i), strumLine.y, i, player);
						babyArrow.camTarget = '';
						if (player == 1)
						{
							if (gamemode == "bothside") {
								opponentStrums.add(babyArrow);
								strumLineNotes.add(babyArrow);//ehhh
							}
							playerStrums.add(babyArrow);
							strumLineNotes.add(babyArrow);
						}
						else
						{
							if(ClientPrefs.middleScroll)
							{
								if(i > 1) { //Up and Right
									babyArrow.x += FlxG.width / 4;
								} else {
									babyArrow.x -= FlxG.width / 4;
								}
							}
							opponentStrums.add(babyArrow);
							strumLineNotes.add(babyArrow);
						}
						babyArrow.postAddedToGroup();	
				}	
			} else {
				// Loop for opponentStrums (8 arrows)
				if (player == 0) {
					for (i in 0...8)
					{
						var noteSize = Note.swagWidth*(Math.min(0.75, 0.7*(FlxG.width/1280)));
					var noteSizeSub = Note.swagWidth*(Math.min(0.125, 0.15*(FlxG.width/1280)));
					var number = (-(noteSize*4))+(noteSize*i);
					var babyArrow:StrumNote = new StrumNote((ClientPrefs.middleScroll || gamemode == "bothside" ? FlxG.width / 2 : FlxG.width*0.25)+number-noteSizeSub, strumLine.y, i, player, i>3);
						babyArrow.camTarget ='';
						if (player != 1)
						{
							if(ClientPrefs.middleScroll)
							{
								if(i > 3) { // Adjust positions for the last 4 arrows
									babyArrow.x += FlxG.width / 4;
								} else {
									babyArrow.x -= FlxG.width / 4;
								}
							}
							if (i > 3) {
							gfStrums.add(babyArrow);
							}
							opponentStrums.add(babyArrow);
						}
					
						strumLineNotes.add(babyArrow);
						babyArrow.postAddedToGroup();
						}
					} else {
				// Loop for playerStrums (only 4 arrows)
					for (i in 0...8)
						{
							if (!(PlayState.SONG.secOpt && gamemode == 'bothside') && i>3) {
								continue;//stop only 4 spawn
							}
							var number = (PlayState.SONG.secOpt && gamemode == 'bothside' ? (-Note.swagWidth*4) : (-(Note.swagWidth)*2))+(Note.swagWidth*i);
							var babyArrow:StrumNote = new StrumNote(((ClientPrefs.middleScroll || gamemode == "bothside" ? FlxG.width / 2 : FlxG.width*0.75)+number), strumLine.y, i, player, i>3);
							babyArrow.camTarget ='';
						
							if (player == 1)
							{
								playerStrums.add(babyArrow);
								if (gamemode == 'bothside') {
									opponentStrums.add(babyArrow);
									if (PlayState.SONG.secOpt && i > 3) {
										gfStrums.add(babyArrow);
									}
								} 
							}
						
							strumLineNotes.add(babyArrow);
							babyArrow.postAddedToGroup();
						}
				}				
			}
		}


	// For Opponent's notes glow
	function StrumPlayAnim(isDad:Bool, id:Int, time:Float, ?note:Note) {
		var spr:StrumNote = null;
		if(isDad) {
			spr = (note.gfNote && PlayState.SONG.secOpt ? gfStrums.members[id] : opponentStrums.members[id]);
		} else {
			spr = playerStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim((note.animConfirm.length < 1 ? spr.animConfirm : note.animConfirm), true);
			spr.resetAnim = time;
		}
	}


	// Note splash shit, duh
	function spawnNoteSplashOnNote(note:Note, player:Bool = true) {
		if(ClientPrefs.noteSplashes && note != null && !ClientPrefs.clsstrum) {
			var strum:StrumNote = (player ? playerStrums.members[note.noteData] : (note.gfNote && PlayState.SONG.secOpt ? gfStrums.members[note.noteData] : opponentStrums.members[note.noteData]));
			if(strum != null) {
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt, note.camTarget, note.noteSplashScale, note.noteSplashScrollFactor[0], note.noteSplashScrollFactor[1]);
		grpNoteSplashes.add(splash);
	}
	
	override function destroy() {
		FlxG.sound.music.stop();
		vocals.stop();
		vocals.destroy();

		if(!ClientPrefs.controllerMode)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		}
		CacheTools.clearCache();
		super.destroy();
	}
}