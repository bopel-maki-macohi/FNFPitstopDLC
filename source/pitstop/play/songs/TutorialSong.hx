package pitstop.play.songs;

class TutorialSong extends SongClass
{
	override function onBeatHit(beat:Int)
	{
		super.onBeatHit(beat);

		if (beat % 16 == 15 && beat > 16 && beat < 48)
		{
			PlayState.instance.boyfriend.playAnim('hey', true);
			PlayState.instance.dad.playAnim('cheer', true);
		}
	}
}
