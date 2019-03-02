import iap.app.extentions.sequences.SequenceManager;
import iap.commander.extentions.Matrix;
import iap.commander.extentions.SoundItem;
import iap.commander.MovieClipCommander;

class iap.commander.extentions.SoundsMP3Loader extends iap.services.MovieClipService {
	static var EVT_SOUND_ITEM_LOAD_COMPLETE:String = "MP3soundItemLoadComplete";
	
	static var EVT_LOAD_COMPLETE:String = "MP3LoadComplete";
	
	private var __sounds:Matrix;
	private var __sequence:SequenceManager;
	private var __loadedSounds:Object;
	
	function init()	{
		__sounds = Matrix(__commander.registerExtention("sounds", Matrix));
		__sounds.cellsTemplate("sound", "");
		__sounds.defineMatrix(40, 40, 0,0,0,0);
		__sounds.extentionsTemplate({sound:SoundItem});
		__sounds._autoMove = false;
		__sequence = SequenceManager(__commander.registerExtention("sequence", SequenceManager));
	}
	
	public function loadSoundsList(soundsListDef:Object) {
		__sequence.defineSequence("soundsLoad");
		for (var o:String in soundsListDef) {
			__sequence.addStep(__name, loadSounds, [o, soundsListDef[o]], EVT_SOUND_ITEM_LOAD_COMPLETE);
		}
		
	}
	
	private function loadSound(name:String, file:String) {
		var mcc:MovieClipCommander = __sounds.createNextCell();
		mcc.addEventListener(SoundItem.EVT_SOUND_LOAD_DONE, this);
		var item:SoundItem = mcc._commands.sound;
		item.loadSound(file);
		__loadedSounds[name] = item;
	}
	
	/**
	* handles the events comming from dispatchers all over the world
	* @param	evt	the event data
	*/
	private function handleEvent(evt:Object) {
		// trace("HandleEvent: "+this+" of type: "+evt.type+", from: "+evt.target+".);
		switch (evt.type) {
			case SoundItem.EVT_SOUND_LOAD_DONE:
				dispatchEvent(EVT_SOUND_ITEM_LOAD_COMPLETE);
				break;
			case SequenceManager.EVT_SEQUENCE_DONE:
				dispatchEvent(EVT_LOAD_COMPLETE, {sounds:__sounds});
		}
	}
}
