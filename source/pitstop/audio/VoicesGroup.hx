package pitstop.audio;

import flixel.sound.FlxSound;
import lime.utils.Assets;

class VoicesGroup extends FunkinSoundGroup
{
	public var bfVocals:FlxSound;
	public var dadVocals:FlxSound;

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
			add(bfVocals = new FlxSound().loadEmbedded(bfVocalPath));
		if (dadVocalsExists)
			add(dadVocals = new FlxSound().loadEmbedded(dadVocalPath));

		if (regularVocalsExists && !bfVocalsExists)
		{
			add(bfVocals = new FlxSound().loadEmbedded(regularVocalPath));
		}

		if (bfVocals == null)
			bfVocals = new FlxSound();
		if (dadVocals == null)
			dadVocals = new FlxSound();
	}
}
