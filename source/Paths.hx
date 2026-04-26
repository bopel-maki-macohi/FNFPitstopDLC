package;

import animate.FlxAnimateFrames;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function chart(song:String, formattedSong:String)
	{
		return 'assets/data/${song.toLowerCase()}/${formattedSong.toLowerCase()}.json';
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	static public function songFile(file:String, song:String, ?difficulty:Int = 1)
	{
		var songSuffix = '';

		// if (difficulty > 2) songSuffix = '-erect';

		return 'songs:assets/songs/${song.toLowerCase()}$songSuffix/$file.$SOUND_EXT';
	}

	inline static public function voices(song:String, ?difficulty:Int = 1, ?suffix:String = '')
	{
		return songFile('Voices$suffix', song, difficulty);
	}

	inline static public function inst(song:String, ?difficulty:Int = 1, ?suffix:String = '')
	{
		return songFile('Inst$suffix', song, difficulty);
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function frag(key:String)
	{
		return 'assets/shaders/$key.frag';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	public static function animateAtlas(path:String, ?library:String = 'shared'):String
	{
		return getLibraryPath('images/$path', library);
	}

	inline static public function getAnimateAtlas(key:String, ?library:String = 'shared')
	{
		var graphicKey:String = Paths.animateAtlas(key, library);

		// Validate asset path.
		if (!Assets.exists('${graphicKey}/Animation.json'))
			throw 'No Animation.json file exists at the specified path (${graphicKey})';

		return FlxAnimateFrames.fromAnimate(graphicKey);
	}
}
