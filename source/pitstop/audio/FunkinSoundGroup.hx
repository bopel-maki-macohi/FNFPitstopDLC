package pitstop.audio;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;

class FunkinSoundGroup extends FlxSoundGroup
{
	public function play(ForceRestart:Bool = false, StartTime:Float = 0.0, ?EndTime:Float)
	{
		for (sound in sounds)
			sound.play(ForceRestart, StartTime, EndTime);
	}

	public function stop()
	{
		for (sound in sounds)
			sound.stop();
	}

	override function add(sound:FlxSound):Bool
	{
		if (!FlxG.sound.list.members.contains(sound))
			FlxG.sound.list.add(sound);

		if (onComplete != null)
			sound.onComplete = onComplete;

		return super.add(sound);
	}

	public var onComplete(default, set):Void->Void;

	function set_onComplete(onComplete:Void->Void):Void->Void
	{
		for (sound in sounds)
			sound.onComplete = onComplete;

		return onComplete;
	}

	public var time(get, set):Float;

	function get_time():Float
	{
		return sounds[0]?.time ?? 0;
	}

	function set_time(time:Float):Float
	{
		for (sound in sounds)
			sound.time = time;

		return time;
	}
}
