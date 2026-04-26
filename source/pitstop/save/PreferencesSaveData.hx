package pitstop.save;

import flixel.FlxG;

typedef PreferencesSaveData =
{
	?censor_naughty:Bool,
	?downscroll:Bool,
	?flashing_menu:Bool,
	?camera_zoom:Bool,
	?fps_counter:Bool,
	?memory_counter:Bool,
	?auto_pause:Bool,
}

class PreferencesSaveField
{
	public static var saveField(get, set):PreferencesSaveData;

	static function get_saveField():PreferencesSaveData
	{
		if (FlxG.save.isBound)
			return FlxG.save.data.preferences;

		return null;
	}

	static function set_saveField(newPrefs:PreferencesSaveData):PreferencesSaveData
	{
		if (FlxG.save.isBound)
		{
			return FlxG.save.data.preferences = newPrefs;
		}

		return null;
	}

	public static function formatToTypedefVal(field:String)
	{
		return StringTools.replace(field, '-', '_');
	}

	public static function getField(key:String):Dynamic
	{
		if (saveField == null)
			saveField = {};

		return Reflect.field(saveField, formatToTypedefVal(key));
	}

	public static function setField(key:String, value:Dynamic)
	{
		if (saveField == null)
			saveField = {};

		Reflect.setField(saveField, formatToTypedefVal(key), value);
	}
}
