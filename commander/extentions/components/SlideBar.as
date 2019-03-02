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
 import iap.commander.extentions.components.Bar;
import iap.commander.extentions.components.Ruller;
import iap.commander.extentions.Draw;
import iap.commander.MovieClipCommander;

/**
* Slide bar component extention for movieclip commander
* 
* This component is incompleted and needs to be refactored
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.components.SlideBar extends iap.services.MovieClipService{
	/**
	* slideChanged, dispatches when the value is changed
	* extra info [B]value:[/B](evt.value) - tic of the bar left location
	*/
	static var EVT_SLIDE_CHANGED:String = "slideChanged";
	/**
	* slideUnusable, ispatches when the slidebar maximum value is smaller then the bar length
	*/
	static var EVT_SLIDE_UNUSABLE:String = "slideUnusable";
	/**
	* slideUnusable, ispatches when the slidebar maximum value is bigger then the bar length
	*/
	static var EVT_SLIDE_USABLE:String = "slideUsable";
	private var __bar:Bar;
	private var __ruller:Ruller;
	private var __hotSpot:MovieClipCommander;
	private var __lastValue:Number;
	private var __rullerOffset:Number;
	private var __length:Number;
	private var __usuable:Boolean;
	
	public function init (){
		__commander.addEventListener("paramChange", this);
		__commander._params.getCreateParam("sliderValue",0);
	}
	
	/**
	* builds the slide bar
	* @param	mainDivision 	the distance between the small ticks division
	* @param	subDivision		the distance between the big ticks division
	* @param	fromNumber		the start of the slider
	* @param	toNumber		the end of the slider
	* @param	barTics			the width of the bar, in ticks
	*/
	public function build(mainDivision:Number,subDivision:Number,fromNumber:Number,toNumber:Number,barTics:Number){
		var ticWidth:Number = __clip._width/(toNumber-fromNumber);
		__length = toNumber- fromNumber;
		__rullerOffset = fromNumber; 
		__hotSpot = new MovieClipCommander(__clip,"hotSpot",__commander._depth.higher);
		
		var rullerMc:MovieClipCommander = new MovieClipCommander(__clip,"rullerMc",__commander._depth.higher);
		var barMcc:MovieClipCommander= new MovieClipCommander(__clip,"bar_mc",__commander._depth.higher);
		
		__bar = Bar(barMcc.registerExtention("bar",Bar,[ticWidth,barTics,(toNumber-fromNumber)]));
		__ruller = Ruller(rullerMc.registerExtention("ruller",Ruller,[__clip._width, mainDivision,subDivision,fromNumber,toNumber]));
		barMcc.addEventListener(Bar.EVT_BAR_CHANGED,this);
		_active = (_length > __bar._length);
		
		__hotSpot.registerExtention("draw",Draw);
		drawHotSpot(__clip._width);
	}
	
	public function setSkin(barSkin:String, barIcon:String, limiterColor:Number, limiterAlpha:Number) {
		setBarSkin(barSkin);
		setBarIcon(barIcon);
		__ruller._limiterColor = limiterColor;
		__ruller._limiterAlpha = limiterAlpha;
	}
	
	private function setBarSkin(linkage:String){
		__bar.skinBar(linkage);	
	}
	
	private function setBarIcon(linkage:String){
		__bar.skinBarIcon(linkage);	
	}
	
	private function drawHotSpot(width:Number){
		var mcc:MovieClipCommander = __hotSpot;
		mcc._commands.draw.clear();
		mcc._commands.draw._fillAlpha = 0;
		mcc._commands.draw._fill = true;
		mcc._commands.draw.lineStyle(0,0,0);
		mcc._commands.draw.rect(0,0,width,__bar._commander._core._clip._height)
	}
	
	public function set _limit(limit:Number){
		limit = Math.max(limit, __bar._length);
		limit = Math.min(limit,__ruller._length);
		__ruller._limit = limit;
		__bar._limit = limit;
		drawHotSpot(__bar.getPositionFromValue(limit))
	}
	
	public function get _value():Number {
		return __bar._value+__rullerOffset;
	}
	
	public function set _value(val:Number) {
		__commander._params.setParam("sliderValue", val);
	}
	public function set _snapTics(val:Number) {
		__bar._snapTics = val;
	}
	
	public function get _snapTics():Number {
		return __bar._snapTics;
	}

	private function handleEvent(evt:Object){
		switch (evt.type){
			case "onPress":
				__bar.moveBar(evt.clip._xmouse)
				break;
			case Bar.EVT_BAR_CHANGED:
				if (evt.value != __lastValue) {
					__commander._params.setParam("sliderValue",_value);
					dispatchEvent(EVT_SLIDE_CHANGED,{value:_value, lastValue:__lastValue})
				}
				__lastValue = evt.value;
				break;
		}
	}
	
	private function paramChange(evt:Object) {
		switch (evt.name) {
			case "sliderValue":
				__bar._value = evt.value;
				break;
			case "barSkin" :
				setBarSkin(evt.value);
				break;
			case "barIcon" :
				setBarIcon(evt.value)
				break;
		}
	}
	
	public function set _length(val:Number) {
		__length = val;
		_active = (val > __bar._length);
		__ruller._length = val;
		__bar._ticWidth = __ruller._ticWidth;
		__bar._limit = val;
	}
	
	public function get _length():Number {
		return __length;
	}
	
	public function get _ruller():Ruller {
		return __ruller;
	}
	public function get _bar():Bar {
		return __bar;
	}
	
	public function set _active(val) {
		if (!val) {
			if (__usuable == true || __usuable == undefined) {
				__hotSpot.removeClipEvent("onPress",this);
				__bar.hide();
				__ruller._limiterAlpha = 0;
				__usuable = false;
				dispatchEvent(EVT_SLIDE_UNUSABLE);
			}
		} else {
			if (__usuable == false || __usuable == undefined) {
				__hotSpot.addClipEvent("onPress",this);
				__bar.show();
				__ruller._limiterAlpha = 100;
				__usuable = true;
				dispatchEvent(EVT_SLIDE_USABLE);
			}
		}
	}
}
