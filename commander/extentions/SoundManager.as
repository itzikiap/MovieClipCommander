/*
*This file is part of MovieClipCommander Framework.
*
*   MovieClipCommander Framework  is free software; you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation; either version 2 of the License, or
*    (at your option) any later version.
*
*    MovieClipCommander Framework is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with MovieClipCommander Framework; if not, write to the Free Software
*    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/
import hd.structures.SoundDef;
import hd.structures.SoundsDef;
import iap.app.extentions.sequences.SequenceManager;
import iap.app.extentions.sequences.SequenceStep;
import iap.commander.extentions.Loader;
import iap.commander.extentions.Matrix;
import iap.commander.extentions.SoundItem;
import iap.commander.MovieClipCommander;
import iap.time.FrameDelay;

/**
* Sounds manager  extention for MovieClipCommander
* This extention enables you to load and manage playing of multiple sounds at ones or one at a time or by a defined sequence
* You can load a swf with all the sounds as linkages, or use the linbkages in the main SWF.
* It creates a movieclip for each sound item played (and delete it in the end) to have a specific control on each sound volume and pan
*
* main commands:
* 	loadSoundsSWF - to load a swf with all the sounds embeded with linkages
*	playSound - to play a sound with linkage. can be together with other sounds, or can stop all othe sounds.
* events:
* 	EVT_LOAD_COMPLETE - when the loading of the sounds SWF is completed
*	EVT_SOUND_ITEM_STOP - when the sound item stoped playing
*
* @author IAP itzik Arzoni (itzik.mcc@gmail.com)
* @version 1
*/
class iap.commander.extentions.SoundManager extends iap.services.MovieClipService {
	/**
	* soundLoadComplete - dispatches when the loading of a SWF file is complete
	*/
	static var EVT_LOAD_COMPLETE:String = "soundsLoadComplete";
	/**
	* soundItemStop - dispatches when a sound item stoped playing.
	* extra Info:
	* 	{[B]name[/B]: the name of the sound, [B]item[/B]: a refference to the sound item
	* 	[B]isSequence[/B]: is the sound part of a sequence
	*/
	static var EVT_SOUND_ITEM_STOP:String = "soundItemStop";
	/**
	* soundItemStart - dispatches when a sound item starts playing
	* extra Info:
	* 	{[B]name[/B]:the name of the sound, [B]item[/B]:a refference to the sound item}
	*/
	static var EVT_SOUND_ITEM_START:String = "soundItemStart";
	/**
	* soundSequenceStop - dispatches when a sequence of sounds stops playing
	*/
	static var EVT_SOUND_SEQUENCE_STOP:String = "soundSequenceStop";
		
	static var EVT_SOUND_ITEM_LOAD_COMPLETE:String = "soundItemLoadComplete";
	
	private var __sounds:Matrix;
	private var __loader:Loader;
	private var __sequential:Boolean;
	private var __sequence:SequenceManager;
	private var __sequencesCount:Number;
	private var __enabled:Boolean;
	private var __externalSounds:Object;
		
	function init(defaultVolume:Number, defaultPan:Number)	{
		__commander._params.getCreateParam("defaultVolume", (defaultVolume==undefined)?100:defaultVolume);
		__commander._params.getCreateParam("defaultPan", (defaultPan==undefined)?0:defaultPan);
		__sounds = Matrix(__commander.uniqueExtention("soundsMatrix", Matrix));
		__sounds.cellsTemplate("soundItem", "", undefined, true);
		__sounds.defineMatrix(1,50,0,0,0,0);
		__sounds.extentionsTemplate({sound:SoundItem});
		__sounds._autoDestroy = true;
		__sounds._autoMove = false;
		
		__sequence = SequenceManager(__commander.uniqueExtention("sequence", SequenceManager));
		__sequencesCount = 0;
		__commander.addEventListener(Matrix.EVT_MATRIX_CELL_ITERATION, this);
		__commander.addEventListener(SequenceManager.EVT_SEQUENCE_DONE, this);
		__enabled = true;
	}
	
	/**
	* get a sounds XML and parses it,
	* then loads all the MP# files from the file
	* @param	data	the xml definition
	*/
	function parseSoundsXml(data:XMLNode) {
		var soundsDef:SoundsDef = new SoundsDef(data);
		setVolume(soundsDef._globalVolume);
		setPan(soundsDef._globalPan);
		
		var count:Number = 0;
		for (var name:String in soundsDef._sounds)
			count++
		
		_commander._params.setParam("soundsTotal", count);
		_commander._params.setParam("soundsLoaded", 0);
		
		loadMP3list(soundsDef._sounds);
		
	}
	
	/**
	* loads a SWF containing all your sounds as embeded linkages
	* @param	fileName	the neame of the SWF
	*/
	function loadSoundsSWF(fileName:String) {
		__loader = Loader(__commander.uniqueExtention("loader", Loader))
		__loader.loadClip(fileName);
		__commander.addEventListener(Loader.EVT_LOAD_COMPLETE, this);
	}
	
	/**
	* loadSound - loads one sound from the list of MP3 sounds
	* @param	name	name of sound object (not in use right now)
	* @param	def		definition of the sound object
	*/
	private function loadSound(name:String, def:SoundDef) {
		
		var obj:Object = {permanent:true, sound_name:name};
		if (def._volume != undefined) {
			obj.volume = def._volume;
		}
		if (def._pan != undefined) {
			obj.pan = def._pan;
		}
		var mcc:MovieClipCommander = __sounds.createNextCell(obj);
		mcc.addEventListener(SoundItem.EVT_SOUND_LOAD_DONE, this);
		var item:SoundItem = mcc._commands.sound;
		item.loadSound(def._fileName);
		__externalSounds[def._name] = mcc;
	}
	
