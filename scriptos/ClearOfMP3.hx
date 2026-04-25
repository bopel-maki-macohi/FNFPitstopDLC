package scriptos;

import haxe.Timer;
import haxe.io.Path;
import sys.FileSystem;

// haxe -m scriptos.ClearOfMP3 --interp
class ClearOfMP3
{
	static function readDir(dir:String):Array<String>
	{
		var files:Array<String> = [];

		for (file in FileSystem.readDirectory(dir))
		{
			final path = '$dir/$file';

			if (FileSystem.isDirectory(path))
				for (subfile in readDir(path))
					files.push(subfile);
			else
				files.push(path);
		}

		return files;
	}

	static function main()
	{
		final mp3s = readDir('assets/').filter(s -> return Path.extension(s) == 'mp3');

		Timer.measure(() ->
		{
			for (file in mp3s)
				FileSystem.deleteFile(file);
		});

		trace('Removed ${mp3s.length} mp3 files');
	}
}
