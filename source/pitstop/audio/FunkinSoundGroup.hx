package pitstop.audio;

import flixel.sound.FlxSoundGroup;

class FunkinSoundGroup extends FlxSoundGroup
{
    public function play(ForceRestart:Bool = false, StartTime:Float = 0.0, ?EndTime:Float)
    {
        for (sound in sounds)
            sound.play(ForceRestart, StartTime, EndTime);
    }
}