package;

import dge.obj.mobile.VirtualButton;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxStringUtil;
using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String>;
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var bothsideTxt:FlxText;
	var skipTimeText:FlxText;
	var skipTimeTracker:Alphabet;
	var curTime:Float = Math.max(0, Conductor.songPosition);
	var skinPly:String;
	//mobile
	private var leftButton:VirtualButton;
	private var rightButton:VirtualButton;
	private var enterButton:VirtualButton;
	private var pauseOverlay:FlxCamera;
	//var botplayText:FlxText;

	public static var songName:String = '';

	public function new()
	{
		super();
		if (ClientPrefs.dragonW) {
			menuItemsOG = ['Dragonflight', 'Reignite Melody', 'Scale Challenge' #if mobile , 'Chart Editor' #end, 'Return to Lair'];
		} else {
			menuItemsOG = ['Resume', 'Restart Song', 'Change Difficulty'  #if mobile , 'Chart Editor' #end, 'Exit to menu'];
		}
		if(CoolUtil.difficulties.length < 2) menuItemsOG.remove((ClientPrefs.dragonW ? 'Scale Challenge' : 'Change Difficulty')); //No need to change difficulty if there is only one!

		if(PlayState.chartingMode)
		{
			menuItemsOG.insert(2, (ClientPrefs.dragonW ? 'Left Forge' : 'Leave Charting Mode'));
			
			var num:Int = 0;
			if(!PlayState.instance.startingSong)
			{
				num = 1;
				menuItemsOG.insert(3, (ClientPrefs.dragonW ? 'Time Control' : 'Skip Time'));
			}
			menuItemsOG.insert(3 + num, 'End ' + (ClientPrefs.dragonW ? 'Melody' : 'Song'));
			menuItemsOG.insert(4 + num, 'Toggle ' + (ClientPrefs.dragonW ? "Wyrm Training" : "Practice Mode") );
			menuItemsOG.insert(5 + num, 'Toggle ' + (ClientPrefs.dragonW ? "Autoflight" : "Botplay"));
		}
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficulties.length) {
			var diff:String = '' + CoolUtil.difficulties[i];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');


		pauseMusic = new FlxSound();
		if(songName != null && songName.toLowerCase() != 'none') {
			pauseMusic.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
		}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, (PlayState.instance != null ? PlayState.instance.bgPauseColor : FlxColor.BLACK));
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		blueballedTxt.text = (ClientPrefs.dragonW ? "Been Killed: " : "Blueballed: ") + PlayState.deathCounter + (ClientPrefs.dragonW ? " Times" : "");
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 15 + 101, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.instance.practiceMode;
		add(practiceText);

		bothsideTxt = new FlxText(20, 15 + 138, 0, PlayState.instance.gamemode.toUpperCase() + " MODE", 32);//optimized lmao
		bothsideTxt.scrollFactor.set();
		bothsideTxt.setFormat(Paths.font('vcr.ttf'), 32);
		bothsideTxt.x = FlxG.width - (bothsideTxt.width + 20);
		bothsideTxt.updateHitbox();
		bothsideTxt.visible = (PlayState.instance.gamemode != 'none' ? true : false);
		add(bothsideTxt);

		var chartingText:FlxText = new FlxText(20, 15 + 101, 0, "CHARTING MODE", 32);
		chartingText.scrollFactor.set();
		chartingText.setFormat(Paths.font('vcr.ttf'), 32);
		chartingText.x = FlxG.width - (chartingText.width + 20);
		chartingText.y = FlxG.height - (chartingText.height + 20);
		chartingText.updateHitbox();
		chartingText.visible = PlayState.chartingMode;
		add(chartingText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedTxt.x = FlxG.width - (blueballedTxt.width + 20);

		FlxTween.tween(bg, {alpha: (PlayState.instance != null ? PlayState.instance.bgPauseAlpha : ClientPrefs.pauseBGAlpha)}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		regenMenu();
		pauseOverlay = new FlxCamera();
		pauseOverlay.bgColor.alpha = 0;
		FlxG.cameras.add(pauseOverlay, false);
		cameras = [pauseOverlay];
		#if mobile
		leftButton = new VirtualButton(0, FlxG.height-125, 'left');
		add(leftButton);
		rightButton = new VirtualButton(125, FlxG.height-125, 'right');
		add(rightButton);
		enterButton = new VirtualButton(FlxG.width-125, FlxG.height-125, 'enter');
		add(enterButton);
		leftButton.cameras = [pauseOverlay];
		rightButton.cameras = [pauseOverlay];
		enterButton.cameras = [pauseOverlay];
		#end
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);
		updateSkipTextStuff();
		var upP = controls.UI_UP_P #if mobile || dge.backend.TouchUtil.swipeUp() #end;
		var downP = controls.UI_DOWN_P #if mobile || dge.backend.TouchUtil.swipeDown() #end;
		var accepted = controls.ACCEPT #if mobile || enterButton.justPressed #end;
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		var daSelected:String = menuItems[curSelected];
		switch (daSelected)
		{
			case 'Skip Time':
				if (controls.UI_LEFT_P #if mobile || leftButton.justPressed #end)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P #if mobile || rightButton.justPressed #end)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if((controls.UI_LEFT #if mobile || leftButton.pressed #end) || (controls.UI_RIGHT #if mobile || rightButton.pressed #end))
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * ((controls.UI_LEFT #if mobile || leftButton.pressed #end) ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
			case 'Time Control':
				if (controls.UI_LEFT_P #if mobile || leftButton.justPressed #end)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime -= 1000;
					holdTime = 0;
				}
				if (controls.UI_RIGHT_P #if mobile || rightButton.justPressed #end)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					curTime += 1000;
					holdTime = 0;
				}

				if((controls.UI_LEFT #if mobile || leftButton.pressed #end) || (controls.UI_RIGHT #if mobile || rightButton.pressed #end))
				{
					holdTime += elapsed;
					if(holdTime > 0.5)
					{
						curTime += 45000 * elapsed * ((controls.UI_LEFT #if mobile || leftButton.pressed #end) ? -1 : 1);
					}

					if(curTime >= FlxG.sound.music.length) curTime -= FlxG.sound.music.length;
					else if(curTime < 0) curTime += FlxG.sound.music.length;
					updateSkipTimeText();
				}
		}

		if (accepted && (cantUnpause <= 0 || !ClientPrefs.controllerMode))
		{
			if (menuItems == difficultyChoices)
			{
				if(menuItems.length - 1 != curSelected && difficultyChoices.contains(daSelected)) {
					var name:String = PlayState.SONG.song;
					var poop = Highscore.formatSong(name, curSelected);
					var songData = Song.loadFromJson(poop, name);
					if (songData != null) {
						PlayState.SONG = Song.loadFromJson(poop, name);
						PlayState.storyDifficulty = curSelected;
						MusicBeatState.resetState();
						FlxG.sound.music.volume = 0;
						PlayState.changedDifficulty = true;
						PlayState.chartingMode = false;
					} else {
						if (FlxG.random.bool(0.1)) {
							trace('PAUSE MENU REFUSE CHANGE DIFFICULT BECAUSE YOU DIDT GAVE A JSON FILE');//lmao. why so funny
						} else {
							trace('PAUSE MENU HAS BEEN CRASHED BECAUSE OF MISSING SONG DATA');//lmao even paused screen can crashed instead entire app.
						}
						close();
					}
					return;
				}

				menuItems = menuItemsOG;
				regenMenu();
			}

			switch (daSelected)
			{
				case "Resume":
					close();
				case 'Change Difficulty':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case "Dragonflight":
					close();
				case 'Scale Challenge':
					menuItems = difficultyChoices;
					deleteSkipTimeText();
					regenMenu();
				case 'Toggle Practice Mode':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case 'Toggle Wyrm Training':
					PlayState.instance.practiceMode = !PlayState.instance.practiceMode;
					PlayState.changedDifficulty = true;
					practiceText.visible = PlayState.instance.practiceMode;
				case "Restart Song":
					restartSong();
				case "Reignite Melody":
					restartSong();
				case "Leave Charting Mode":
					restartSong();
					PlayState.chartingMode = false;
				case "Left Forge":
					restartSong();
					PlayState.chartingMode = false;
				case 'Skip Time':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Song":
					close();
					PlayState.instance.finishSong(true);
				case 'Time Control':
					if(curTime < Conductor.songPosition)
					{
						PlayState.startOnTime = curTime;
						restartSong(true);
					}
					else
					{
						if (curTime != Conductor.songPosition)
						{
							PlayState.instance.clearNotesBefore(curTime);
							PlayState.instance.setSongTime(curTime);
						}
						close();
					}
				case "End Melody":
					close();
					PlayState.instance.finishSong(true);
				case 'Toggle Botplay':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case 'Toggle Autoflight':
					PlayState.instance.cpuControlled = !PlayState.instance.cpuControlled;
					PlayState.changedDifficulty = true;
					PlayState.instance.botplayTxt.visible = PlayState.instance.cpuControlled;
					PlayState.instance.botplayTxt.alpha = 1;
					PlayState.instance.botplaySine = 0;
				case "Chart Editor":
					PlayState.instance.openChartEditor();
				case "Exit to menu":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					WeekData.loadTheFirstEnabledMod();
					if(PlayState.isStoryMode) {
						MusicBeatState.switchState(new StoryMenuState());
					} else {
						MusicBeatState.switchState(new FreeplayState());
					}
					PlayState.cancelMusicFadeTween();
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					PlayState.changedDifficulty = false;
					PlayState.chartingMode = false;
				case "Return to Lair":
						PlayState.deathCounter = 0;
						PlayState.seenCutscene = false;
	
						WeekData.loadTheFirstEnabledMod();
						if(PlayState.isStoryMode) {
							MusicBeatState.switchState(new StoryMenuState());
						} else {
							MusicBeatState.switchState(new FreeplayState());
						}
						PlayState.cancelMusicFadeTween();
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						PlayState.changedDifficulty = false;
						PlayState.chartingMode = false;
			}
		}
	}

	function deleteSkipTimeText()
	{
		if(skipTimeText != null)
		{
			skipTimeText.kill();
			remove(skipTimeText);
			skipTimeText.destroy();
		}
		skipTimeText = null;
		skipTimeTracker = null;
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true; // For lua
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransOut = true;
			FlxG.resetState();
		}
		else
		{
			MusicBeatState.resetState();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	#if mobile
	override public function close() {
		FlxG.cameras.remove(pauseOverlay, true);
		super.close();
	}
	#end

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));

				if(item == skipTimeTracker)
				{
					curTime = Math.max(0, Conductor.songPosition);
					updateSkipTimeText();
				}
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			var obj = grpMenuShit.members[0];
			obj.kill();
			grpMenuShit.remove(obj, true);
			obj.destroy();
		}

		for (i in 0...menuItems.length) {
			var item = new Alphabet(90, 320, menuItems[i], true);
			var maxWidth = 980*(FlxG.width/1280);//adapt any resolution ig
			if (item.width > maxWidth)
			{
				item.scaleX = maxWidth / item.width;
			}
			item.isMenuItem = true;
			item.targetY = i;
			grpMenuShit.add(item);

			if(menuItems[i] == 'Skip Time')
			{
				skipTimeText = new FlxText(0, 0, 0, '', 64);
				skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				skipTimeText.scrollFactor.set();
				skipTimeText.borderSize = 2;
				skipTimeTracker = item;
				add(skipTimeText);

				updateSkipTextStuff();
				updateSkipTimeText();
			}
			if(menuItems[i] == 'Time Control')
				{
					skipTimeText = new FlxText(0, 0, 0, '', 64);
					skipTimeText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					skipTimeText.scrollFactor.set();
					skipTimeText.borderSize = 2;
					skipTimeTracker = item;
					add(skipTimeText);
	
					updateSkipTextStuff();
					updateSkipTimeText();
				}
		}
		curSelected = 0;
		changeSelection();
	}
	
	function updateSkipTextStuff()
	{
		if(skipTimeText == null || skipTimeTracker == null) return;

		skipTimeText.x = skipTimeTracker.x + skipTimeTracker.width + 60;
		skipTimeText.y = skipTimeTracker.y;
		skipTimeText.visible = (skipTimeTracker.alpha >= 1);
	}

	function updateSkipTimeText()
	{
		skipTimeText.text = FlxStringUtil.formatTime(Math.max(0, Math.floor(curTime / 1000)), false) + ' / ' + FlxStringUtil.formatTime(Math.max(0, Math.floor(FlxG.sound.music.length / 1000)), false);
	}
}
