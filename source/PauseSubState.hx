package;

#if desktop
import Discord.DiscordClient;
#end
import Song.SwagSong;
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

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Skip Song', 'Change Difficulty', 'Toggle One Shot Mode', 'Toggle Practice Mode', 'Change Character', 'Exit to menu'];
	var originalmenuItems:Array<String> = [];
	
	var curSelected:Int = 0;
	var modeText:FlxText;
	

	var pauseMusic:FlxSound;

	var lastSelected:Int = 0;

	var SelectionScreen:Bool = false;

	public function new(x:Float, y:Float)
	{
		if (!PlayState.isStoryMode)
		{
			menuItems.remove("Skip Song");
		}

		originalmenuItems = menuItems;

		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var bpmlevelInfo:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		bpmlevelInfo.text += "BPM:" + PlayState.SONG.bpm;
		bpmlevelInfo.scrollFactor.set();
		bpmlevelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		bpmlevelInfo.updateHitbox();
		add(bpmlevelInfo);

		var speedlevelInfo:FlxText = new FlxText(20, 15 + 64, 0, "", 32);
		speedlevelInfo.text += "SPEED:" + PlayState.SONG.speed;
		speedlevelInfo.scrollFactor.set();
		speedlevelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		speedlevelInfo.updateHitbox();
		add(speedlevelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 96, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var deathMenuCounter:FlxText = new FlxText(20, 15 + 128, 0, "", 32);
		deathMenuCounter.text = "Blue balled: " + PlayState.deathCounter;
		deathMenuCounter.scrollFactor.set();
		deathMenuCounter.setFormat(Paths.font('vcr.ttf'), 32);
		deathMenuCounter.updateHitbox();
		add(deathMenuCounter);

		modeText = new FlxText(20, 15 + 160, 0, "", 32);
		modeText.scrollFactor.set();
		modeText.setFormat(Paths.font('vcr.ttf'), 32);
		modeText.updateHitbox();
		// I KNOW HOW TO SPELL PRACTICE
		if (PlayState.praticemode)
		{
			modeText.visible = true;
			modeText.text = "PRACTICE MODE";
		}
		else if (PlayState.oneshot)
		{
			modeText.visible = true;
			modeText.text = "ONE SHOT MODE";
		}
		else
		{
			modeText.visible = false;
		}
		add(modeText);

		var sicks:FlxText = new FlxText(20, 568, 0, "", 32);
		sicks.text += "SICKS:" + PlayState.sicks;
		sicks.scrollFactor.set();
		sicks.setFormat(Paths.font("vcr.ttf"), 32);
		sicks.updateHitbox();
		add(sicks);

		var goods:FlxText = new FlxText(20, 568 + 32, 0, "", 32);
		goods.text += "GOODS:" + PlayState.goods;
		goods.scrollFactor.set();
		goods.setFormat(Paths.font("vcr.ttf"), 32);
		goods.updateHitbox();
		add(goods);

		var bads:FlxText = new FlxText(20, 568 + 64, 0, "", 32);
		bads.text += "BADS:" + PlayState.bads;
		bads.scrollFactor.set();
		bads.setFormat(Paths.font("vcr.ttf"), 32);
		bads.updateHitbox();
		add(bads);

		var shits:FlxText = new FlxText(20, 568 + 96, 0, "", 32);
		shits.text += "SHITS:" + PlayState.shits;
		shits.scrollFactor.set();
		shits.setFormat(Paths.font("vcr.ttf"), 32);
		shits.updateHitbox();
		add(shits);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		bpmlevelInfo.alpha = 0;
		speedlevelInfo.alpha = 0;
		deathMenuCounter.alpha = 0;
		sicks.alpha = 0;
		goods.alpha = 0;
		bads.alpha = 0;
		shits.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		bpmlevelInfo.x = FlxG.width - (bpmlevelInfo.width + 20);
		speedlevelInfo.x = FlxG.width - (speedlevelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		deathMenuCounter.x = FlxG.width - (deathMenuCounter.width + 20);
		modeText.x = FlxG.width - (modeText.width + 20);
		sicks.x = FlxG.width - (sicks.width + 20);
		goods.x = FlxG.width - (goods.width + 20);
		bads.x = FlxG.width - (bads.width + 20);
		shits.x = FlxG.width - (shits.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(bpmlevelInfo, {alpha: 1, y: bpmlevelInfo.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(speedlevelInfo, {alpha: 1, y: speedlevelInfo.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(deathMenuCounter, {alpha: 1, y: deathMenuCounter.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 1.1});

		FlxTween.tween(sicks, {alpha: 1, y: sicks.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(goods, {alpha: 1, y: goods.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(bads, {alpha: 1, y: bads.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(shits, {alpha: 1, y: shits.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	public function regenMenu()
	{
		grpMenuShit.clear();
		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		#if desktop
			if (PlayState.praticemode)
				PlayState.modeText = " - Practice Mode";
			else if (PlayState.oneshot)
				PlayState.modeText = " - One Shot Mode";
			else
				PlayState.modeText = '';
			DiscordClient.changePresence(PlayState.detailsPausedText, PlayState.SONG.song + " (" + PlayState.storyDifficultyText + PlayState.modeText + ")", PlayState.player2RPC, PlayState.player1RPC);
		#end

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
		var exit = controls.BACK;
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (exit)
		{
			if (SelectionScreen)
			{
				SelectionScreen = false;
				menuItems = originalmenuItems;
				regenMenu();
				curSelected = lastSelected;
				changeSelection();
			}
			else
				close();
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			var lastOpponent:String = PlayState.SONG.player2;
			var lastCharacter:String = PlayState.SONG.player1;
			var lastStage:String = PlayState.curStage;
			var difficulty:String = "";
			var gfVersion:String = "gf";
			SelectionScreen = false;
			switch (PlayState.curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';				
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
					if (PlayState.SONG.song.toLowerCase() == 'gugh' || PlayState.SONG.song.toLowerCase() == 'gums')
						gfVersion = 'gf-tankmenvoid';
					if (PlayState.SONG.song.toLowerCase() == 'stress')
						gfVersion = 'pico-speaker';
				case 'amogus':
					gfVersion = 'gf-amogus';
			}
			switch (PlayState.storyDifficulty)
			{
				case 0:
					difficulty = '-easy';						
				case 2:
					difficulty = '-hard';
				case 3:
					difficulty = '-hardplus';
			}

			switch (daSelected)
			{
				case "BACK":
					menuItems = originalmenuItems;
					regenMenu();
					curSelected = lastSelected;
					changeSelection();
				case "Skip Song":
					var difficulty = "";
					PlayState.deathCounter = 0;
					PlayState.storyPlaylist.remove(PlayState.storyPlaylist[0]);
					if (PlayState.storyPlaylist.length <= 0) 
					{
						FlxG.sound.playMusic(Paths.music('gumMenu'));
						OG.gunsCutsceneEnded = false;
						OG.ughCutsceneEnded = false;
						OG.stressCutsceneEnded = false;
						OG.horrorlandCutsceneEnded = false;
						FlxG.switchState(new StoryMenuState());
					}
					else
					{
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0].toLowerCase());
						if (!lastCharacter.startsWith("bf"))
							PlayState.SONG.player1 = lastCharacter;
						if (lastOpponent.startsWith("bf") && lastStage == "tank")
							PlayState.SONG = Song.loadFromJson("tank" + PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0].toLowerCase());
						if (lastOpponent.startsWith("bf") && lastStage == "philly")
							PlayState.SONG = Song.loadFromJson("play" + PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0].toLowerCase());
						if (lastOpponent.startsWith("bf") && lastCharacter.startsWith("monster"))
							PlayState.SONG = Song.loadFromJson("lemon" + PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0].toLowerCase());

						LoadingState.loadAndSwitchState(new PlayState());
					}
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					PlayState.deathCounter = 0;
					OG.gunsCutsceneEnded = false;
					OG.ughCutsceneEnded = false;
					OG.stressCutsceneEnded = false;
					OG.horrorlandCutsceneEnded = false;
					FlxG.switchState(new MainMenuState());
				case "Toggle Practice Mode":
					PlayState.praticemode = !PlayState.praticemode;
					modeText.visible = PlayState.praticemode;
					modeText.text = "PRACTICE MODE";
					modeText.x = FlxG.width - (modeText.width + 20);
					PlayState.oneshot = false;
				case "Toggle One Shot Mode":
					PlayState.oneshot = !PlayState.oneshot;
					modeText.visible = PlayState.oneshot;
					modeText.text = "ONE SHOT MODE";
					modeText.x = FlxG.width - (modeText.width + 20);
					PlayState.praticemode = false;
				case "Change Difficulty":
					lastSelected = curSelected;
					SelectionScreen = true;				
					menuItems = CoolUtil.difficultyArray.copy();
					menuItems.push("BACK");
					regenMenu();
					curSelected = 0;
					changeSelection();
				case "Change Character":
					lastSelected = curSelected;
					SelectionScreen = true;
					menuItems = ['bf', 'amog us', 'monster', 'tankman', 'pico', 'gf', 'BACK'];
					if (gfVersion != "gf-christmas" && gfVersion != "gf" && PlayState.SONG.player2 != "gf")
						menuItems.remove('gf');
					if (PlayState.SONG.song.toLowerCase() == "among us drip")
						menuItems.remove('bf');
					if (menuItems.contains(PlayState.SONG.player1))
						menuItems.remove(PlayState.SONG.player1);
					if (PlayState.SONG.player1 == 'bf-amogus' || PlayState.curStage.startsWith('school'))
						menuItems.remove('amog us');
					if (PlayState.curStage.startsWith('school') || PlayState.SONG.player1.startsWith('monster'))
						menuItems.remove('monster');
					if (PlayState.SONG.player1 == gfVersion)
						menuItems.remove('gf');
					if (PlayState.SONG.player1.startsWith('bf') && PlayState.SONG.player1 != 'bf-amogus')
						menuItems.remove('bf');
					if (PlayState.higheffort)
						menuItems.remove('tankman');
					regenMenu();
					curSelected = 0;
					changeSelection();
				case "EASY" | "NORMAL" | "HARD" | "HARD PLUS":
					switch (daSelected)
					{
						case "EASY":
							difficulty = '-easy';						
						case "HARD":
							difficulty = '-hard';
						case "HARD PLUS":
							difficulty = '-hardplus';
					}
					if (CoolUtil.difficultyString() == daSelected)
					{
						close();
						return;
					}
					var folder = PlayState.SONG.song.toLowerCase();
					if (PlayState.higheffort)
						folder += "/higheffort";
					PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.toLowerCase() + difficulty, folder);
					if (!lastCharacter.startsWith("bf"))
						PlayState.SONG.player1 = lastCharacter;
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson("tank" + PlayState.SONG.song.toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("gftutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson("play" + PlayState.SONG.song.toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith("monster"))
						PlayState.SONG = Song.loadFromJson("lemon" + PlayState.SONG.song.toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = curSelected;
					LoadingState.loadAndSwitchState(new PlayState());
				case "tankman":
					if (PlayState.curStage == 'tank')
						PlayState.SONG = Song.loadFromJson("tank" + PlayState.SONG.song.toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("lemon","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (PlayState.curStage == "school" || PlayState.curStage == "schoolEvil")
					{
						PlayState.SONG.player1 = "tankman-pixel";
					}
					else if (PlayState.SONG.song.toLowerCase() == 'gugh')
					{
						PlayState.SONG.player1 = "tankmannoamongus";
					}
					else
					{
						PlayState.SONG.player1 = "tankman";
					}
					LoadingState.loadAndSwitchState(new PlayState());
				case "bf":
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("lemon","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					PlayState.SONG.player1 = PlayState.SONG.player1;
					LoadingState.loadAndSwitchState(new PlayState());
				case "pico":
					if (PlayState.curStage == 'philly')
						PlayState.SONG = Song.loadFromJson("play" + PlayState.SONG.song.toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("lemon","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (PlayState.curStage == "school" || PlayState.curStage == "schoolEvil")
					{
						PlayState.SONG.player1 = "pico-pixel";
					}
					else
					{
						PlayState.SONG.player1 = "pico";
					}
					LoadingState.loadAndSwitchState(new PlayState());
				case "gf":
					if (PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("gftutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("lemon","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					PlayState.SONG.player1 = gfVersion;
					LoadingState.loadAndSwitchState(new PlayState());
				case "amog us":
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("lemon","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					PlayState.SONG.player1 = "bf-amogus";
					LoadingState.loadAndSwitchState(new PlayState());
				case "monster":
					if (PlayState.SONG.player2.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson("lemon" + PlayState.SONG.song.toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastStage == "tank")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("tank","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && PlayState.SONG.song.toLowerCase() == "tutorial")
						PlayState.SONG = Song.loadFromJson("tutorial" + difficulty, "tutorial");
					if (lastOpponent.startsWith("bf") && lastStage == "philly")
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("play","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					if (lastOpponent.startsWith("bf") && lastCharacter.startsWith('monster'))
						PlayState.SONG = Song.loadFromJson(PlayState.SONG.song.replace("lemon","").toLowerCase() + difficulty, PlayState.SONG.song.toLowerCase());
					PlayState.SONG.player1 = "monster";
					if (PlayState.curStage.startsWith('mall'))
						PlayState.SONG.player1 += "-christmas";
					LoadingState.loadAndSwitchState(new PlayState());
			}

			if (FlxG.keys.justPressed.F11 || FlxG.keys.justPressed.F)
        	{
				FlxG.save.data.fullscreen = !FlxG.fullscreen;
				FlxG.save.flush();
        		FlxG.fullscreen = !FlxG.fullscreen;
        	}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}
	
	


	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

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
			}
		}
	}
}
