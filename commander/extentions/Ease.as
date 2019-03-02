
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
 import iap.basic.IndexedHash;
import iap.commander.extentions.Core;

/**
* A simple ease extention for MovieClipCommander
* just use easeProperty to add another property to ease
* @event "easeDone": {property: the property name, value: the end value}
* 
* @author I.A.P Itzik arzoni (itzik.mcc@gmail.com)
* @version 1.0
*/
class iap.commander.extentions.Ease extends iap.services.MovieClipService {
	/**
	* easeStart - when an easing of a certain property is started
	*/
	static var EVT_EASE_START:String = "easeStart";
	/**
	* -easeDone When the easing of one property is done
	* 	Extra info: {[B]property[/B]: the property name, [B]value[/B]: the end value}
	*/
	static var EVT_EASE_DONE:String = "easeDone";
	/**
	* easeEnd - when a easing of all peoperyies is ended
	*/
	static var EVT_EASE_END:String = "easeEnd";

	
	// private vars
	private var __trashold:Number;
	private var __defaultFactor:Number;
	private var __properties:IndexedHash;
	private var __easing:Boolean;
	private var __propertiesNames:Array;
	private var __hookToCore:Boolean;
	
	public function init(hookCore:Boolean) {
		__properties = new IndexedHash();
		__trashold = 0.8;
		__defaultFactor = 3;
		__easing = false
		_hookToCore = hookCore;
	}
	
	/**
	* add another clip property to be eased and begin the easing
	* if the clip property is already being eased, its easing definitions are updated
	* Old definitions are deleted
	* @param	name	name of the property to ease
	* @param	value	the end value
	* @param	factor	(optional) the easing speed
	*/
	public function easeProperty(name:String, value:Number, factor:Number) {
		
		if (value != undefined) {
			if (factor == undefined) {
				factor = __defaultFactor;
			}
			if (name == "_alpha") {
				if (!__clip._visible) {
					__clip._alpha = 0;
				}
				if (value > 0) {
					__clip._visible = true;
				}
			}
			
			var property:Object = new Object();
			property.value = __clip[name];
			property.oldValue = property.value;
			property.factor = factor;
			property.endValue = value;
			__properties.addItem(name, property);
			__propertiesNames = __properties.names;
			beginEasing();
		}
	}
	
	/**
	* begins the easing and registring the onEnterFrame event
	*/
	private function beginEasing() {
		if (!__easing) {
			registerClipEvent("onEnterFrame", this);
			__easing = true;
			dispatchEvent(EVT_EASE_START);
		}
	}
	
	/**
	* ends the easing after all the 
	*/
	private function endEasing() {
		removeClipEvent("onEnterFrame");
		__properties.destroy();
		__easing = false;
			dispatchEvent(EVT_EASE_END);
	}

	/**
	* the main easing function
	* @param	evt
	*/
	private function onEnterFrame(evt:Object) {
		var calcs:Object = new Object();
		// unknow count (to save function call) that would be replaced when deleting object
		var count:Number = -1;
		for (var o in __propertiesNames) {
			var name = __propertiesNames[o];
			var property = __properties.getItem(name);
			
			var calc:Number = (property.endValue - property.value) / property.factor;
			property.value += calc;
			if (Math.abs(calc) < __trashold) {
				changeProperty(name, property.endValue);
				dispatchEvent(EVT_EASE_DONE ,{property:name, value:property.endValue});
				__properties.removeItem(name);
				
				count = __properties._count;
			} else {
				changeProperty(name, property.value);
				__properties.replaceItem(name, property);
			}
			property.oldValue = calc;
		}
		__propertiesNames = __properties.names;
		if (count == 0) {
			endEasing();
		}
	}
	
	private function changeProperty(key:String, value:Number) {
		__clip[key] = value;
		if (key == "_alpha") {
			if (value < 1) {
				__clip._alpha = 100;
				__clip._visible = false;
			}
		}
	}
	
	/**
	* handleEvent method
	*/
	public function handleEvent(evt:Object) {
		//trace(this+", handle event of type: "+evt.type);
		switch (evt.type) {
			case Core.EVT_MOVE:
				easeProperty("_x", evt.x);
				easeProperty("_y", evt.y);
				evt.handled = true;
				break;
			case Core.EVT_PROPERTY:
				easeProperty(evt.name, evt.value);
				evt.handled = true;
				break;
		}
	}
	
	public function set _defaultFactor(newFactor:Number) {
		__defaultFactor = newFactor;
	}
	
	public function get _defaultFactor():Number {
		return __defaultFactor;
	}
	
	public function get _hookToCore():Boolean	{
		return __hookToCore;
	}
	
	public function set _hookToCore( val:Boolean ):Void	{
		if (__hookToCore != val) {
			__hookToCore = val;
			var core:Core = __commander._core;
			if (val) {
				__commander.addEventListener(Core.EVT_MOVE, this);
				__commander.addEventListener(Core.EVT_PROPERTY, this);
				__commander.addEventListener(Core.EVT_ROTATE, this);
				__commander.addEventListener(Core.EVT_SCALE, this);
				__commander.addEventListener(Core.EVT_SIZE, this);
			} else {
				__commander.removeEventListener(Core.EVT_MOVE, this);
				__commander.removeEventListener(Core.EVT_PROPERTY, this);
				__commander.removeEventListener(Core.EVT_ROTATE, this);
				__commander.removeEventListener(Core.EVT_SCALE, this);
				__commander.removeEventListener(Core.EVT_SIZE, this);
			}
		}
	}
	
	public function get _trashold():Number	{
		return __trashold;
	}
	
	public function set _trashold(val:Number):Void	{
		__trashold = val;
	}

}
