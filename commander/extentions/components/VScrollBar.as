import flash.geom.Rectangle;
import iap.commander.extentions.Button;
import iap.commander.extentions.Drag;
import iap.structures.ScrollBounds;
	
class iap.commander.extentions.components.VScrollBar extends iap.services.MovieClipService {
	/**
	* VScrollBarChanged - disptaches when the scrollbar value is changed
	* extra info: {[B]value[/B]: scroll bar value}
	*/
	static var EVT_CHANGED:String = "VScrollBarChanged";
	
	
	static var PRM_VALUE:String = "VScrollbarValue";
	
	private var __bounds:ScrollBounds;
	private var __bar:Button;
	private var __up:Button;
	private var __down:Button;
	
	function init() {
		__bounds = new ScrollBounds(0, __clip._height, 0, 0);
		__bar =  Button(Button.create(__clip["barBtn"] , "button", Button));
		__up =   Button(Button.create(__clip["upBtn"]  , "button", Button));
		__down = Button(Button.create(__clip["downBtn"], "button", Button));
		 __bar._commander.addEventListener(Button.EVT_CLICK, this);
		  __up._commander.addEventListener(Button.EVT_CLICK, this);
		__down._commander.addEventListener(Button.EVT_CLICK, this);
		var drag:Drag = Drag(__bar._commander.registerExtention("drag", Drag, [true]));
		drag._updateAfterEvent = true;
		drag._commander.addEventListener(Drag.EVT_DRAG, this);
		setBarPosition();
		__commander.addEventListener("paramChange", this);
	}
	
	function createScroll(min:Number, max:Number, extent:Number) {
		__commander._params.setParam(PRM_VALUE, 0);
		__bounds.setVBounds(min, max);
		__bounds._extent = __bounds.getTranslatedValue(extent);
	}
	
	function invalidate(min:Number, max:Number, extent:Number) {
		createScroll(min, max, extent)
		setBarPosition();
	}
	
	private function setBarPosition() {
		__bar._commander._clip._y = __bounds._value;
		__bar._commander._clip._height = __bounds._extent;
		var drag:Drag = __bar._commander._commands.drag;
		drag._limits = new Rectangle(0,0,0,__clip._height-__bar._commander._clip._height);
	}
	
	function setValueByPos(pos:Number) {
		__bounds._value = pos;
		//trace( "setValueByPos > pos : " + [pos,  int(__bounds._value), int(__bounds._vBounds._value)] );
		__commander._params.setParam(PRM_VALUE, __bounds._vBounds._value);
	}
	
	function setPosByValue(val:Number) {
		//trace( "setPosByValue > val : " + val );
		__bounds._value = __bounds.getTranslatedValue(val);
		__bar._commander._clip._y = __bounds._value;
		__commander._params.setParam(PRM_VALUE, __bounds._vBounds._value);
	}
	
	function paramChange(evt:Object) {
		//trace( "paramChange > evt : " + evt );
		switch (evt.name) {
			case PRM_VALUE:
				dispatchEvent(EVT_CHANGED, {value:__bounds._vBounds._value});
				break;
		}
	}
	
	/**
	* handles the events comming from dispatchers all over the world
	* @param	evt	the event data
	*/
	private function handleEvent(evt:Object) {
		 //trace("HandleEvent: "+this+" of type: "+evt.type+", from: "+evt.target+".");
		switch (evt.type) {
			case Drag.EVT_DRAG:
				setValueByPos(evt.clip._y);
				break;
		}
	}
	
	public function set _visible(flag:Boolean) {
		__clip._visible = flag;
	}
}
