package;

import lime.utils.Assets;
import animate.FlxAnimateFrames;
import animate.FlxAnimate;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;

using StringTools;

class Character extends FlxAnimate
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var animationNotes:Array<Dynamic> = [];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		switch (curCharacter)
		{
			case 'gf':
				loadTextures([Paths.getSparrowAtlas('characters/GF_assets'),]);

				quickAnimAdd('cheer', 'GF Cheer');
				quickAnimAdd('singLEFT', 'GF left note');
				quickAnimAdd('singRIGHT', 'GF Right Note');
				quickAnimAdd('singUP', 'GF Up Note');
				quickAnimAdd('singDOWN', 'GF Down Note');

				quickIndicesAnimAdd('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);

				quickIndicesAnimAdd('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]);
				quickIndicesAnimAdd('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29]);

				quickIndicesAnimAdd('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3]);
				quickIndicesAnimAdd('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]);

				quickAnimAddLooped('scared', 'GF FEAR');

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'dad':
				loadTextures([Paths.getSparrowAtlas('characters/DADDY_DEAREST'),]);

				quickAnimAdd('idle', 'Dad idle dance');
				quickAnimAdd('singUP', 'Dad Sing Note UP');
				quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');
				quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
				quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				dadVar = 6.1;

			case 'bf':
				loadTextures([Paths.getSparrowAtlas('characters/BOYFRIEND'),]);

				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singUP', 'BF NOTE UP0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('hey', 'BF HEY!!');

				quickAnimAdd('firstDeath', "BF dies");
				quickAnimAddLooped('deathLoop', "BF Dead Loop");
				quickAnimAdd('deathConfirm', "BF Dead confirm");

				quickAnimAddLooped('scared', "BF idle shaking");

				loadOffsetFile(curCharacter);
				loadOffsetFile('bf-dead');

				playAnim('idle');

			case 'gf-park':
				loadTextures([Paths.getAnimateAtlas('characters/gf-park'),]);

				quickFrameLabelAnimAdd('danceLeft', 'danceLeft');
				quickFrameLabelAnimAdd('danceRight', 'danceRight');

				playAnim('danceRight');

				loadOffsetFile(curCharacter);

			case 'bf-park':
				loadTextures([
					Paths.getSparrowAtlas('characters/bf-park'),
					Paths.getSparrowAtlas('characters/BOYFRIEND'),
				]);

				quickAnimAdd('idle', 'bf anim idle');

				quickAnimAdd('singLEFT', 'bf anim left');
				quickAnimAdd('singDOWN', 'bf anim down');
				quickAnimAdd('singUP', 'bf anim up');
				quickAnimAdd('singRIGHT', 'bf anim right');

				quickAnimAdd('singLEFTmiss', 'bf anim miss left');
				quickAnimAdd('singDOWNmiss', 'bf anim miss down');
				quickAnimAdd('singUPmiss', 'bf anim miss up');
				quickAnimAdd('singRIGHTmiss', 'bf anim miss right');

				quickAnimAdd('firstDeath', "BF dies");
				quickAnimAddLooped('deathLoop', "BF Dead Loop");
				quickAnimAdd('deathConfirm', "BF Dead confirm");

				loadOffsetFile(curCharacter);
				loadOffsetFile('bf-dead');

				playAnim('idle');
		}

		dance();
		anim.finish();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!flippedHorizSingAnimChars.contains(curCharacter))
			{
				// var animArray
				var oldRight = anim.getByName('singRIGHT').frames;
				anim.getByName('singRIGHT').frames = anim.getByName('singLEFT').frames;
				anim.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (anim.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = anim.getByName('singRIGHTmiss').frames;
					anim.getByName('singRIGHTmiss').frames = anim.getByName('singLEFTmiss').frames;
					anim.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	var flippedHorizSingAnimChars:Array<String> = ['bf', 'bf-park'];

	public var startedDeath:Bool = false;

	public var dadVar:Float = 4;

	public var isHolding:Bool = false;

	override function update(elapsed:Float)
	{
		if (isPlayer)
		{
			if (anim.name.startsWith('sing'))
				holdTimer += elapsed;
			else
				holdTimer = 0;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				if (!isHolding && anim?.curAnim?.name.startsWith('sing') && !anim?.curAnim?.name.endsWith('miss'))
					dance();

			if (anim.name.endsWith('miss') && anim.finished && !debugMode)
				playAnim('idle', true, false, 10);

			if (anim.name == 'firstDeath' && anim.finished && startedDeath)
				playAnim('deathLoop');
		}
		else
		{
			if (anim?.name?.startsWith('sing'))
				holdTimer += elapsed;

			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (anim.name == 'hairFall' && anim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	public var danceIdleChars:Array<String> = ['gf', 'gf-park'];

	public function dance()
	{
		if (debugMode)
			return;

		if (danceIdleChars.contains(curCharacter))
		{
			if (curCharacter == 'gf' && anim.name.startsWith('hair'))
				return;

			danced = !danced;

			if (danced)
				playAnim('danceRight');
			else
				playAnim('danceLeft');
		}
		else
			playAnim('idle');
	}

	function loadTextures(textures:Array<FlxAtlasFrames>)
		frames = FlxAnimateFrames.combineAtlas(textures);

	private function loadOffsetFile(offsetCharacter:String)
	{
		var offsetFile:String = Paths.file("images/characters/" + offsetCharacter + "Offsets.txt", TEXT, 'shared');

		if (!Assets.exists(offsetFile))
			return;

		var daFile:Array<String> = CoolUtil.coolTextFile(offsetFile);

		for (i in daFile)
		{
			var splitWords:Array<String> = i.split(" ");
			addOffset(splitWords[0], Std.parseInt(splitWords[1]), Std.parseInt(splitWords[2]));
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		anim.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0], daOffset[1]);
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
			else if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
		animOffsets[name] = [x, y];

	function quickAnimAdd(name:String, prefix:String)
		anim.addByPrefix(name, prefix, 24, false);

	function quickAnimAddLooped(name:String, prefix:String)
		anim.addByPrefix(name, prefix, 24, true);

	function quickIndicesAnimAdd(name:String, prefix:String, indices:Array<Int>)
		anim.addByIndices(name, prefix, indices, '', 24, false);

	function quickFrameLabelAnimAdd(name:String, prefix:String)
		anim.addByFrameLabel(name, prefix, 24, false);
}
