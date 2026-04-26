package pitstop.play.songs;

import flixel.tweens.FlxEase;
import flixel.FlxG;
import flixel.tweens.FlxTween;

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

	override function cameraMovement(bfSide:Bool)
	{
		super.cameraMovement(bfSide);

		if (!bfSide)
			PlayState.instance.tweenCamIn();
		else
			FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}
}
