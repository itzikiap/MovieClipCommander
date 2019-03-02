
class iap.commander.extentions.animation.CoreParamProxy extends iap.services.MovieClipService {
	function init(toEnable:Boolean)	{
		enable(toEnable == true);
	}
	
	public function enable(flag:Boolean) {
		if (flag != false) {
			__commander.addEventListener("paramChange", this);
		} else {
			__commander.removeEventListener("paramChange", this);
		}
	}
	
	private function paramChange(evt:Object) {
		if (evt.name.indexOf("_") == 0) {
			__clip[evt.name] = evt.value;
		}
	}
}
