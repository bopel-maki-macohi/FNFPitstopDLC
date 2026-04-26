package pitstop.play.score;

class Score
{
	public static function grade(noteDiff:Float):RatingClass
	{
		if (noteDiff > Conductor.safeZoneOffset * 0.9)
			return Rating.SHIT;
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
			return Rating.BAD;
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
			return Rating.GOOD;

		return Rating.SICK;
	}
}
