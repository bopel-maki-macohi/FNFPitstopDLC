package pitstop.options;

import flixel.text.FlxText;
import pitstop.save.PreferencesSaveData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import pitstop.options.AtlasText.AtlasFont;
import pitstop.options.TextMenuList.TextMenuItem;

class PreferencesMenu extends pitstop.options.OptionsState.Page
{
	public static var preferences:Map<String, Dynamic> = new Map();

	var items:TextMenuList;

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var camFollow:FlxObject;

	public var textBox:FlxSprite;
	public var textText:FlxText;

	public function new(experimental:Bool = false)
	{
		super();

		menuCamera = new SwagCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());

		curPrefs = [];
		for (pref in allPrefs)
			if (experimental && experimentalPrefs.contains(pref) || !experimental && !experimentalPrefs.contains(pref))
			{
				curPrefs.push(pref);
				createPrefItem(pref, prefsOptionMap.get(pref), preferences.get(prefsOptionMap.get(pref)));
			}
		// trace(curPrefs);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
			camFollow.y = items.selectedItem.y;

		menuCamera.follow(camFollow, null, 0.06);
		var margin = 160;
		menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
		menuCamera.minScrollY = 0;

		items.onChange.add(function(selected)
		{
			camFollow.y = selected.y;
		});

		textBox = new FlxSprite().makeGraphic(FlxG.width, Math.round(FlxG.height * .15), FlxColor.BLACK);
		add(textBox);

		textBox.alpha = .4;

		textText = new FlxText(0, 0, FlxG.width, '', 16);
		textText.alignment = CENTER;
		add(textText);

		textBox.scrollFactor.set();
		textText.scrollFactor.set();

		textBox.cameras = textText.cameras = [menuCamera];
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);

		items.forEach(function(daItem:TextMenuItem)
		{
			if (items.selectedItem == daItem)
				daItem.x = 150;
			else
				daItem.x = 120;
		});

		textText.text = prefsOptionDescMap.get(curPrefs[this.items.selectedIndex]) ?? 'N / A';

		textBox.screenCenter();
		textBox.y = FlxG.height * .8;

		textText.y = textBox.getGraphicMidpoint().y - (textText.height / 2);
	}

	public static function getPref(pref:String):Dynamic
	{
		return preferences.get(pref);
	}

	// easy shorthand?
	public static function setPref(pref:String, value:Dynamic):Void
	{
		preferences.set(pref, value);
	}

	public static var allPrefs:Array<String> = [];
	public var curPrefs:Array<String> = [];
	public static var regularPrefs:Array<String> = [];
	public static var experimentalPrefs:Array<String> = [];

	static var prefsOptionMap:Map<String, Dynamic> = [];
	static var prefsOptionDescMap:Map<String, Dynamic> = [];
	static var prefsValMap:Map<String, Dynamic> = [];

	// for array prefs but thats l8r
	static var prefsValuesMap:Map<String, Array<Dynamic>> = [];

	public static function makePref(preferenceClass:Preference)
	{
		allPrefs.push(preferenceClass.display);

		if (preferenceClass.experimental)
			experimentalPrefs.push(preferenceClass.display);
		else
			regularPrefs.push(preferenceClass.display);

		prefsOptionMap.set(preferenceClass.display, preferenceClass.id);
		prefsOptionDescMap.set(preferenceClass.display, preferenceClass.description);
		prefsValMap.set(preferenceClass.id, preferenceClass.defaultValue);
	}

	public static function initPrefs():Void
	{
		makePref(new Preference('censor-naughty', 'Naughtyness', true).setDescription('Toggles naughty naughty things ;)'));
		makePref(new Preference('downscroll', 'Downscroll',
			false).setDescription('Toggles the gameplay arrows being down and the arrows coming in from the top instead of the other way around.'));

		makePref(new Preference('flashing-menu', 'Flashing Menu BG', true).setDescription('Toggles the Menu BG flashing when you select something.'));

		makePref(new Preference('camera-zoom', 'Camera Zooming on Beat', false).setDescription('Toggles the Camera bopping on beat in gameplay.'));

		makePref(new Preference('debug-display', 'Debug Display (DD)', false).setDescription('Toggle the Debug Display.'));
		makePref(new Preference('fps-counter', 'DD FPS Counter', true).setDescription('Toggle the Debug Display FPS Counter.'));
		makePref(new Preference('memory-counter', 'DD Memory Counter', true).setDescription('Toggle the Debug Display Memory Counter.'));

		makePref(new Preference('auto-pause', 'Auto Pause',
			true).setDescription('Toggles Flixel pausing the game when you lose focus after already having it.'));

		makePref(new Preference('ghost-tapping', 'Ghost Tapping (GT)',
			false).setExperimental().setDescription('Toggles allowing you to press notes when theres no note there and not get penaltized.'));
		makePref(new Preference('ghost-tapping-penalty', 'GT Note Press Penalty',
			false).setExperimental()
			.setDescription('Toggles the Ghost Tapping Note Press penalty.\n\nThe combo won\'t reset and it\'s half the regular penalty.'));

		for (key => value in prefsValMap)
			preferenceCheck(key, value);

		FlxG.autoPause = getPref('auto-pause');
	}

	private function createPrefItem(prefName:String, prefString:String, prefValue:Dynamic):Void
	{
		items.createItem(120, (120 * items.length) + 30, prefName, AtlasFont.Bold, function()
		{
			preferenceCheck(prefString, prefValue);

			switch (Type.typeof(prefValue).getName())
			{
				case 'TBool':
					prefToggle(prefString);
			}

			PreferencesSaveField.setField(prefString, preferences.get(prefString));
		});

		switch (Type.typeof(prefValue).getName())
		{
			case 'TBool':
				createCheckbox(prefString);
		}

		#if debug
		trace('$prefString : ' + Type.typeof(prefValue).getName());
		#end
	}

	function createCheckbox(prefString:String)
	{
		var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(prefString));
		checkboxes.push(checkbox);
		add(checkbox);
	}

	/**
	 * Assumes that the preference has already been checked/set?
	 */
	private function prefToggle(prefName:String)
	{
		var daSwap:Bool = preferences.get(prefName);
		daSwap = !daSwap;

		preferences.set(prefName, daSwap);

		checkboxes[items.selectedIndex].daValue = daSwap;
		trace('toggled? ' + preferences.get(prefName));

		switch (prefName)
		{
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
		}
	}

	private static function preferenceCheck(prefString:String, ?defaultValue:Dynamic):Void
	{
		if (preferences.get(prefString) == null)
		{
			if (PreferencesSaveField.getField(prefString) == null)
			{
				trace('set $prefString to default value: $defaultValue!');

				preferences.set(prefString, defaultValue);
				PreferencesSaveField.setField(prefString, defaultValue);
			}
			else
			{
				preferences.set(prefString, PreferencesSaveField.getField(prefString));
				trace('set $prefString to save value: ${preferences.get(prefString)}!');
			}
		}
		else
		{
			trace('found preference: ' + preferences.get(prefString));
		}
	}
}

class CheckboxThingie extends FlxSprite
{
	public var daValue(default, set):Bool;

	public function new(x:Float, y:Float, daValue:Bool = false)
	{
		super(x, y);

		frames = Paths.getSparrowAtlas('checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);

		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();

		this.daValue = daValue;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		switch (animation.curAnim.name)
		{
			case 'static':
				offset.set();
			case 'checked':
				offset.set(17, 70);
		}
	}

	function set_daValue(value:Bool):Bool
	{
		if (value)
			animation.play('checked', true);
		else
			animation.play('static');

		return value;
	}
}
