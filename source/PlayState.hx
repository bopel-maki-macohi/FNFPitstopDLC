package;

import pitstop.play.songs.ArgueParkSong;
import pitstop.play.SongClass;
import pitstop.play.stages.*;
import pitstop.play.StageGroup;
import Section.SwagSection;
import Song.SwagSong;
import flixel.*;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup;
import flixel.math.*;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.*;
import flixel.ui.FlxBar;
import flixel.util.*;
import shaderslmfao.*;
import ui.PreferencesMenu;
import pitstop.play.notes.*;

using StringTools;

#if discord_rpc
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	override function destroy()
	{
		super.destroy();

		instance = null;
	}

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;

	public var vocals:FlxSound;
	public var vocalsFinished:Bool = false;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	public var camFollow:FlxObject;

	public static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<NoteStatic>;
	public var playerStrums:FlxTypedGroup<NoteStatic>;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	public static var seenCutscene:Bool = false;

	public var backgroundSprites:FlxTypedGroup<FlxSprite>;
	public var midgroundSprites:FlxTypedGroup<FlxSprite>;
	public var foregroundSprites:FlxTypedGroup<FlxSprite>;

	public var songScore:Int = 0;
	public var scoreTxt:FlxText;

	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;

	#if discord_rpc
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public var camPos:FlxPoint;

	override public function create()
	{
		if (instance != null)
			instance = null;
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new SwagCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		FlxG.sound.cache(Paths.inst(PlayState.SONG.song, storyDifficulty));
		if (SONG.needsVoices)
			FlxG.sound.cache(Paths.voices(PlayState.SONG.song, storyDifficulty));
		curSong = SONG.song.toLowerCase();

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		backgroundSprites = new FlxTypedGroup<FlxSprite>();
		midgroundSprites = new FlxTypedGroup<FlxSprite>();
		foregroundSprites = new FlxTypedGroup<FlxSprite>();

		#if discord_rpc
		initDiscord();
		#end

		gf = new Character(400, 130, SONG?.gfVersion ?? 'gf');
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		boyfriend = new Character(770, 450, SONG.player1);

		add(backgroundSprites);

		add(gf);

		add(midgroundSprites);

		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		initSongShits(SONG);

		makeStage(SONG.stage ?? 'stage');

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150; // 150 just random ass number lol

		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<NoteStatic>();
		add(strumLineNotes);

		// fake notesplash cache type deal so that it loads in the graphic?

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		var noteSplash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0.1;

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<NoteStatic>();

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];

		startingSong = true;

		// remember this
		// if (isStoryMode && !seenCutscene)
		startCountdown();

		super.create();
	}

	function initDiscord():Void
	{
		#if discord_rpc
		storyDifficultyText = difficultyString();
		iconRPC = SONG.player2;

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		detailsText = isStoryMode ? "Story Mode: Week " + storyWeek : "Freeplay";
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;
		camHUD.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (swagCounter % gfSpeed == 0)
				gf.dance();

			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.anim?.curAnim?.name.startsWith("sing"))
					boyfriend.playAnim('idle');
				if (!dad.anim?.curAnim?.name.startsWith("sing"))
					dad.dance();
			}

			if (generatedMusic)
				notes.sort(sortNotes, FlxSort.DESCENDING);

			var introSprPaths:Array<String> = ["ready", "set", "go"];

			var introSndPaths:Array<String> = [
				"intro3", "intro2",
				"intro1", "introGo"
			];

			if (swagCounter > 0)
				readySetGo(introSprPaths[swagCounter - 1]);
			FlxG.sound.play(Paths.sound(introSndPaths[swagCounter]), 0.6);

			swagCounter += 1;
		}, 4);
	}

	function readySetGo(path:String):Void
	{
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(path));
		spr.scrollFactor.set();

		if (curStage.startsWith('school'))
			spr.setGraphicSize(Std.int(spr.width * daPixelZoom));

		spr.updateHitbox();
		spr.screenCenter();
		add(spr);
		FlxTween.tween(spr, {y: spr.y += 100, alpha: 0}, Conductor.crochet / 1000, {
			ease: FlxEase.cubeInOut,
			onComplete: function(twn:FlxTween)
			{
				spr.destroy();
			}
		});
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		FlxG.sound.playMusic(Paths.inst(SONG.song, storyDifficulty), 1, false);
		if (paused)
			FlxG.sound.music.pause();

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if discord_rpc
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	public function generateSong():Void
	{
		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		vocals = new FlxSound();
		if (SONG.needsVoices)
			vocals.loadEmbedded(Paths.voices(SONG.song, storyDifficulty));
		vocals.onComplete = () -> vocalsFinished = true;

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note = null;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
					swagNote.x += FlxG.width / 2; // general offset
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	// Now you are probably wondering why I made 2 of these very similar functions
	// sortByShit(), and sortNotes(). sortNotes is meant to be used by both sortByShit(), and the notes FlxGroup
	// sortByShit() is meant to be used only by the unspawnNotes array.
	// and the array sorting function doesnt need that order variable thingie
	// this is good enough for now lololol HERE IS COMMENT FOR THIS SORTA DUMB DECISION LOL
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(order:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note)
	{
		return FlxSort.byValues(order, Obj1.strumTime, Obj2.strumTime);
	}

	// ^ These two sorts also look cute together ^

	public function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:NoteStatic = new NoteStatic(i, strumLine.y);

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			if (player == 1)
				playerStrums.add(babyArrow);

			babyArrow.animation.play('static');

			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			for (tween in tweensList)
				tween.active = true;

			if (FlxG.sound.music != null && !startingSong)
				resyncVocals();

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if discord_rpc
			if (startTimer.finished)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		super.closeSubState();
	}

	#if discord_rpc
	override public function onFocus():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
		{
			if (Conductor.songPosition > 0.0)
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			else
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused && FlxG.autoPause)
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void
	{
		if (_exiting)
			return;

		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		if (vocalsFinished)
			return;

		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		// do this BEFORE super.update() so songPosition is accurate
		updateConductor();

		super.update(elapsed);

		for (stage in stageClasses)
			stage.update(elapsed);

		for (song in songClasses)
			song.update(elapsed);

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.volume = FlxG.sound.volume;
			if (vocals != null)
				vocals.volume = FlxG.sound.music.volume;
		}

		updateUI();

		handlePausing();

		handleDebugKeys();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0;
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0;

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null && useDefaultCameraStuffs)
		{
			cameraRightSide = SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'fresh')
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
			}

		if (curSong == 'bopeebo')
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
			}

		// better streaming of shit

		if (!inCutscene && !_exiting && health <= 0 && !practiceMode)
		{
			gameOver();
		}

		while (unspawnNotes[0] != null && unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
		{
			var dunceNote:Note = unspawnNotes[0];
			notes.add(dunceNote);

			var index:Int = unspawnNotes.indexOf(dunceNote);
			unspawnNotes.shift();
		}

		if (generatedMusic)
			scrollNotes();

		if (!inCutscene)
			keyShit();
	}

	function updateConductor()
	{
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset; // 20 is THE MILLISECONDS??

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}
	}

	function updateUI()
	{
		scoreTxt.text = "Score:" + songScore;
	}

	function handlePausing()
	{
		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
				FlxG.switchState(() -> new GitarooPause());
			else
			{
				var boyfriendPos = boyfriend.getScreenPosition();

				var pauseSubState = new PauseSubState(boyfriendPos.x, boyfriendPos.y);
				openSubState(pauseSubState);

				for (tween in tweensList)
					tween.active = false;

				pauseSubState.camera = camHUD;
				boyfriendPos.put();
			}

			#if discord_rpc
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}
	}

	function handleDebugKeys()
	{
		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(() -> new ChartingState());

			#if discord_rpc
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		if (FlxG.keys.justPressed.EIGHT)
		{
			/*
				8 for opponent char
				SHIFT+8 for player char
				CTRL+SHIFT+8 for gf 
			 */

			if (FlxG.keys.pressed.SHIFT)
				if (FlxG.keys.pressed.CONTROL)
					FlxG.switchState(() -> new AnimationDebug(gf.curCharacter));
				else
					FlxG.switchState(() -> new AnimationDebug(SONG.player1));
			else
				FlxG.switchState(() -> new AnimationDebug(SONG.player2));
		}

		// nope.
		// if (FlxG.keys.justPressed.PAGEUP)
		// 	changeSection(1);
		// if (FlxG.keys.justPressed.PAGEDOWN)
		// 	changeSection(-1);
		#end

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				trace("RESET = True");
			}

			#if CAN_CHEAT // brandon's a pussy
			if (controls.CHEAT)
			{
				health += 1;
				trace("User is cheating!");
			}
			#end
		}
	}

	function gameOver()
	{
		persistentUpdate = false;
		persistentDraw = false;
		paused = true;

		vocals.stop();
		FlxG.sound.music.stop();

		deathCounter += 1;

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

		#if discord_rpc
		// Game Over doesn't get his own variable because it's only used here
		DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end
	}

	function scrollNotes()
	{
		notes.forEachAlive(function(daNote:Note)
		{
			if ((PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
				|| (!PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height))
				daNote.active = daNote.visible = false;
			else
				daNote.visible = daNote.active = true;

			var notePos:Float = strumLine.y;
			var notePosOffsetsies:Float = (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2));

			if (PreferencesMenu.getPref('downscroll'))
				notePos += notePosOffsetsies;
			else
				notePos -= notePosOffsetsies;

			daNote.y = notePos;

			if (daNote.isSustainNote)
				scrollNotesSustainClipRect(daNote);

			if (!daNote.mustPress && daNote.wasGoodHit)
			{
				if (SONG.song != 'Tutorial')
					camZooming = true;

				var altAnim:String = "";

				if (SONG.notes[Math.floor(curStep / 16)] != null)
					if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = '-alt';

				if (daNote.altNote)
					altAnim = '-alt';

				switch (Math.abs(daNote.noteData))
				{
					case 0:
						dad.playAnim('singLEFT' + altAnim, true);
					case 1:
						dad.playAnim('singDOWN' + altAnim, true);
					case 2:
						dad.playAnim('singUP' + altAnim, true);
					case 3:
						dad.playAnim('singRIGHT' + altAnim, true);
				}

				dad.holdTimer = 0;

				if (SONG.needsVoices)
					vocals.volume = 1;

				murderNote(daNote);
			}

			if (daNote.isSustainNote && daNote.wasGoodHit)
			{
				if ((!PreferencesMenu.getPref('downscroll') && daNote.y < -daNote.height)
					|| (PreferencesMenu.getPref('downscroll') && daNote.y > FlxG.height))
					murderNote(daNote);
			}
			else if (daNote.tooLate || daNote.wasGoodHit)
			{
				if (daNote.tooLate)
					noteMiss();

				murderNote(daNote);
			}
		});
	}

	function scrollNotesSustainClipRect(daNote:Note)
	{
		var strumLineMid = strumLine.y + Note.swagWidth / 2;

		var swagRect:FlxRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
		var baseClipRectCondition:Bool = (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit)));
		var susnoteYOffset = daNote.offset.y * daNote.scale.y;

		if (PreferencesMenu.getPref('downscroll'))
		{
			if (daNote.animation.curAnim.name.endsWith("end") && daNote.prevNote != null)
				daNote.y += daNote.prevNote.height;
			else
				daNote.y += daNote.height / 2;

			swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
		}

		if (baseClipRectCondition)
		{
			if (PreferencesMenu.getPref('downscroll') && daNote.y - susnoteYOffset + daNote.height >= strumLineMid)
			{
				// clipRect is applied to graphic itself so use frame Heights

				swagRect.height = (strumLineMid - daNote.y) / daNote.scale.y;
				swagRect.y = daNote.frameHeight - swagRect.height;
				daNote.clipRect = swagRect;
			}
			else if (!PreferencesMenu.getPref('downscroll') && daNote.y + susnoteYOffset <= strumLineMid)
			{
				swagRect.y = (strumLineMid - daNote.y) / daNote.scale.y;
				swagRect.height -= swagRect.y;
				daNote.clipRect = swagRect;
			}
		}
	}

	function killCombo():Void
	{
		if (combo > 5 && gf.animOffsets.exists('sad'))
			gf.playAnim('sad');
		if (combo != 0)
		{
			combo = 0;
			displayCombo();
		}
	}

	function endSong():Void
	{
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (SONG.validScore)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
			else
			{
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
			}

			if (storyPlaylist.length <= 0)
			{
				// FlxG.switchState(() -> new StoryMenuState());

				if (SONG.validScore)
					Highscore.saveWeekScore(LoadingState.getWeekTitleShit(storyWeek), campaignScore, storyDifficulty);
			}
			else
			{
				var difficulty:String = Highscore.formatSong('', storyDifficulty);

				trace('LOADING NEXT SONG');
				trace(storyPlaylist[0].toLowerCase() + difficulty);

				FlxG.sound.music.stop();
				vocals.stop();

				prevCamFollow = camFollow;

				SONG = Song.loadFromJson(storyPlaylist[0].toLowerCase() + difficulty, storyPlaylist[0]);
				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(() -> new FreeplayState());
		}
	}

	// gives score and pops up rating
	public function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		vocals.volume = 1;

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}

		var isSick:Bool = daRating == 'sick';

		if (isSick)
		{
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(noteSplash);
		}

		if (!practiceMode)
			songScore += score;

		var ratingPath:String = daRating;

		rating.loadGraphic(Paths.image(ratingPath));
		rating.x = FlxG.width * 0.55 - 40;
		// make sure rating is visible lol!
		if (rating.x < FlxG.camera.scroll.x)
			rating.x = FlxG.camera.scroll.x;
		else if (rating.x > FlxG.camera.scroll.x + FlxG.camera.width - rating.width)
			rating.x = FlxG.camera.scroll.x + FlxG.camera.width - rating.width;

		rating.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 - 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		add(rating);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
		if (combo >= 10 || combo == 0)
			displayCombo();
	}

	function displayCombo():Void
	{
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
		comboSpr.y = FlxG.camera.scroll.y + FlxG.camera.height * 0.4 + 80;
		comboSpr.x = FlxG.width * 0.55;

		// make sure combo is visible lol!
		// 194 fits 4 combo digits
		if (comboSpr.x < FlxG.camera.scroll.x + 194)
			comboSpr.x = FlxG.camera.scroll.x + 194;
		else if (comboSpr.x > FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width)
			comboSpr.x = FlxG.camera.scroll.x + FlxG.camera.width - comboSpr.width;

		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;
		comboSpr.velocity.x += FlxG.random.int(1, 10);

		add(comboSpr);

		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.updateHitbox();

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		var seperatedScore:Array<Int> = [];
		var tempCombo:Int = combo;

		while (tempCombo != 0)
		{
			seperatedScore.push(tempCombo % 10);
			tempCombo = Std.int(tempCombo / 10);
		}
		while (seperatedScore.length < 3)
			seperatedScore.push(0);

		var daLoop:Int = 1;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.y = comboSpr.y;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.x = comboSpr.x - (43 * daLoop); //- 90;
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
	}

	var cameraRightSide:Bool = false;

	function cameraMovement()
	{
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			if (SONG.song.toLowerCase() == 'tutorial')
				tweenCamIn();
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			if (SONG.song.toLowerCase() == 'tutorial')
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
		}
	}

	public function keyShit():Void
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var pressArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
					goodNoteHit(daNote);
			});

		// PRESSES, check for note hits
		if (pressArray.contains(true) && generatedMusic)
			checkForNoteHit(pressArray);

		boyfriend.isHolding = holdArray.contains(true);

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function checkForNoteHit(pressArray:Array<Bool>)
	{
		boyfriend.holdTimer = 0;

		var possibleNotes:Array<Note> = []; // notes that can be hit
		var directionList:Array<Int> = []; // directions that can be hit
		var dumbNotes:Array<Note> = []; // notes to kill later

		notes.forEachAlive(function(daNote:Note)
		{
			var checkNote = daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit;

			if (!checkNote)
				return;

			if (directionList.contains(daNote.noteData))
			{
				for (coolNote in possibleNotes)
					if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
					{
						/**
						 * if it's the same note twice at < 10ms distance, just delete it
						 * EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
						 */

						dumbNotes.push(daNote);
						break;
					}
					else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
					{
						/**
						 * if daNote is earlier than existing note (coolNote), replace
						 */

						possibleNotes.remove(coolNote);
						possibleNotes.push(daNote);
						break;
					}
			}
			else
			{
				possibleNotes.push(daNote);
				directionList.push(daNote.noteData);
			}
		});

		for (note in dumbNotes)
			murderNote(note);

		possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

		if (perfectMode)
			goodNoteHit(possibleNotes[0]);
		else if (possibleNotes.length > 0)
		{
			// if a direction is hit that shouldn't be
			for (shit in 0...pressArray.length)
				if (pressArray[shit] && !directionList.contains(shit))
					noteMiss(shit);

			for (coolNote in possibleNotes)
				if (pressArray[coolNote.noteData])
					goodNoteHit(coolNote);
		}
		else
			for (shit in 0...pressArray.length)
				if (pressArray[shit])
					noteMiss(shit);
	}

	function noteMiss(direction:Int = 1):Void
	{
		health -= 0.04;
		killCombo();

		if (!practiceMode)
			songScore -= 10;

		vocals.volume = 0;
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));

		switch (direction)
		{
			case 0:
				boyfriend.playAnim('singLEFTmiss', true);
			case 1:
				boyfriend.playAnim('singDOWNmiss', true);
			case 2:
				boyfriend.playAnim('singUPmiss', true);
			case 3:
				boyfriend.playAnim('singRIGHTmiss', true);
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (note.wasGoodHit)
			return;

		if (!note.isSustainNote)
		{
			combo += 1;
			popUpScore(note.strumTime, note);
		}

		health += 0.023;

		switch (note.noteData)
		{
			case 0:
				boyfriend.playAnim('singLEFT', true);
			case 1:
				boyfriend.playAnim('singDOWN', true);
			case 2:
				boyfriend.playAnim('singUP', true);
			case 3:
				boyfriend.playAnim('singRIGHT', true);
		}

		playerStrums.forEach((spr) -> if (Math.abs(note.noteData) == spr.ID) spr.animation.play('confirm', true));

		note.wasGoodHit = true;
		vocals.volume = 1;

		if (!note.isSustainNote)
			murderNote(note);
	}

	function murderNote(note:Note)
	{
		note.active = note.visible = false;

		note.kill();
		notes.remove(note, true);
		note.destroy();
	}

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		for (song in songClasses)
			song.onStepHit(curStep);
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
			notes.sort(sortNotes, FlxSort.DESCENDING);

		if (SONG.notes[Math.floor(curStep / 16)] != null)
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}

		if (PreferencesMenu.getPref('camera-zoom'))
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
			gf.dance();

		if (curBeat % 2 == 0)
		{
			if (!boyfriend.anim?.curAnim?.name.startsWith("sing"))
				boyfriend.playAnim('idle');
			if (!dad.anim?.curAnim?.name.startsWith("sing"))
				dad.dance();
		}

		if (curBeat % 8 == 7 && curSong == 'bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && curSong == 'tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		for (spriteGroup in [backgroundSprites, midgroundSprites, foregroundSprites])
		{
			spriteGroup.forEach((spr) ->
			{
				if (Std.isOfType(spr, BGSprite))
				{
					final bgSprite:BGSprite = cast spr;
					if (bgSprite != null)
						bgSprite.dance();
				}
			});
		}

		for (song in songClasses)
			song.onBeatHit(curBeat);
	}

	function initSongShits(song:SwagSong)
	{
		switch (song.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
			case 'dad':
				camPos.x += 400;
		}

		switch (curSong)
		{
			case 'argue park':
				appendSongClass(new ArgueParkSong());
		}
	}

	public var tweensList:Array<FlxTween> = [];

	public var useDefaultCameraStuffs:Bool = true;

	public function makeStage(stage:String)
	{
		curStage = stage;

		switch (stage)
		{
			case 'romancePark':
				loadStageFromClass(new RomanceParkStage());

			default:
				curStage = 'mainStage';
				loadStageFromClass(new MainStage());
		}

		for (song in songClasses)
			song.postBuildStage();
	}

	public var songClasses:Array<SongClass> = [];
	public var stageClasses:Array<StageGroup> = [];

	function loadStageFromClass(stageClass:StageGroup)
	{
		if (stageClass != null)
			stageClass.buildStage();

		if (stageClass != null)
			stageClasses.push(stageClass);
	}

	function appendSongClass(songClass:SongClass)
	{
		if (songClass != null)
			songClass.make();

		if (songClass != null)
			songClasses.push(songClass);
	}
}
