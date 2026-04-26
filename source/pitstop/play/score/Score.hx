package pitstop.play.score;

class Score
{
	public static final GOOD_THRESHOLD:Float = 0.2;

	public static final BAD_THRESHOLD:Float = 0.75;

	public static final SHIT_THRESHOLD:Float = 0.9;

	public static function grade(noteDiff:Float):RatingClass
	{
		if (noteDiff >= Conductor.safeZoneOffset * SHIT_THRESHOLD)
			return Rating.SHIT;
		else if (noteDiff >= Conductor.safeZoneOffset * BAD_THRESHOLD)
			return Rating.BAD;
		else if (noteDiff >= Conductor.safeZoneOffset * GOOD_THRESHOLD)
			return Rating.GOOD;

		return Rating.SICK;
	}
}
