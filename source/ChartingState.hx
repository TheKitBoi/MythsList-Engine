package;

#if desktop
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIText;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.zip.Writer;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;

	public var playClaps:Bool = false;

	var UI_box:FlxUITabMenu;

	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var gridBlackLine:FlxSprite;

	var curSong:String = 'test';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var writingNotesText:FlxText;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var noteType:Int = 0;
	var noteTypeNames:Array<String> = ['default'];
	var noteTypeText:FlxText = new FlxText(5, 5, 0, '', 24);

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;

	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	private var lastNote:Note;
	var claps:Array<Note> = [];

	var colorArray:Array<Dynamic>;

	override function create()
	{
		#if desktop
			DiscordClient.changePresence("In The Charting Debug Menu", null);
		#end

		curSection = lastSection;

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				player3: 'gf',
				speed: 1,
				validScore: false
			};
		}

		colorArray = [
			MythsListEngineData.arrowLeft,
			MythsListEngineData.arrowDown,
			MythsListEngineData.arrowUp,
			MythsListEngineData.arrowRight
		];

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		menuBG.color = 0xFF606060;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.scrollFactor.set();
		menuBG.antialiasing = true;
		add(menuBG);
		menuBG.screenCenter();

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		noteTypeText.text = 'Note type: ' + noteTypeNames[noteType].toUpperCase();
		noteTypeText.scrollFactor.set();
		add(noteTypeText);

		var keybindTxt:FlxText = new FlxText(650, 425, 0,
		  'ENTER : Resume with the current changes\n'
		+ 'ESCAPE : Exit to the Main Menu\n\n'
		+ '1-4 : Place notes on left side\n'
		+ 'CTRL + 1-4 : Place notes on right side\n'
		+ 'Z-X : Change the note type\n'
		+ 'CTRL + Z : Undo\n'
		+ 'SHIFT : Remove the grid temporarily\n\n'
		+ 'MOUSE WHEEL : Scroll\n'
		+ 'W-S : Scroll slowly\n\n'
		+ 'LEFT-RIGHT : Move to the previous/next section\n'
		+ 'SHIFT + R : Reset the current section\n\n'
		+ 'SPACE : Resume/Pause the song\n\n',
		14);

		keybindTxt.scrollFactor.set();
		add(keybindTxt);

		leftIcon = new HealthIcon(PlayState.SONG.player1, false, true);
		rightIcon = new HealthIcon(PlayState.SONG.player2, false, true);

		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		if (_song.notes[curSection].mustHitSection)
		{
			leftIcon.setPosition(0, -100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
		else
		{
			rightIcon.setPosition(0, -100);
			leftIcon.setPosition(gridBG.width / 2, -100);
		}

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, '', 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Assets", label: 'Assets'},
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle:FlxUIInputText = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices:FlxUICheckBox = new FlxUICheckBox(10, 30, null, null, "Has Voice Track", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
		};

		var check_mute_inst:FlxUICheckBox = new FlxUICheckBox(10, 210, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float;

			if (check_mute_inst.checked)
				vol = 0;
			else
				vol = 1;

			FlxG.sound.music.volume = vol;
		};

		var hitsounds:FlxUICheckBox = new FlxUICheckBox(10, 180, null, null, "Play Hitsounds", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var restart = new FlxButton(10, 140, "Reset Chart", function()
        {
            for (v in 0..._song.notes.length)
            {
                 for (i in 0..._song.notes[v].sectionNotes.length)
                {
                    _song.notes[v].sectionNotes = [];
                }
             }
            resetSection(true);
        });

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel:FlxText = new FlxText(74, 80, 'Scroll Speed');

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1, 5000, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel:FlxText = new FlxText(74, 65, 'BPM');

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfversions:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));

		var player1DropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
		});

		player1DropDown.selectedLabel = _song.player1;
		var player1Label:FlxText = new FlxText(player1DropDown.x, player1DropDown.y - 20, 64, 'Player 1');

		var player2DropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(160, 40, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
		});

		player2DropDown.selectedLabel = _song.player2;
		var player2Label:FlxText = new FlxText(player2DropDown.x, player2DropDown.y - 20, 64, 'Player 2');

		var player3DropDown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, 180, FlxUIDropDownMenu.makeStrIdLabelArray(gfversions, true), function(gfversion:String)
		{
			_song.player3 = gfversions[Std.parseInt(gfversion)];
		});
	
		player3DropDown.selectedLabel = _song.player3;
		var player3Label:FlxText = new FlxText(player3DropDown.x, player3DropDown.y - 20, 64, 'Player 3');

		var tab_group_song:FlxUI = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(hitsounds);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(restart);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);

		var tab_group_assets:FlxUI = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";

		tab_group_assets.add(player3DropDown);
		tab_group_assets.add(player3Label);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player2Label);

		UI_box.addGroup(tab_group_song);
		UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section:FlxUI = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy Last", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			var sectionNotes:Array<Dynamic> = _song.notes[curSection].sectionNotes;

			for (i in 0...sectionNotes.length)
			{
				var note = sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must Hit Section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 350, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var tab_group_note:FlxUI;

	function addNoteUI():Void
	{
		tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		writingNotesText = new FlxUIText(20, 100, 0, "");
		writingNotesText.setFormat('Arial', 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps * 4);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var stepperSusLengthLabel:FlxText = new FlxText(10, 10, 'Note Sustain Length');
		var applyLength:FlxButton = new FlxButton(10, 350, 'Apply Data');

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(stepperSusLengthLabel);
		tab_group_note.add(applyLength);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		var note:SwagSection = _song.notes[curSection];

		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;

			switch(label.toLowerCase())
			{
				case 'must hit section':
				{
					note.mustHitSection = check.checked;
					updateHeads();
				}
				case 'change bpm':
				{
					note.changeBPM = check.checked;
					FlxG.log.add('changed bpm');
				}
				case "alt animation":
				{
					note.altAnim = check.checked;
				}
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;

			FlxG.log.add(wname);

			switch(wname)
			{
				case 'section_length':
				{
					if (nums.value < 4)
						nums.value = 4;

					note.lengthInSteps = Std.int(nums.value);
					updateGrid();
				}
				case 'song_speed':
				{
					if (nums.value < 0)
						nums.value = 0;
					else if (nums.value > 8)
						nums.value = 8;

					_song.speed = nums.value;
				}
				case 'song_bpm':
				{
					if (nums.value < 1)
						nums.value = 1;

					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));
				}
				case 'note_susLength':
				{
					if (curSelectedNote == null)
						return;
	
					if (nums.value < 0)
						nums.value = 0;

					curSelectedNote[2] = nums.value;
					updateGrid();
				}
				case 'section_bpm':
				{
					if (nums.value < 1)
						nums.value = 1;

					note.bpm = Std.int(nums.value);
					updateGrid();
				}
			}
		}
	}

	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}	

	function sectionStartTime():Float
	{
		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;

		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}

		return daPos;
	}

	var writingNotes:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.time > FlxG.sound.music.length)
		{
			FlxG.sound.music.time = FlxG.sound.music.length;
			vocals.time = FlxG.sound.music.time;
		}

		if (curBeat < 0)
		{
			FlxG.sound.music.time = 0;
			vocals.time = FlxG.sound.music.time;
		}

		curStep = recalculateSteps();

		if (FlxG.keys.justPressed.ALT && UI_box.selected_tab == 0)
			writingNotes = !writingNotes;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		var pressArray:Array<Bool> = [
			FlxG.keys.justPressed.ONE,
			FlxG.keys.justPressed.TWO,
			FlxG.keys.justPressed.THREE,
			FlxG.keys.justPressed.FOUR,
		];

		for (p in 0...pressArray.length)
		{
			var daValue:Int = (FlxG.keys.pressed.CONTROL ? 4 : 0);

			if (pressArray[p])
				addNote(new Note(Conductor.songPosition, p + daValue, null, false, noteType));
		}

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		if (playClaps)
		{
			curRenderedNotes.forEach(function(note:Note)
			{
				if (note.strumTime <= Conductor.songPosition && !claps.contains(note) && FlxG.sound.music.playing)
				{
					claps.push(note);
					FlxG.sound.play(Paths.sound('hitsound', 'shared'), 0.8);
				}
			});
		}

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			if (_song.notes[curSection + 1] == null)
				addSection();

			changeSection(curSection + 1, false);
		}
		else if (strumLine.y < -10)
		{
			if (_song.notes[curSection - 1] == null)
			{
				FlxG.sound.music.time = 0;
				vocals.time = FlxG.sound.music.time;
			}
	
			changeSection(curSection - 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
							selectNote(note);
						else
							deleteNote(note);
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x && FlxG.mouse.x < gridBG.x + gridBG.width && FlxG.mouse.y > gridBG.y && FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;

			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.play(Paths.sound('confirmMenu', 'preload'));

			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			LoadingState.loadAndSwitchState(new PlayState(), true);
		}

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new MainMenuState());

		if (FlxG.keys.justPressed.E)
			changeNoteSustain(Conductor.stepCrochet);
		else if (FlxG.keys.justPressed.Q)
			changeNoteSustain(-Conductor.stepCrochet);

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab --;

				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab ++;

				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.Z && lastNote != null)
				{
					if (curRenderedNotes.members.contains(lastNote))
						deleteNote(lastNote);
					else 
						addNote(lastNote);
				}
			}

			var shiftThing:Int = (FlxG.keys.pressed.SHIFT ? 4 : 1);

			if (!FlxG.keys.pressed.CONTROL)
			{
				if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
					changeSection(curSection + shiftThing);

				if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
					changeSection(curSection - shiftThing);
			}	

			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
					vocals.time = FlxG.sound.music.time;
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				var daTime:Float = (!FlxG.keys.pressed.SHIFT ? 700 * FlxG.elapsed : Conductor.stepCrochet * 2);

				FlxG.sound.music.time -= (FlxG.keys.pressed.W ? daTime : -daTime);

				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.CONTROL && (FlxG.keys.justPressed.Z || FlxG.keys.justPressed.X))
			{
				this.noteType += (FlxG.keys.justPressed.Z ? -1 : 1);

				if (noteType < 0)
					noteType = noteTypeNames.length - 1;
				else if (noteType >= noteTypeNames.length)
					noteType = 0;

				noteTypeText.text = 'Note type: ' + noteTypeNames[noteType].toUpperCase();
			}
		}

		_song.bpm = tempBpm;

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\n\nSection: "
			+ curSection 
			+ "\n\ncurStep: " 
			+ curStep
			+ "\ncurBeat: " 
			+ curBeat;
			
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);
			var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];

			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.setPosition(0, -100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
		else
		{
			leftIcon.setPosition(gridBG.width / 2, -100);
			rightIcon.setPosition(0, -100);
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		remove(gridBG);
        gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * _song.notes[curSection].lengthInSteps);
        add(gridBG);

		remove(gridBlackLine);
		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			var daBPM:Int = _song.bpm;

			for (i in 0...curSection)
			{
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			}

			Conductor.changeBPM(daBPM);
		}

		for (sec in 0..._song.notes.length)
		{
			for (notesse in 0..._song.notes[sec].sectionNotes.length)
			{
				if (_song.notes[sec].sectionNotes[notesse][2] == null)
					_song.notes[sec].sectionNotes[notesse][2] = 0;
			}
		}

		for (i in sectionInfo)
		{
			var daStrumTime = i[0];
			var daNoteInfo = i[1];
			var daSus = i[2];
			var daType:Int = i[3];

			var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, false, daType);

			if (MythsListEngineData.arrowColors && daType == 0)
				note.color = FlxColor.fromRGB(colorArray[daNoteInfo % 4][0], colorArray[daNoteInfo % 4][1], colorArray[daNoteInfo % 4][2]);

			note.sustainLength = daSus;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			if (curSelectedNote != null && curSelectedNote[0] == note.strumTime)
				lastNote = note;

			curRenderedNotes.add(note);

			var defaultColors:Array<Dynamic> = [
				[194, 75, 153],
				[0, 255, 255],
				[18, 250, 5],
				[247, 57, 63]
			];

			var customColors:Array<Dynamic> = [
				MythsListEngineData.arrowLeft,
				MythsListEngineData.arrowDown,
				MythsListEngineData.arrowUp,
				MythsListEngineData.arrowRight
			];

			var colorSusArray:Array<Dynamic> = (MythsListEngineData.arrowColors ? customColors : defaultColors);

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2), note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * _song.notes[curSection].lengthInSteps, 0, gridBG.height)));
				sustainVis.x -= sustainVis.width / 2;
				sustainVis.color = FlxColor.fromRGB(colorSusArray[daNoteInfo % 4][0], colorSusArray[daNoteInfo % 4][1], colorSusArray[daNoteInfo % 4][2]);

				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % 4 == note.noteData)
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];

			swagNum ++;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		lastNote = note;

		for (i in _song.notes[curSection].sectionNotes)
		{
			var value:Bool = (note.x < gridBG.x + (GRID_SIZE * 4) ? true : false);

			if (i[0] == note.strumTime && i[1] == note.noteData + (value ? 0 : 4))
			{
				_song.notes[curSection].sectionNotes.remove(i);
				break;
			}
		}
		
		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote(?daNote:Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var daNoteType = noteType;

		var note = _song.notes[curSection];

		if (daNote != null)
			note.sectionNotes.push([daNote.strumTime, daNote.noteData, daNote.sustainLength, daNote.noteType]);
		else
			note.sectionNotes.push([noteStrum, noteData, noteSus, daNoteType]);

		curSelectedNote = note.sectionNotes[note.sectionNotes.length - 1];

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		var difficulty:String = CoolUtil.difficultyArray[PlayState.storyDifficulty][1];

		// since you can't write those, a space will do
		var newSong:String = StringTools.replace(song.toLowerCase(), ' ', '-');

		PlayState.SONG = Song.loadFromJson(newSong.toLowerCase() + difficulty, newSong.toLowerCase());
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		LoadingState.loadAndSwitchState(new ChartingState());
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + CoolUtil.difficultyArray[PlayState.storyDifficulty][1] + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}