package pitstop.audio;

import flixel.sound.FlxSound;
import lime.utils.Assets;
import flixel.sound.FlxSoundGroup;

class VoicesGroup extends FlxSoundGroup
{
	public function new(song:String, difficulty:Int)
	{
		super();

		final bfVocalPath:String = Paths.voices(song, difficulty, 'bf');
		final dadVocalPath:String = Paths.voices(song, difficulty, 'dad');
		final regularVocalPath:String = Paths.voices(song, difficulty, '');

		final bfVocalsExists:Bool = Assets.exists(bfVocalPath);
		final dadVocalsExists:Bool = Assets.exists(dadVocalPath);
		final regularVocalsExists:Bool = Assets.exists(regularVocalPath);

		if (bfVocalsExists)
			add(new FlxSound().loadEmbedded(bfVocalPath));
		if (dadVocalsExists)
			add(new FlxSound().loadEmbedded(dadVocalPath));
        
		if (regularVocalsExists)
			add(new FlxSound().loadEmbedded(regularVocalPath));
	}
}
