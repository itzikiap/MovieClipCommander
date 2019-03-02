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
 import flash.geom.Rectangle;
import iap.commander.extentions.Align;
import iap.commander.extentions.Button;
import iap.commander.extentions.Drag;
import iap.commander.extentions.Draw;
import iap.commander.MovieClipCommander;

/**
* Bar component part of slide bar component extention for movie clip commander
* 
* This component is incompleted and needs to be refactored
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.components.Bar extends iap.services.MovieClipService{
	
	/**
	* "barChanged - 
	* extra info:
	*  {[B]value[/B]: the bar value}
	*/
	
	static var EVT_BAR_CHANGED:String = "barChanged";
	
	private var __barTics:Number;
	private var __ticWidth:Number;
	private var __limit:Number;
	private var __snapTics:Number;
	private var __rullerHeight:Number;
	private var __barSkin:MovieClipCommander;

	
	public function init(ticWidth:Number,barTics:Number,totalTics:Number){
		__barTics = barTics;
		__ticWidth = ticWidth;
		__rullerHeight = __clip._parent._height;
		__snapTics = 1;
		createBar();
		var drag:Drag = Drag(__commander.registerExtention("drag",Drag));
		drag._dragOnClick = true;
		_limit = totalTics;
		__commander.addEventListener(Drag.EVT_STOP_DRAG,this)
		__commander.addEventListener(Drag.EVT_START_DRAG,this)
		__commander.addEventListener(Drag.EVT_DRAG,this)
		 __commander.registerExtention("draw",Draw);
	}

	private function createBar(){
		var draw:Draw = __commander._commands.draw;
		draw.clear();
		if (__barSkin == undefined) {
			draw._fillColor= 0x47F2C3;
			draw.rect(0,0,(__ticWidth*__barTics),__rullerHeight);
		}
	}
	
	public function skinBar(linkage:String){
		var tmpHeight:Number = __clip._height;
		__barSkin = MovieClipCommander( __commander.createChild("skin",7,linkage));
		var btn:Button = Button(__barSkin.registerExtention("button",Button))
//		btn.registerAffectedClip("skin");
		resizeBar();
	}
	
	public function resizeBar() {
		__barSkin._core.size(__ticWidth*__barTics,__rullerHeight);
		createBar();
	}
	
	public function skinBarIcon(linkage:String){
		var mcc:MovieClipCommander = MovieClipCommander( __commander.createChild("skinIcon",12,linkage));
		mcc.registerExtention("align",Align, [true, __barSkin])
		mcc._commands.align.center()
	}
	

	
	private function setBarPosition(n:Number){
		// snapping 
		var snapDown:Number = n - (n % __snapTics);
		var snapUp:Number = n + (__snapTics - (n % __snapTics));
		var ticSnap:Number;
		if (n > __limit-__barTics){
			ticSnap = __limit-__barTics;
		}else if(snapDown < 0){
			ticSnap = 0;
		}else{
			ticSnap = (n-snapDown > snapUp - n)?(snapUp):(snapDown);
		}
		__clip._x = ticSnap * __ticWidth; 
	}

		/**
	* moves the bar from a _x value it gets
	* @param	xPos
	*/
	public function moveBar(xPos:Number){
		var newVal:Number = getValueFromPosition(xPos);
		newVal -= __barTics / 2;
		this._value = newVal;
	}
	
	/**
	* returns the tic value from a specified X position
	* @param	xPos
	*/
	private function getValueFromPosition(xPos:Number):Number{
			return Math.round((xPos)/__ticWidth);
	}
	/**
	* calls to setBarPosition if snap is not false
	* and dispatches the EVT_BAR_CHANGE event
	* @param	value the new tic value
	* @param	snap if set to false - does not snap the bar position 
	*/
	private function updateValue(value:Number,snap:Boolean){
		if(snap!=false){
			setBarPosition(value);
		}
		dispatchEvent(EVT_BAR_CHANGED,{value:_value})
	}
	
	public function getPositionFromValue(value:Number):Number {
		return (value*__ticWidth);
	}
	
	public function hide() {
		__clip._visible = false;
	}
	
	public function show() {
		__clip._visible = true;
	}
	
	
	private function handleEvent(evt:Object){
		var val:Number = _value;
		switch (evt.type) {
			case Drag.EVT_STOP_DRAG:
				updateValue(val,true);
				break;
			case Drag.EVT_DRAG:
				updateValue(val,false);	
				break;
		}
	}
	/**
	* gets the tics value of the _x position OF THE BAR OK 
	* @return
	*/
	public function get _value():Number{
	 return getValueFromPosition(__clip._x)
	}
	
	/**
	* set the value of the bar and sets the bar _x position 
	* @param	value
	*/
	public function set _value(value:Number){
		updateValue(value, !__commander._commands.drag._dragging);
	}
	
	
	public function set _limit(value:Number) {
		__limit = value;
		if (_value > (__limit-__barTics)){
			updateValue(__limit-__barTics);
		}
		__commander._commands.drag._limits = new Rectangle(0,0,(__limit-__barTics)*__ticWidth, 0);
	}
	
	public function get _limit():Number {
		return __limit;
	}
	
	public function set _snapTics(value:Number){
		__snapTics = value
	}
	
	public function get _snapTics():Number {
		return __snapTics;
	}
	
	/**
	* returns the tics of the bar 
	*/
	public function get _length():Number {
		return __barTics;
	}
	
	public function set _ticWidth(val:Number) {
		__ticWidth = val;
		resizeBar();
		_limit = __limit;
		setBarPosition(_value);
	}
	
	public function get _ticWidth():Number {
		return __ticWidth;
	}
}








