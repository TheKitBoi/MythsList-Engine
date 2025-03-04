package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var stunned:Bool = false;

	// Just some settings
	var colorPrefix:String = '0xFF';
	public var healthBarColor:String;
	
	public var hasTrail:Bool = false;
	public var hasDanceAnimations:Bool = false; // For shitass characters that can't have a damn idle
	var flipAnimations:Bool = true;
	var isMenuChar:Bool = false;

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?isMenuChar:Bool = false)
	{
		super(x, y);

		this.isPlayer = isPlayer;
		this.isMenuChar = isMenuChar;

		animOffsets = new Map<String, Array<Dynamic>>();

		curCharacter = character;
		antialiasing = (!isMenuChar ? MythsListEngineData.antiAliasing : MythsListEngineData.menuAntialiasing);
		healthBarColor = colorPrefix + '';

		switch(curCharacter)
		{
			case 'gf':
				healthBarColor = colorPrefix + 'A5004D';
				hasDanceAnimations = true;

				frames = Paths.getSparrowAtlas('characters/GF_assets', 'shared');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');

			case 'gf-christmas':
				healthBarColor = colorPrefix + 'A5004D';
				hasDanceAnimations = true;

				frames = Paths.getSparrowAtlas('christmas/gfChristmas', 'week5');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				playAnim('danceRight');

			case 'gf-car':
				healthBarColor = colorPrefix + 'A5004D';
				hasDanceAnimations = true;

				frames = Paths.getSparrowAtlas('gfCar', 'week4');
				
				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');

			case 'gf-pixel':
				healthBarColor = colorPrefix + 'A5004D';
				hasDanceAnimations = true;

				frames = Paths.getSparrowAtlas('weeb/gfPixel', 'week6');
				
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				antialiasing = false;

			case 'dad':
				healthBarColor = colorPrefix + 'AF66CE';

				frames = Paths.getSparrowAtlas('DADDY_DEAREST', 'week1');
				
				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				playAnim('idle');

			case 'spooky':
				healthBarColor = colorPrefix + 'D57E00';
				hasDanceAnimations = true;

				frames = Paths.getSparrowAtlas('spooky_kids_assets', 'week2');
				
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				playAnim('danceRight');

			case 'mom':
				healthBarColor = colorPrefix + 'D8558E';

				frames = Paths.getSparrowAtlas('Mom_Assets', 'week4');
				
				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

			case 'mom-car':
				healthBarColor = colorPrefix + 'D8558E';

				frames = Paths.getSparrowAtlas('momCar', 'week4');
				
				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				playAnim('idle');

			case 'monster':
				healthBarColor = colorPrefix + 'F3FF6E';

				frames = Paths.getSparrowAtlas('NewMonster_Assets', 'week2');
				
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');

			case 'monster-christmas':
				healthBarColor = colorPrefix + 'F3FF6E';

				frames = Paths.getSparrowAtlas('christmas/monsterChristmas', 'week5');
				
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				playAnim('idle');

			case 'pico':
				healthBarColor = colorPrefix + 'B7D855';

				var animationName:Array<String>;

				if (isPlayer)
					animationName = ['Pico NOTE LEFT0', 'Pico NOTE LEFT miss', 'Pico Note Right0', 'Pico Note Right Miss'];
				else
					animationName = ['Pico Note Right0', 'Pico Note Right Miss', 'Pico NOTE LEFT0', 'Pico NOTE LEFT miss'];

				frames = Paths.getSparrowAtlas('Pico_FNF_assetss', 'week3');
				
				animation.addByPrefix('idle', 'Pico Idle Dance', 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singLEFT', animationName[0], 24, false);
				animation.addByPrefix('singRIGHT', animationName[2], 24, false);
				animation.addByPrefix('singLEFTmiss', animationName[1], 24, false);
				animation.addByPrefix('singRIGHTmiss', animationName[3], 24, false);
				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				playAnim('idle');

				flipX = true;

			case 'bf':
				healthBarColor = colorPrefix + '31B0D1';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

			case 'bf-christmas':
				healthBarColor = colorPrefix + '31B0D1';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('christmas/bfChristmas', 'week5');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				playAnim('idle');

				flipX = true;

			case 'bf-car':
				healthBarColor = colorPrefix + '31B0D1';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('bfCar', 'week4');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				playAnim('idle');

				flipX = true;

			case 'bf-minus':
				healthBarColor = colorPrefix + '31B0D1';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('characters/BOYFRIEND_MINUS', 'shared');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

			case 'bf-old':
				healthBarColor = colorPrefix + 'E9FF48';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('characters/BOYFRIEND_OLD', 'shared');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

			case 'bf-veryold':
				healthBarColor = colorPrefix + '5FB6F1';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('characters/BOYFRIEND_VERYOLD', 'shared');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				playAnim('idle');

				flipX = true;

			case 'bf-corrupted':
				healthBarColor = colorPrefix + '31B0D1';
	
				flipAnimations = false;
	
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND_CORRUPTED', 'shared');
				
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
	
				playAnim('idle');
	
				flipX = true;

			case 'bf-pixel':
				healthBarColor = colorPrefix + '7BD6F6';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('weeb/bfPixel', 'week6');

				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;

				antialiasing = false;

				flipX = true;

			case 'bf-pixel-dead':
				healthBarColor = colorPrefix + '7BD6F6';

				flipAnimations = false;

				frames = Paths.getSparrowAtlas('weeb/bfPixelsDEAD', 'week6');

				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				playAnim('firstDeath');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

				flipX = true;

			case 'senpai':
				healthBarColor = colorPrefix + 'FFAA6F';

				frames = Paths.getSparrowAtlas('weeb/senpai', 'week6');

				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'senpai-angry':
				healthBarColor = colorPrefix + 'FFAA6F';

				frames = Paths.getSparrowAtlas('weeb/senpai', 'week6');

				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'spirit':
				healthBarColor = colorPrefix + 'FF3C6E';
				hasTrail = true;

				frames = Paths.getPackerAtlas('weeb/spirit', 'week6');

				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				healthBarColor = colorPrefix + 'C55CAA';

				frames = Paths.getSparrowAtlas('christmas/mom_dad_christmas_assets', 'week5');

				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);
				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				playAnim('idle');

			case 'brody-foxx':
				healthBarColor = colorPrefix + 'FFA8C8';

				flipAnimations = false;
	
				frames = Paths.getSparrowAtlas('characters/brody-foxx', 'shared');
				
				animation.addByPrefix('idle', 'BrodyIdle', 24, false);
				animation.addByPrefix('singUP', 'brodyup', 24, false);
				animation.addByPrefix('singRIGHT', 'BrodyLeft', 24, false);
				animation.addByPrefix('singDOWN', 'YO', 24, false);
				animation.addByPrefix('singLEFT', 'BrodyRight', 24, false);
				animation.addByPrefix('singUPmiss', 'brodyup', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BrodyRight', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BrodyLeft', 24, false);
				animation.addByPrefix('singDOWNmiss', 'YO', 24, false);
	
				playAnim('idle');
			
			case 'template':
				healthBarColor = colorPrefix + 'A1A1A1';

				flipAnimations = false;
		
				frames = Paths.getSparrowAtlas('characters/template', 'shared');
				
				animation.addByPrefix('idle', 'Pico Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'pico Up note', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note', 24, false);
				animation.addByPrefix('singLEFT', 'Pico Note Right', 24, false);
				animation.addByPrefix('singUPmiss', 'pico Up note', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico Note Right', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note', 24, false);

				// This character doesn't want to be resized so i keep that here
				if (isMenuChar)
				{
					setGraphicSize(Std.int(width * 0.5));
					updateHitbox();
				}
		
				playAnim('idle');

				flipX = true;

			case 'rhys':
				healthBarColor = colorPrefix + '7C6E89';
	
				frames = Paths.getSparrowAtlas('characters/rhys', 'shared');
				
				animation.addByPrefix('idle', 'rhys idle', 24, false);
				animation.addByPrefix('singUP', 'rhys up', 24, false);
				animation.addByPrefix('singRIGHT', 'rhys right', 24, false);
				animation.addByPrefix('singDOWN', 'rhys down', 24, false);
				animation.addByPrefix('singLEFT', 'rhys left', 24, false);
				animation.addByPrefix('singUPmiss', 'rhys up', 24, false);
				animation.addByPrefix('singLEFTmiss', 'rhys left', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'rhys right', 24, false);
				animation.addByPrefix('singDOWNmiss', 'rhys down', 24, false);
	
				playAnim('idle');

			case 'mythslist':
				healthBarColor = colorPrefix + '29211F';
		
				frames = Paths.getSparrowAtlas('characters/lowbudget', 'shared');
					
				animation.addByPrefix('idle', 'idle', 24, false);
				animation.addByPrefix('singUP', 'up', 2, false);
				animation.addByPrefix('singRIGHT', 'right', 2, false);
				animation.addByPrefix('singDOWN', 'down', 2, false);
				animation.addByPrefix('singLEFT', 'left', 2, false);
		
				playAnim('idle');
		}

		if (isMenuChar)
		{
			setGraphicSize(Std.int(width * 0.5));
			updateHitbox();
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			if (flipAnimations)
			{
				var rightFrames = (animation.getByName('singRIGHT') != null ? animation.getByName('singRIGHT').frames : null);
				var leftFrames = (animation.getByName('singLEFT') != null ? animation.getByName('singLEFT').frames : null);
				var rightMissFrames = (animation.getByName('singRIGHTmiss') != null ? animation.getByName('singRIGHTmiss').frames : null);
				var leftMissFrames = (animation.getByName('singLEFTmiss') != null ? animation.getByName('singLEFTmiss').frames : null);

				if (leftFrames != null) animation.getByName('singRIGHT').frames = leftFrames;
				if (rightFrames != null) animation.getByName('singLEFT').frames = rightFrames;
				if (leftMissFrames != null) animation.getByName('singRIGHTmiss').frames = leftMissFrames;
				if (rightMissFrames != null) animation.getByName('singLEFTmiss').frames = rightMissFrames;
			}
		}

		loadOffsetFile(curCharacter);
	}

	public function loadOffsetFile(character:String, library:String = 'shared')
	{
		var offsetFile = Paths.offsets(character + 'Offsets', library);
	
		if (offsetFile != null)
		{
			for (i in 0...offsetFile.length)
			{
				var data:Array<String> = offsetFile[i].split(' ');

				if (animation.getByName(data[0]) != null)
				{
					if (data[1] == null) data[1] = '0';
					if (data[2] == null) data[2] = '0';

					var curX:Int = Std.parseInt(data[1]);
					var curY:Int = Std.parseInt(data[2]);
					var curMultiplier:Float = (!isMenuChar ? 1 : 0.5);

					if (isPlayer && flipAnimations)
						addOffset(data[0], -(curX * curMultiplier), curY * curMultiplier);
					else
						addOffset(data[0], curX * curMultiplier, curY * curMultiplier);
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			var daVar:Float = (curCharacter == 'dad' ? 6.1 : 4);

			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * 0.001 * daVar)
			{
				dance();
				holdTimer = 0;
			}
		}

		super.update(elapsed);
	}

	public var danced:Bool = false;

	public function dance()
	{
		if (!debugMode)
		{
			if (hasDanceAnimations)
			{
				if (animOffsets.exists('danceRight') && animOffsets.exists('danceLeft'))
				{
					danced = !danced;
					playAnim((danced ? 'danceRight' : 'danceLeft'));
				}
			}
			else
			{
				if (animOffsets.exists('idle'))
					playAnim('idle');
			}
		}
	}

	public function playAnim(animName:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void
	{
		animation.play(animName, force, reversed, frame);

		var daOffset = animOffsets.get(animName);

		if (animOffsets.exists(animName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (hasDanceAnimations)
		{
			switch(animName)
			{
				case 'singLEFT':
					danced = true;
				case 'singRIGHT':
					danced = false;
				case 'singUP' | 'singDOWN':
					danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}