	/**
	* loads a list of MP3 files
	* @param	mp3Dic	dictionary of sound object definitions to load
	*/
	function loadMP3list(mp3Dic:Object) {
		
		__externalSounds = new Object();
		__sequence.defineSequence("soundsLoad");
		for (var o:String in mp3Dic) {
			__sequence.addStep(__name, "loadSound", [o, mp3Dic[o]], EVT_SOUND_ITEM_LOAD_COMPLETE);
		}
		__sequence.saveSequence();
		__sequence.run("soundsLoad");
	}

	/**
	* plays a sound.
	* @param	id	the linkage of the sound in the library
	* @param 	loops how many times to repeat playing the sound
	* @param 	volume	the volume of the sound
	* @param 	pan	the pan of the sound
	*/
	function playSound(id:String, loops:Number, volume:Number, pan:Number):SoundItem {
		
		
		volume = (volume == undefined)? __commander._params.getNumber("defaultVolume"): volume;
		if (!__enabled) {
			// if not enabled, it is better to keep playing the sound because maybe there are some
			// things that depends on it
			volume = 0;
		}
		pan = (pan == undefined)? __commander._params.getNumber("defaultPan"): pan;
		if (__sequential) {
			this.stopAllSounds();
		}

		var cell:MovieClipCommander;
		if (__externalSounds[id] == undefined) {
			cell = __sounds.createNextCell( { volume:volume, pan:pan, permanent:false, sound_name:id } );
			cell.addEventListener(SoundItem.EVT_STOP, this);
			var snd:SoundItem = cell._commands.sound;
			snd.attachAndPlaySound(id, loops, volume, pan);
		} else {
			cell = __externalSounds[id];
			
			cell.addEventListener(SoundItem.EVT_STOP, this);
			var snd:SoundItem = cell._commands.sound;
			
			//snd.setVolume(volume);
			//
			//snd.setPan(pan);
			snd.attachAndPlaySound(id, loops, volume, pan);
		}
		dispatchEvent(EVT_SOUND_ITEM_START, {name:id, item:cell._commands.sound});
		__commander._params.setParam("lastPlaying", cell._commands.sound);
		return cell._commands.sound;
	}
	
	/**
	* plays a sequence of sounds one after another
	* @param	soundsArr	an array of linkages
	*/
	public function playSequentialSounds(soundsArr:Array) {
		
		//_sequential = true;
		if (_sequential) {
			this.stopAllSounds();
		}
		__sequence.defineSequence("soundSequence"+(++__sequencesCount));
		for (var i:Number = 0; i<soundsArr.length; i++) {
			__sequence.addSequenceStep(new SequenceStep(_name, "playSound", [soundsArr[i]], EVT_SOUND_ITEM_STOP));
			__sequence.addStep("sequence", "delay", [1], SequenceManager.EVT_DELAY);
		}
		__sequence.saveSequence();
		__sequence.run("soundSequence"+__sequencesCount);
	}
	
	/**
	* stop playing all the sounds
	*/
	public function stopAllSounds() {
		
		__sounds.iterate({command:"destroy"});
	}
	
	/**
	* sets the global volyume
	* effect all playing sounds
	*/
	public function setVolume(val:Number) {

		__commander._params.setParam("defaultVolume", val);
		__sounds.iterate({command: "setVolume", value:val});
	}
	
	/**
	* sets global pan
	* effects all playing sounds
	*/
	public function setPan(val:Number) {
		__commander._params.setParam("defaultPan", val);
		__sounds.iterate({command: "setPan", value:val});
	}
	
	function dispatchSequenceStopEvent() {
		dispatchEvent(EVT_SOUND_SEQUENCE_STOP);
	}

	/**
	* handleEvent method
	*/
	private function handleEvent(evt:Object) {
		switch (evt.type) {
			case SequenceManager.EVT_SEQUENCE_DONE:
				if (evt.sequenceName == "soundsLoad") {
					dispatchEvent(EVT_LOAD_COMPLETE);
				} else {
					FrameDelay.create(this, dispatchSequenceStopEvent, [], true);
				}
				break;
			case SoundItem.EVT_SOUND_LOAD_DONE:
			
				_commander._params.setParam("soundsLoaded", _commander._params.getNumber("soundsLoaded") + 1);
				dispatchEvent(EVT_SOUND_ITEM_LOAD_COMPLETE);
				break;
			case Loader.EVT_LOAD_COMPLETE:
				dispatchEvent(EVT_LOAD_COMPLETE);
				break;
			case SoundItem.EVT_STOP:
				if (!evt.commander._params.getBool("permanent")){
					__sounds.removeFromMatrix(evt.commander._params.getNumber("index"));
				}
				dispatchEvent(EVT_SOUND_ITEM_STOP, {name:evt.commander._params.getString("sound_name"), isSequence:__sequence._isRunning});
				break;
			case Matrix.EVT_MATRIX_CELL_ITERATION:
				switch (evt.command) {
					case "destroy":
						var sound:SoundItem = evt.cell._commands.sound
						sound.stop();
						if (!evt.cell._params.getBool("permanent")){
							__sounds.removeFromMatrix(evt.index);
						}
						break;
					case "setVolume":
						evt.cell._params.setParam("volume", evt.value);
						break;
					case "setPan":
						evt.cell._params.setParam("pan", evt.value);
						break;
				}
				break;
		}
	}
	
	public function set _sequential(val:Boolean) {
		__sequential = val;
		if (val) {
			this.stopAllSounds();
		}
	}
	
	public function set _enabled(val:Boolean) {
		if (val != __enabled) {
			__enabled = val;
			if (!val)
				setVolume(0);
				//this.stopAllSounds();
			else
				setVolume(45);
		}
	}
	
	public function get _enabled():Boolean {
		return __enabled;
	}
	
}
