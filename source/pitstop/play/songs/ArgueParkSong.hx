package pitstop.play.songs;

class ArgueParkSong extends SongClass
{
	override function make()
	{
		super.make();

		PlayState.instance.useDefaultCameraStuffs = false;

		PlayState.instance.camPos.x = PlayState.instance.gf.getGraphicMidpoint().x;
		PlayState.instance.camPos.y = PlayState.instance.gf.getGraphicMidpoint().y - 45;
	}
}
