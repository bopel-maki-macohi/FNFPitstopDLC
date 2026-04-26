package;

import lime.utils.Assets;
import Song.SwagSong;
import flixel.FlxG;

class Highscore
{
	public static var songScores:Map<String, Float> = [];

	public static function saveScore(song:String, score:Float = 0, ?diff:Int = 0):Void
	{
		var formattedSong:String = formatSong(song, diff);

		if (songScores.exists(formattedSong))
		{
			if (songScores.get(formattedSong) < score)
				setScore(formattedSong, score);
		}
		else
			setScore(formattedSong, score);
	}

	public static function saveWeekScore(week:String, score:Float = 0, ?diff:Int = 0):Void
	{
		var formattedSong:String = formatSong(week, diff);

		if (songScores.exists(formattedSong))
		{
			if (songScores.get(formattedSong) < score)
				setScore(formattedSong, score);
		}
		else
			setScore(formattedSong, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(formattedSong:String, score:Float):Void
	{
		/** GeoKureli
		 * References to Highscore were wrapped in `#if !switch` blocks. I wasn't sure if this
		 * is because switch doesn't use NGio, or because switch has a different saving method.
		 * I moved the compiler flag here, rather than using it everywhere else.
		 */
		#if !switch
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(formattedSong, score);
		FlxG.save.data.songScores = songScores;
		#end
	}

	public static function formatSong(song:String, diff:Int):String
	{
		var daSong:String = song;

		// Difficulty Array Diff
		var dad = CoolUtil.difficultyArray[diff]?.toUpperCase() ?? 'NORMAL';

		if (dad != 'NORMAL')
			daSong += '-${dad.toLowerCase()}';

		return daSong;
	}

	public static function calcSongDifficulties(song:String)
	{
		var difficulties = [];

		song = song.toLowerCase();

		for (i => diff in CoolUtil.difficultyArray)
			if (Assets.exists(Paths.chart(song, formatSong(song, i))))
				difficulties.push(i);

		return difficulties;
	}

	public static function difficultiesStrArray(song:String)
	{
		var diffs = [];

		for (d in Highscore.calcSongDifficulties(song))
			diffs.push(CoolUtil.difficultyArray[d]);

		return diffs;
	}

	public static function getScore(song:String, diff:Int):Float
	{
		if (!songScores.exists(formatSong(song, diff)))
			setScore(formatSong(song, diff), 0);

		return songScores.get(formatSong(song, diff)) ?? 0;
	}

	public static function getWeekScore(week:String, diff:Int):Float
	{
		if (!songScores.exists(formatSong(week, diff)))
			setScore(formatSong(week, diff), 0);

		return songScores.get(formatSong(week, diff)) ?? 0;
	}

	public static function load():Void
	{
		if (FlxG.save.data.songScores != null)
		{
			songScores = FlxG.save.data.songScores;
		}
	}
}
