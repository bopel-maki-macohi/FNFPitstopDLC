package pitstop.play.notes;

import pitstop.shaders.ColorSwap;
import flixel.FlxSprite;

class NoteStatic extends FlxSprite
{
	override public function new(i:Int, ?ny:Float = 0)
	{
		super(0, ny);
		
		this.ID = i;

		frames = Paths.getSparrowAtlas('NOTE_assets');

		setGraphicSize(Std.int(width * 0.7));

		x += Note.swagWidth * Math.abs(i);

		switch (Math.abs(i))
		{
			case 0:
				animation.addByPrefix('static', 'arrow static instance 1');
				animation.addByPrefix('pressed', 'left press instance', 24, false);
				animation.addByPrefix('confirm', 'left confirm instance', 24, false);
			case 1:
				animation.addByPrefix('static', 'arrow static instance 2');
				animation.addByPrefix('pressed', 'down press instance', 24, false);
				animation.addByPrefix('confirm', 'down confirm instance', 24, false);
			case 2:
				animation.addByPrefix('static', 'arrow static instance 4');
				animation.addByPrefix('pressed', 'up press instance', 24, false);
				animation.addByPrefix('confirm', 'up confirm instance', 24, false);
			case 3:
				animation.addByPrefix('static', 'arrow static instance 3');
				animation.addByPrefix('pressed', 'right press instance', 24, false);
				animation.addByPrefix('confirm', 'right confirm instance', 24, false);
		}

		updateHitbox();
		scrollFactor.set();
	}
}
