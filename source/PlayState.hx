package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxAngle;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.Lib;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var praticemode:Bool = false;
	public static var oneshot:Bool = false;
	public static var gainmultiplier:Float = 1;
	public static var losemultiplier:Float = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	public static var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var player2Strums:FlxTypedGroup<FlxSprite>;

	private var strumming2:Array<Bool> = [false, false, false, false];

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var goodnotes:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;
	
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var FULLhealthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var tank5:FlxSprite;
	var tank4:FlxSprite;
	var tank3:FlxSprite;
	var tank2:FlxSprite;
	var tank1:FlxSprite;
	var tank0:FlxSprite;
	var tank:FlxSprite;
	var runningtank:FlxSprite;
	var tankground:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	public static var songScore:Int = 0;
	var accuracyTxt:FlxText;
	var ratingTxt:FlxText;
	var scoreTxt:FlxText;
	var healthTxt:FlxText;
	var missesTxt:FlxText;
	var lengthTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	public static var storyDifficultyText:String = "";
	public static var player1RPC:String = "";
	public static var player2RPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	public static var detailsPausedText:String = "";
	public static var modeText:String = "";
	#end

	public var timer:FlxTimer;

	var runningTankSpeed:Array<Float> = [];
	var tankGoingRight:Array<Bool> = [];
	var tankStrumTime:Array<Dynamic> = [];
	var endingOffset:Array<Float> = [];
	var runningtanks:FlxTypedGroup<FlxSprite>;

	public static var higheffort:Bool = false;

	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
	{
		var length:Float = note.sustainLength;

		if (length > 0)
		{
			strumming2[strum] = true;
		}

		var bps:Float = Conductor.bpm / 60;
		var spb:Float = 1 / bps;

		if (!note.isSustainNote)
		{
			timer = new FlxTimer();
			timer.start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
			{
				if (!strumming2[strum])
				{
					spr.animation.play("static", true);
					spr.centerOffsets();
				}
				else
				{
					strumming2[strum] = false;
					spr.animation.play("static", true);
					spr.centerOffsets();
				}
			});
		}
	}

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		timer = new FlxTimer();
		misses = 0;
		goodnotes = 0;
		songScore = 0;
		gainmultiplier = 1;
		losemultiplier = 1;
		sicks = 0;
		goods = 0;
		bads = 0;
		shits = 0;

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var splash = new NoteSplash(100, 100, 0);
		splash.alpha = 0.1;
		grpNoteSplashes.add(splash);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'dadbattle' | 'fresh' | 'bopeebo' | 'tutorial':
				if (SONG.player1 == "tankman")
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/TankDialogue'));
				else if (SONG.player1 == "pico")
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/PicoDialogue'));
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/Dialogue'));
			case 'senpai' | 'roses' | 'thorns':
				if (SONG.player1 == "tankman-pixel")
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/TankDialogue'));
				else if (SONG.player1 == "pico-pixel")
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/PicoDialogue'));
				else
					dialogue = CoolUtil.coolTextFile(Paths.txt(SONG.song.toLowerCase() + '/Dialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
			case 3:
				storyDifficultyText = "Hard Plus";
				gainmultiplier = 0.5;
				losemultiplier = 2;
		}

		player1RPC = SONG.player1;

		switch (player1RPC)
		{
			case 'mom-car':
				player1RPC = 'mom';
			case 'bf-car':
				player1RPC = 'bf';
		}

		player2RPC = SONG.player2;

		switch (player2RPC)
		{
			case 'mom-car':
				player2RPC = 'mom';
			case 'bf-car':
				player2RPC = 'bf';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			var weektxt:String = "Week " + Std.string(storyWeek);
			if (storyWeek == 0)
				weektxt = 'tutorial';
			if (storyWeek == 8)
				weektxt = 'Week meme';
			detailsText = "in Story Mode: " + weektxt;
		}
		else
		{
			detailsText = "in Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC);
		#end

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south' | 'iphone': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
		          }
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		                  overlayShit.alpha = 0.5;
		                  // add(overlayShit);

		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  var limoTex = Paths.getSparrowAtlas('limo/limoDrive');

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = limoTex;
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		                  // add(limo);
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.6, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();

		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  if (SONG.song.toLowerCase() == 'roses')
	                          {
		                          bgGirls.getScared();
		                  }

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);
		          }
		          case 'thorns':
		          {
		                  curStage = 'schoolEvil';

		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                          var posY = 200;

		                  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);

		                  /* 
		                           var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
		                           bg.scale.set(6, 6);
		                           // bg.setGraphicSize(Std.int(bg.width * 6));
		                           // bg.updateHitbox();
		                           add(bg);

		                           var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
		                           fg.scale.set(6, 6);
		                           // fg.setGraphicSize(Std.int(fg.width * 6));
		                           // fg.updateHitbox();
		                           add(fg);

		                           wiggleShit.effectType = WiggleEffectType.DREAMY;
		                           wiggleShit.waveAmplitude = 0.01;
		                           wiggleShit.waveFrequency = 60;
		                           wiggleShit.waveSpeed = 0.8;
		                    */

		                  // bg.shader = wiggleShit.shader;
		                  // fg.shader = wiggleShit.shader;

		                  /* 
		                            var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
		                            var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

		                            // Using scale since setGraphicSize() doesnt work???
		                            waveSprite.scale.set(6, 6);
		                            waveSpriteFG.scale.set(6, 6);
		                            waveSprite.setPosition(posX, posY);
		                            waveSpriteFG.setPosition(posX, posY);

		                            waveSprite.scrollFactor.set(0.7, 0.8);
		                            waveSpriteFG.scrollFactor.set(0.9, 0.8);

		                            // waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
		                            // waveSprite.updateHitbox();
		                            // waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
		                            // waveSpriteFG.updateHitbox();

		                            add(waveSprite);
		                            add(waveSpriteFG);
		                    */
		          }

				  case 'ugh' | 'guns' | 'stress' | 'gugh' | 'gums' | 'picospeaker':
				  {
					  defaultCamZoom = 0.9;
					  curStage = 'tank';
					  var bg:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('tankSky'));
		              bg.antialiasing = true;
					  bg.scrollFactor.set(0,0);
		              add(bg);

					  var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700,-100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tankClouds'));
					  clouds.active = true;
					  clouds.velocity.x = FlxG.random.float(5,15);
					  clouds.antialiasing = true;
					  clouds.scrollFactor.set(0.1,0.1);
					  add(clouds);

					  var bgmountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tankMountains'));
					  bgmountains.setGraphicSize(Std.int(bgmountains.width * 1.2));
					  bgmountains.antialiasing = true;
					  bgmountains.updateHitbox();
					  bgmountains.scrollFactor.set(0.2,0.2);
					  add(bgmountains);
					  
					  var bgbuildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankBuildings'));
					  bgbuildings.setGraphicSize(Std.int(bgbuildings.width * 1.1));
					  bgbuildings.antialiasing = true;
					  bgbuildings.updateHitbox();
					  bgbuildings.scrollFactor.set(0.3, 0.3);
					  add(bgbuildings);

					  var bgruins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankRuins'));
					  bgruins.setGraphicSize(Std.int(bgruins.width * 1.1));
					  bgruins.antialiasing = true;
					  bgruins.updateHitbox();
					  bgruins.scrollFactor.set(0.35,0.35);
					  add(bgruins);

					  var leftsmoke:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('SmokeLeft'));
					  leftsmoke.frames = Paths.getSparrowAtlas('smokeLeft');
		              leftsmoke.animation.addByPrefix('smoke', 'SmokeBlurLeft', 24, true);
					  leftsmoke.antialiasing = true;
					  leftsmoke.animation.play('smoke');
					  leftsmoke.scrollFactor.set(0.4,0.4);
					  add(leftsmoke);

					  var rightsmoke:FlxSprite = new FlxSprite(1100, -100).loadGraphic(Paths.image('SmokeRight'));
					  rightsmoke.frames = Paths.getSparrowAtlas('smokeRight');
		              rightsmoke.animation.addByPrefix('smoke', 'SmokeRight', 24, true);
					  rightsmoke.antialiasing = true;
					  rightsmoke.animation.play('smoke');
					  rightsmoke.scrollFactor.set(0.4,0.4);
					  add(rightsmoke);

					  var bgwatchtower:FlxSprite = new FlxSprite(100, 50).loadGraphic(Paths.image('tankWatchtower'));
					  bgwatchtower.frames = Paths.getSparrowAtlas('tankWatchtower');
		              bgwatchtower.animation.addByPrefix('watchtower', 'watchtower gradient color', 24);
					  bgwatchtower.animation.play('watchtower');
					  bgwatchtower.antialiasing = true;
					  bgwatchtower.scrollFactor.set(0.5,0.5);
					  add(bgwatchtower);

					  tank = new FlxSprite(300, 300).loadGraphic(Paths.image('tankRolling'));
					  tank.frames = Paths.getSparrowAtlas('tankRolling');
		              tank.animation.addByPrefix('tankRolling', 'BG tank w lighting', 24, true);
					  tank.antialiasing = true;
					  tank.animation.play('tankRolling');
					  tank.scrollFactor.set(0.5,0.5);
					  add(tank);

					  runningtanks = new FlxTypedGroup<FlxSprite>();

					  tankground = new FlxSprite(-420, -150).loadGraphic(Paths.image('tankGround'));
					  tankground.setGraphicSize(Std.int(tankground.width * 1.15));
					  tankground.antialiasing = true;
					  tankground.updateHitbox();
					  add(tankground);

					  tank0 = new FlxSprite(-500, 650).loadGraphic(Paths.image('tank0'));
					  tank1  = new FlxSprite(-300, 750).loadGraphic(Paths.image('tank1'));
					  tank2  = new FlxSprite(450, 940).loadGraphic(Paths.image('tank2'));
					  tank3  = new FlxSprite(1300, 1200).loadGraphic(Paths.image('tank3'));
					  tank4  = new FlxSprite(1300, 900).loadGraphic(Paths.image('tank4'));
					  tank5  = new FlxSprite(1620, 700).loadGraphic(Paths.image('tank5'));
					  tank0.antialiasing = true;
					  tank1.antialiasing = true;
					  tank2.antialiasing = true;
					  tank3.antialiasing = true;
					  tank4.antialiasing = true;
					  tank5.antialiasing = true;
					  tank0.frames = Paths.getSparrowAtlas('tank0');
		              tank0.animation.addByPrefix('tank', 'fg', 24);
					  tank1.frames = Paths.getSparrowAtlas('tank1');
		              tank1.animation.addByPrefix('tank', 'fg', 24);
					  tank2.frames = Paths.getSparrowAtlas('tank2');
		              tank2.animation.addByPrefix('tank', 'foreground', 24);
					  tank3.frames = Paths.getSparrowAtlas('tank3');
		              tank3.animation.addByPrefix('tank', 'fg', 24);
					  tank4.frames = Paths.getSparrowAtlas('tank4');
		              tank4.animation.addByPrefix('tank', 'fg', 24);
					  tank5.frames = Paths.getSparrowAtlas('tank5');
		              tank5.animation.addByPrefix('tank', 'fg', 24);
					  tank0.animation.play('tank');
					  tank1.animation.play('tank');
					  tank2.animation.play('tank');
					  tank3.animation.play('tank');
					  tank4.animation.play('tank');
					  tank5.animation.play('tank');
					  tank0.scrollFactor.set(1.7,1.5);
					  tank1.scrollFactor.set(2,0.2);
					  tank2.scrollFactor.set(1.5,1.5);
					  tank3.scrollFactor.set(3.5,2.5);
					  tank4.scrollFactor.set(1.5,1.5);
					  tank5.scrollFactor.set(1.5,1.5);
				  }

				  case 'among us drip':
				  {
		                  defaultCamZoom = 0.9;
		                  curStage = 'amogus';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('amogus_bg'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var ground:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('amogusGround'));
		                  ground.setGraphicSize(Std.int(ground.width * 1.1));
		                  ground.updateHitbox();
		                  ground.antialiasing = true;
		                  ground.scrollFactor.set(0.9, 0.9);
		                  ground.active = false;
		                  add(ground);
				  }

		          default:
		          {
		                  defaultCamZoom = 0.9;
		                  curStage = 'stage';
		                  var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.9, 0.9);
		                  bg.active = false;
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
		          }
              }

		var gfVersion:String = 'gf';
		{
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';				
				case 'mall' | 'mallEvil':
					gfVersion = 'gf-christmas';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				case 'tank':
					gfVersion = 'gf-tankmen';
					if (SONG.song.toLowerCase() == 'gugh' || SONG.song.toLowerCase() == 'gums')
						gfVersion = 'gf-tankmenvoid';
					if (SONG.song.toLowerCase() == 'stress')
						gfVersion = 'pico-speaker';
				case 'amogus':
					gfVersion = 'gf-amogus';
			}
		}
		
	

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		if (SONG.song.toLowerCase() == 'stress')
		{
			runningtank = new FlxSprite(FlxG.width + 1000, 500);
       		runningtank.frames = Paths.getSparrowAtlas('tankmanKilled1');
        	runningtank.antialiasing = true;
        	runningtank.animation.addByPrefix("run", "tankman running", 24, true);
        	runningtank.animation.addByPrefix("shot", "John Shot " + FlxG.random.int(1,2), 24, false);
        	runningtank.setGraphicSize(Std.int(0.8 * runningtank.width));
        	runningtank.updateHitbox();
        	runningtank.animation.play("run");
        	runningTankSpeed.push(0.7);
        	tankGoingRight.push(false);

			tankStrumTime.push(Character.animationNotes[0][0]);
        	endingOffset.push(FlxG.random.float(0.6, 1));
			resetRunningTank(FlxG.width * 1.5, 600, true, runningtank, 0);
			runningtanks.add(runningtank);
			remove(tankground);
			add(runningtank);

			var tanknum = 0;
			for (c in 1...Character.animationNotes.length)
			{
				if (FlxG.random.float(0, 100) < 16)
				{
                	var runningtank2:FlxSprite = runningtank.clone();
                	runningTankSpeed.push(0.7);
                	tankGoingRight.push(false);

                	tankStrumTime.push(Character.animationNotes[c][0]);
                	endingOffset.push(FlxG.random.float(0.6, 1));
                	resetRunningTank(FlxG.width * 1.5, 200 + FlxG.random.int(50, 100),  2 > Character.animationNotes[c][1], runningtank2, tanknum);
					runningtanks.add(runningtank2);
					add(runningtank2);
                	tanknum++;
				}
			}
			add(tankground);
		}

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gf-tankmen' | 'gf-tankmenvoid' | 'pico-speaker':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'bf':
				if (curStage == 'philly' && SONG.player2 == 'bf')
					camPos.x += 600;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':
				dad.y += 180;
			case 'tankmannoamongus':
				dad.y += 250;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		switch (SONG.player1)
		{
			case 'pico':
				boyfriend.y -= 50;
			case 'gf-christmas' | 'gf':
				if (SONG.song.toLowerCase() == "tutorial")
					dad.setPosition(boyfriend.x, boyfriend.y);
				boyfriend.setPosition(gf.x, gf.y);
				gf.visible = false;
			case 'monster-christmas' | 'monster':
				boyfriend.y -= 250;
				if (curStage == "mallEvil" || curStage == "spooky")
					dad.y += 350;
			case 'tankman':
				boyfriend.y -= 150;
			case 'tankmannoamongus':
				boyfriend.y -= 100;
		}

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'spooky' | "mallEvil" | "mall" | "stage":
				// nothing

			case 'philly':
				if (SONG.player2.startsWith('bf'))
				{
					dad.y += 350;
				}

			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;
			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;

			case 'tank':
				if (SONG.player2.startsWith("bf"))
				{
					dad.y += 350;
				}
				else
				{
					dad.y += 60;
				}
				dad.x -= 80;
				if (gf.curCharacter == 'pico-speaker')
				{
					gf.y -= 200;
					gf.x -= 50;
				}
				else
				{
					gf.y -= 75;
					gf.x -= 170;
				}
				boyfriend.x += 40;
		}

		// Shitty layering but whatev it works LOL

		if (PlayState.SONG.song.toLowerCase() == "tutorial" && SONG.player2 == "gf")
		{
			add(gf);
			add(dad);
			add(boyfriend);
		}
		else if (curStage != 'limo')
		{
			add(gf);
			add(boyfriend);
			add(dad);
		}

		if (curStage == 'limo')
			add(gf);
			add(limo);
			add(boyfriend);
			add(dad);

		if (curStage == 'tank')
			add(tank0);
			add(tank1);
			add(tank2);
			add(tank3);
			add(tank4);
			add(tank5);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		player2Strums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);
		var fps = Std.int(cast (Lib.current.getChildAt(0), Main).currentframerate());
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * ((30 / (fps / 60)) / fps));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		FULLhealthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		FULLhealthBar.scrollFactor.set();
		FULLhealthBar.createFilledBar(0xFFFFFF00, 0xFFFFFF00);
		FULLhealthBar.visible = false;
		add(FULLhealthBar);

		accuracyTxt = new FlxText(1150, healthBarBG.y + 45, 0, "", 20);
		accuracyTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		accuracyTxt.scrollFactor.set();
		add(accuracyTxt);

		ratingTxt = new FlxText(1235, accuracyTxt.y - 25, 0, "", 20);
		ratingTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		ratingTxt.scrollFactor.set();
		ratingTxt.visible = false;
		add(ratingTxt);


		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 300, healthBarBG.y + 45, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		healthTxt = new FlxText(healthBarBG.x + healthBarBG.width - 150, healthBarBG.y + 45, 0, "", 20);
		healthTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		healthTxt.scrollFactor.set();
		add(healthTxt);

		missesTxt = new FlxText(healthBarBG.x + healthBarBG.width - 450, healthBarBG.y + 45, 0, "", 20);
		missesTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		missesTxt.scrollFactor.set();
		add(missesTxt);

		lengthTxt = new FlxText(25, healthBarBG.y + 25, 0, "", 20);
		lengthTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		lengthTxt.scrollFactor.set();
		lengthTxt.visible = false;
		add(lengthTxt);

		
		var gftutorialicon = false;
		if (SONG.player1.startsWith("bf") || SONG.player2.startsWith("bf"))
		{
			gftutorialicon = true;
		}
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false, gftutorialicon);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		FULLhealthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		healthTxt.cameras = [camHUD];
		missesTxt.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		ratingTxt.cameras = [camHUD];
		lengthTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
				if (OG.horrorlandCutsceneEnded == false)
				{
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									OG.horrorlandCutsceneEnded = true;
									startCountdown();
								}
							});
						});
					});
				}

				case 'senpai' | 'thorns':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'tutorial' | 'bopeebo' | 'fresh' | 'dadbattle':
					if (!SONG.player1.startsWith('gf') && SONG.player1 != "bf-amogus" && !SONG.player1.startsWith('monster'))
						schoolIntro(doof);
					else
						startCountdown();
				case 'guns':
				if (OG.gunsCutsceneEnded == false)
				{
					inCutscene = true;
					#if desktop
						DiscordClient.changePresence("in Guns Cutscene", SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC);
					#end
					camHUD.visible = false;
					var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					add(black);
					black.scrollFactor.set();
					FlxG.switchState(new VideoState('assets/week7/videos/gunsCutscene.webm', function() {OG.gunsCutsceneEnded = true; FlxG.switchState(new PlayState());}));
				}
				else
				{
					startCountdown();
				}
				case 'ugh':
				if (OG.ughCutsceneEnded == false)
				{
					inCutscene = true;
					#if desktop
						DiscordClient.changePresence("in Ugh Cutscene", SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC);
					#end
					camHUD.visible = false;
					var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					add(black);
					black.scrollFactor.set();
					FlxG.switchState(new VideoState('assets/week7/videos/ughCutscene.webm', function() {OG.ughCutsceneEnded = true; FlxG.switchState(new PlayState());}));
				}
				else
				{
					startCountdown();
				}
				case 'stress':
				if (OG.stressCutsceneEnded == false)
				{
					inCutscene = true;
					#if desktop
						DiscordClient.changePresence("in Stress Cutscene", SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC);
					#end
					camHUD.visible = false;
					var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					add(black);
					black.scrollFactor.set();
					FlxG.switchState(new VideoState('assets/week7/videos/stressCutscene.webm', function() {OG.stressCutsceneEnded = true; FlxG.switchState(new PlayState());}));
				}
				else
				{
					startCountdown();
				}
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');
			if (boyfriend.color != FlxColor.WHITE)
				boyfriend.color = FlxColor.WHITE;
			if (SONG.player1.startsWith('gf'))
				boyfriend.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
					lengthTxt.visible = true;
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

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
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
							babyArrow.animation.addByPrefix('ugh', 'left ugh', 24, false);
							babyArrow.animation.addByPrefix('aaa', 'left aaa', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
							babyArrow.animation.addByPrefix('ugh', 'up ugh', 24, false);
							babyArrow.animation.addByPrefix('aaa', 'up aaa', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				player2Strums.add(babyArrow);
			}

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
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			timer.active = true;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		FlxG.updateFramerate = Std.int(cast (Lib.current.getChildAt(0), Main).currentframerate());
		#if !debug
		perfectMode = false;
		#end

		var fps = Std.int(cast (Lib.current.getChildAt(0), Main).currentframerate());
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * ((30 / (fps / 60)) / fps));

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name.startsWith('bf'))
				if (iconP1.animation.curAnim.name == 'bf-old')
					iconP1.animation.play(SONG.player1);
				else
					iconP1.animation.play('bf-old');
			else if (iconP2.animation.curAnim.name.startsWith('bf'))
				if (iconP2.animation.curAnim.name == 'bf-old')
					iconP2.animation.play(SONG.player2);
				else
					iconP2.animation.play('bf-old');

		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			case 'tank':
				moveTank();
				if (SONG.song.toLowerCase() == 'stress') {
				var updatetanknum = 0;
   				for (spr in runningtanks.members) 
				{
        			if (spr.x >= 1.2 * FlxG.width || spr.x <= -0.5 * FlxG.width)
            			spr.visible = false;
        			else
            			spr.visible = true;
        			if (spr.animation.curAnim.name == "run") 
					{
            			var cool:Float = 0.74 * FlxG.width + endingOffset[updatetanknum];
            			if (tankGoingRight[updatetanknum]) 
						{
                			cool = 0.02 * FlxG.width - endingOffset[updatetanknum];
                			spr.x = cool + (Conductor.songPosition - tankStrumTime[updatetanknum]) * runningTankSpeed[updatetanknum];
                			spr.flipX = true;
            			} 
						else 
						{
                			spr.x = cool - (Conductor.songPosition - tankStrumTime[updatetanknum]) * runningTankSpeed[updatetanknum];
                			spr.flipX = false;
            			}
        			}
        			if (Conductor.songPosition > tankStrumTime[updatetanknum]) 
					{
            			spr.animation.play("shot");
            			if (tankGoingRight[updatetanknum]) 
						{
                			spr.offset.y = 200;
                			spr.offset.x = 300;
            			}	
        			}
        			if (spr.animation.curAnim.name == "shot" && spr.animation.curAnim.curFrame >= spr.animation.curAnim.frames.length - 1) 
					{
            			spr.kill();
        			}
        			updatetanknum++;
				}
				}
		}

		super.update(elapsed);
		var min = Math.floor((FlxG.sound.music.length - Conductor.songPosition) / 60000);
		var sec = Math.floor(((FlxG.sound.music.length - Conductor.songPosition) % 60000) / 1000);
		var finalmin = '$min'.lpad("0", 2);
		var finalsec = '$sec'.lpad("0", 2);
		if (Std.parseFloat(finalsec) < 0)
			lengthTxt.visible = false;
		lengthTxt.text = Std.string(finalmin + ":" + finalsec);
		lengthTxt.size = 40;



		scoreTxt.text = "Score:" + songScore;
		if (health <= 0)
			healthTxt.text = "Health:" + healthBar.percent + "% (DEAD)";
		else
			healthTxt.text = "Health:" + healthBar.percent + "%";
		missesTxt.text = "Misses:" + misses;
		var accuracy:Float = Math.round(((goodnotes - misses) / (goodnotes + misses)) * 100);
		if (misses == 0 && goodnotes == 0 || accuracy == 100)
		{
			accuracyTxt.text = "Accuracy:100%";
			ratingTxt.text = "(FC)";
			ratingTxt.visible = true;
		}
		else if (misses < 10)
		{
			if (accuracy > 0)
				accuracyTxt.text = "Accuracy:" + accuracy + "%";
			else
				accuracyTxt.text = "Accuracy:0%";
			ratingTxt.text = "(SDCB)";
			ratingTxt.x = 1215;
			ratingTxt.visible = true;
		}
		else if (accuracy < 0)
		{
			accuracyTxt.text = "Accuracy:0%";
			ratingTxt.visible = false;
		}
		else
		{
			accuracyTxt.text = "Accuracy:" + accuracy + "%";
			ratingTxt.visible = false;
		}

		#if desktop
			if (praticemode)
				modeText = " - Practice Mode";
			else if (oneshot)
				modeText = " - One Shot Mode";
			else
				modeText = '';
		#end

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			timer.active = false;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + modeText + ")", player2RPC, player1RPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.TWO)
		{
			FlxG.switchState(new GitarooPause());
		}

		if (FlxG.keys.justPressed.U)
		{
			if (SONG.player1 == 'tankman' || SONG.player1 == 'tankmannoamongus')
			{
				boyfriend.playAnim("singUP-alt", true);
				if (SONG.player1 == 'tankman')
					FlxG.sound.play(Paths.sound('ugh'));
				else
					FlxG.sound.play(Paths.sound('aaa'));
			}
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
		{
			health = 2;
			FULLhealthBar.visible = true;
			healthBar.visible = false;
			healthTxt.color = FlxColor.YELLOW;
		}
		else if (health < 2)
		{
			FULLhealthBar.visible = false;
			healthBar.visible = true;
			healthTxt.color = FlxColor.WHITE;
		}

		if (health < 0)
			health = 0;

		if (oneshot && health > 0)
			health = 0.001;

		if (healthBar.percent < 20 && !oneshot)
		{
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 3;
			healthTxt.color = FlxColor.RED;
		}
		else if (healthBar.percent < 80 || oneshot)
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
			healthTxt.color = FlxColor.WHITE;
		
		}

		if (healthBar.percent > 80)
		{
			iconP1.animation.curAnim.curFrame = 3;
			iconP2.animation.curAnim.curFrame = 1;
			healthTxt.color = FlxColor.LIME;
		}
		else if (healthBar.percent > 20)
		{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
			healthTxt.color = FlxColor.WHITE;
		}

		if (misses == 0)
		{
			missesTxt.color = FlxColor.LIME;
		}
		else if (misses <= 5)
		{
			missesTxt.color = FlxColor.GREEN;
		}
		else if (misses <= 15)
		{
			missesTxt.color = FlxColor.CYAN;
		}
		else if (misses <= 30)
		{
			missesTxt.color = FlxColor.ORANGE;
		}
		else if (misses <= 50)
		{
			missesTxt.color = FlxColor.YELLOW;
		}
		else if (misses >= 50)
		{
			missesTxt.color = FlxColor.RED;
		}

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

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
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				// bf opponent for philly map camera fix thing yes
				if (curStage == 'philly' && dad.curCharacter == 'bf')
				{
					camFollow.x += 150;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
				}

				// pico player cam fix
				if (SONG.player1 == "pico" || SONG.player1 == "pico-pixel")
				{
					camFollow.x -= 150;
					if (curStage != 'school' && curStage != 'schoolEvil')
						camFollow.y += 80;
					else
						camFollow.y -= 50;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
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
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0 && praticemode == false)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			deathCounter += 1;

			if (SONG.player1.startsWith('tankman') || SONG.player1 == "pico" || SONG.player1.startsWith('gf') || SONG.player1.startsWith('monster'))
			{
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			var deadRPC = GameOverSubstate.daBf;

			switch (deadRPC)
			{
				case 'bf' | 'bf-amogus':
					deadRPC += '-dead';
			}
			switch (SONG.player1)
			{
				case 'pico' | 'tankman' | 'monster' | 'gf' | 'tankmannoamongus':
					deadRPC = SONG.player1 + '-dead';
				case 'monster-christmas' | 'gf-christmas':
					deadRPC = SONG.player1.replace('-christmas','') + '-dead';
			}
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + modeText + ")", deadRPC, player2RPC);
			#end
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							if (SONG.notes[Math.floor(curStep / 16)].altAnimPlayer == 0 || SONG.notes[Math.floor(curStep / 16)].altAnimPlayer == 2)
								altAnim = '-alt';
					}

					if (daNote.altNote)
					{
						altAnim = '-alt';
					}

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
					player2Strums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm');
							sustain2(spr.ID, spr, daNote);
						}

						if (daNote.altNote)
						{
							if (spr.ID == 2 && !PlayState.higheffort)
							{
								switch (SONG.song.toLowerCase())
								{
									case 'ugh':
										spr.animation.play('ugh');
									case 'gugh':
										spr.animation.play('aaa');
								}
							}
						 	if (spr.ID == 0 && PlayState.higheffort)
							{
								switch (SONG.song.toLowerCase())
								{
									case 'ugh':
										spr.animation.play('ugh');
									case 'gugh':
										spr.animation.play('aaa');
								}
							}
						}
						
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				player2Strums.forEach(function(spr:FlxSprite)
				{
					if (strumming2[spr.ID])
					{
						spr.animation.play("confirm");
					}

					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475 * losemultiplier;
						
						vocals.volume = 0;
						if (!daNote.isSustainNote)
							misses++;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
		{
			var length:Float = note.sustainLength;

			if (length > 0)
			{
				strumming2[strum] = true;
			}

			var bps:Float = Conductor.bpm / 60;
			var spb:Float = 1 / bps;

			if (!note.isSustainNote)
			{
				timer = new FlxTimer();
				timer.start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
				{
					if (!strumming2[strum])
					{
						spr.animation.play("static", true);
						spr.centerOffsets();
					}
					else
					{
						strumming2[strum] = false;
						spr.animation.play("static", true);
						spr.centerOffsets();
					}
				});
			}
		}

		if (FlxG.keys.justPressed.F11 || FlxG.keys.justPressed.F)
        {
			FlxG.save.data.fullscreen = !FlxG.fullscreen;
			FlxG.save.flush();
        	FlxG.fullscreen = !FlxG.fullscreen;
        }
	}

	function endSong():Void
	{
		lengthTxt.visible = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
				Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}
		OG.gunsCutsceneEnded = false;
		OG.ughCutsceneEnded = false;
		OG.stressCutsceneEnded = false;
		OG.horrorlandCutsceneEnded = false;

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('gumMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';
				
				if (storyDifficulty == 3)
					difficulty = '-hardplus';
				var lastCharacter:String = PlayState.SONG.player1;
				var lastOpponent:String = PlayState.SONG.player2;
				var lastStage:String = PlayState.curStage;
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);
				

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				if (!lastCharacter.startsWith("bf"))
					PlayState.SONG.player1 = lastCharacter;
				if (lastOpponent.startsWith("bf") && lastStage == "tank")
					PlayState.SONG = Song.loadFromJson("tank" + PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				if (lastOpponent.startsWith("bf") && lastStage == "philly")
					PlayState.SONG = Song.loadFromJson("play" + PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				if (lastOpponent.startsWith("bf") && lastCharacter.startsWith("monster"))
					PlayState.SONG = Song.loadFromJson("lemon" + PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			#if html5
				FlxG.sound.playMusic(Paths.music('gumMenu'));
			#end
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			goods++;
		}

		if (daRating == 'sick')
		{	
			var noteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(noteSplash);
			sicks++;
		}

		if (praticemode == false)
		{
			songScore += score;
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';
		var sussy:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		if (curStage.startsWith('amogus'))
		{
			if (daRating == 'bad' || daRating == 'shit')
				sussy = 'sus';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + sussy + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
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
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

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

		curSection += 1;
	}

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

		// FlxG.watch.addQuick('asdfa', upP);
		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);
				}
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				if (perfectMode)
					noteCheck(true, daNote);

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData])
								goodNoteHit(coolNote);
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList)
									badNoteCheck();
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							noteCheck(controlArray[coolNote.noteData], coolNote);
						}
					}
				}
				else // regular notes?
				{
					noteCheck(controlArray[daNote.noteData], daNote);
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}

					//this is already done in noteCheck / goodNoteHit
					if (daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				 */
			}
			else
			{
				badNoteCheck();
			}
		}

		if ((up || right || down || left) && !boyfriend.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 0:
							if (left)
								goodNoteHit(daNote);
						case 1:
							if (down)
								goodNoteHit(daNote);
						case 2:
							if (up)
								goodNoteHit(daNote);
						case 3:
							if (right)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss') && boyfriend.color == FlxColor.WHITE && !boyfriend.animation.curAnim.name.endsWith('alt'))
			{
				boyfriend.playAnim('idle');
				if (SONG.player1.startsWith('gf'))
					boyfriend.dance();
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 0:
					if (leftP && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'ugh' && spr.animation.curAnim.name != 'aaa')
						spr.animation.play('pressed');
					if (leftR)
						spr.animation.play('static');
				case 1:
					if (downP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (downR)
						spr.animation.play('static');
				case 2:
					if (upP && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'ugh' && spr.animation.curAnim.name != 'aaa')
						spr.animation.play('pressed');
					if (upR)
						spr.animation.play('static');
				case 3:
					if (rightP && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (rightR)
						spr.animation.play('static');
			}

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

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04 * losemultiplier;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (praticemode == false)
			{
				songScore -= 10;
			}

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			if (!boyfriend.animation.curAnim.name.startsWith('hair'))
			{
				var misstxt:String = '';
				if (boyfriend.animation.getByName('singRIGHTmiss') == null)
					boyfriend.color = 0xCFAFFF;
				else
					misstxt = 'miss';
				switch (direction)
				{
					case 0:
						boyfriend.playAnim('singLEFT' + misstxt, true);
					case 1:
						boyfriend.playAnim('singDOWN' + misstxt, true);
					case 2:
						boyfriend.playAnim('singUP' + misstxt, true);
					case 3:
						boyfriend.playAnim('singRIGHT' + misstxt, true);
				}
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
				goodnotes++;
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023 * gainmultiplier;
			else
				health += 0.004 * gainmultiplier;
			
			var altAnim:String = "";

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].altAnim)
					if (SONG.notes[Math.floor(curStep / 16)].altAnimPlayer == 0 || SONG.notes[Math.floor(curStep / 16)].altAnimPlayer == 1)
						altAnim = '-alt';
			}

			if (note.altNote)
			{
				altAnim = '-alt';
			}
			if (boyfriend.color != FlxColor.WHITE)
				boyfriend.color = FlxColor.WHITE;
			if (!boyfriend.animation.curAnim.name.startsWith('hair'))
			{
				switch (note.noteData)
				{
					case 0:
						boyfriend.playAnim('singLEFT' + altAnim, true);
					case 1:
						boyfriend.playAnim('singDOWN' + altAnim, true);
					case 2:
						boyfriend.playAnim('singUP' + altAnim, true);
					case 3:
						boyfriend.playAnim('singRIGHT' + altAnim, true);
				}
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}

				if (note.altNote)
				{
					if (spr.ID == 2 && !PlayState.higheffort)
					{
						switch (SONG.song.toLowerCase())
						{
							case 'ugh':
								spr.animation.play('ugh');
							case 'gugh':
								spr.animation.play('aaa');
						}
					}
					if (spr.ID == 0 && PlayState.higheffort)
					{
						switch (SONG.song.toLowerCase())
						{
							case 'ugh':
								spr.animation.play('ugh');
							case 'gugh':
								spr.animation.play('aaa');
						}
					}
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

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			if (SONG.player1.startsWith('gf'))
				boyfriend.playAnim('hairBlow');
				if (boyfriend.color != FlxColor.WHITE)
					boyfriend.color = FlxColor.WHITE;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		if (SONG.player1.startsWith('gf'))
			boyfriend.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		gf.playAnim('scared', true);
		if (boyfriend.curCharacter.startsWith("bf"))
			boyfriend.playAnim('scared', true);	
	}

	var tankAngle:Float = FlxG.random.int(-90, 45);

	function moveTank():Void
	{
		tankAngle += FlxG.elapsed * FlxG.random.float(5, 7);
        tank.angle = tankAngle - 90 + 15;
        tank.x = 400 + 1500 * FlxMath.fastCos(FlxAngle.asRadians(tankAngle + 180));
        tank.y = 1300 + 1100 * FlxMath.fastSin(FlxAngle.asRadians(tankAngle + 180));
	}

	function resetRunningTank(x:Float, y:Int, goingRight:Bool, spr:FlxSprite, tanknum:Int):Void
	{
    	spr.x = x;
    	spr.y = y;
    	tankGoingRight[tanknum] = goingRight;
    	endingOffset[tanknum] = FlxG.random.float(50, 200);
    	runningTankSpeed[tanknum] = FlxG.random.float(0.6, 1);
     	spr.flipX = if (goingRight) true else false;
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

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
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.animation.curAnim.name.startsWith("hair"))
		{
			boyfriend.playAnim('idle');
			if (boyfriend.color != FlxColor.WHITE)
				boyfriend.color = FlxColor.WHITE;
			if (SONG.player1.startsWith('gf'))
				boyfriend.dance();
		}
		if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
				dad.playAnim('idle');
				dad.playAnim('idle', true);
			}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			if (boyfriend.animation.getByName('hey') != null)
				boyfriend.playAnim('hey', true);

			if (boyfriend.curCharacter == "tankman")
				FlxG.sound.play(Paths.sound('ugh'));

			gf.playAnim('cheer', true);
			if (boyfriend.curCharacter == "gf")
				boyfriend.playAnim('cheer', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			if (boyfriend.curCharacter != "pico")
				boyfriend.playAnim('hey', true);

			if (boyfriend.curCharacter == "tankman")
				FlxG.sound.play(Paths.sound('ugh'));

			dad.playAnim('cheer', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'bf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('cheer', true);
			dad.playAnim('hey', true);
		}

		switch (curStage)
		{
			case 'school':


				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
