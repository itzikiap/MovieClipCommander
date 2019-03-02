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
 import iap.basic.Counter;
import iap.basic.IndexedHash;
import iap.commander.extentions.animation.tweens.ITween;
import iap.hash.ClassHash;
import iap.hash.CounterHash;
/**
* Params tweening extention for movie clip eommander
* This class make a frame based tween on parameters.
* For certain extentions (As much as possible) there are several parameters describing
* several things, whether visual or logical.
* If an extention is registered to listen to this particular parameter change and do something with it
* you can use this extention to tween a change of a parameter instead of 
* just changing it.
* 
* This extention use external class as the tweening calculator. 
* Don't hasitate to write more and more tweening calculators
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
**/
class iap.commander.extentions.animation.ParamTween extends iap.services.MovieClipService {
	/**
	* tweenDone: when all tweening of all parameters are done
	*/
	static var EVT_TWEEN_DONE:String = "tweenDone";
	/**
	* tweenEnd: when a tweening of one parameter is done
	* extra info:
	* [B]param[/B]:param,
	* [B]value[/B]:getEndValue()
	*/
	static var EVT_TWEEN_END:String = "tweenEnd";
	
	
	private static var DEFAULT_TWEEN:Function = iap.commander.extentions.animation.tweens.Linear;
	
	private var __activeTweens:CounterHash;
	private var __tweensData:ClassHash;
	private var __running:Boolean;
	
	/**
	* initialize the extention
	*/
	function init() {
		__activeTweens = new CounterHash();
		__tweensData = new ClassHash();
		__tweensData.initFunc = "preCalc";
		__running = false;
	}
	
	/**
	* adds a tween or replace an existing one
	* @param	paramName	the name of the parameter to tween
	* @param	destValue	the destination value
	* @param	duration	the duration in frames
	* @param	tweenClass	the class that will calculate the tween. if ommited, linear tween is the default
	*/
	function addTween(paramName:String, destValue:Number, duration:Number, tweenClass:Function) {
		tweenClass = (tweenClass == undefined)? DEFAULT_TWEEN : tweenClass;
		var value:Number = __commander._params.getNumber(paramName)
		if (__activeTweens.isExist(paramName)) {
			__activeTweens.getCounter(paramName).value = 0;
			__activeTweens.getCounter(paramName).max = duration;
			__tweensData.replaceItem(paramName, {destination:destValue, value:value});
		} else {
			__activeTweens.addCounter(paramName, 0, duration);
			__tweensData.addClass(paramName, tweenClass, [value, destValue, duration]);
			if (!__running) {
				engageAnimationLoop();
			}
		}
	}
	
	/**
	* the main tweening loop
	*/
	private function onEnterFrame() {
		var params:Array = __tweensData.names;
		for (var o:String in params) {
			var param:String = params[o];
			var counter:Counter = __activeTweens.getCounter(param);
			var tweenData:ITween = ITween(__tweensData.getItem(param));
//			trace("param tween: "+[param, counter.value, tweenData.getNextValue(counter.value)]);
			if (!counter.inc(param)){
				tweenStep(param, tweenData.getNextValue(counter.value));
			} else {
				//trace("~2done param tween: "+[param, counter.value, tweenData.getEndValue(counter.value)]);
				tweenStep(param, tweenData.getEndValue());
				destroyTween(param);
			}
		}
	}
	
	/**
	* one tween step
	* @param	paramName	the parameter name
	* @param	nextValue	the new value
	*/
	private function tweenStep(paramName:String, nextValue:Number) {
		__commander._params.setParam(paramName, nextValue);
	}
	
	/**
	* destroy a tween (stop it)
	* dispatches event "EVT_TWEEN_DONE"
	* @param	param	the parameter to stop tweening
	*/
	function destroyTween(param:String) {
		dispatchEvent(EVT_TWEEN_END, {param:param, value:__tweensData.getItem(param).getEndValue()});
		removeTween(param);
		if (__activeTweens._count == 0) {
			dispatchEvent(EVT_TWEEN_DONE);
		}
	}
	
	/**
	* removes a tween from the list
	* @param	param	removes the tween without dispatching "tweenDone" event
	*/	
	function removeTween(param:String) {
		__tweensData.removeClass(param);
		__activeTweens.removeItem(param);
		if (__activeTweens._count == 0) {
			destroyAnimationLoop();
		}
	}
	
	/**
	* starts the animation loop
	*/
	private function engageAnimationLoop() {
		__commander.addClipEvent("onEnterFrame",this);
		__running = true;
	}
	
	/**
	* stop the animation loop
	*/
	private function destroyAnimationLoop() {
		removeClipEvent("onEnterFrame");
		__running = false;
	}
}

