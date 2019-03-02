
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

/**
* This is an old attempt to make a progress bar. I stopped working on it, feel free to complete this.
* NOT COMPLETE!!
* @author I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
* @version 0.5
*/

class iap.commander.extentions.ProgressBar extends iap.services.MovieClipService {
	static var BY_X_SCALE:Number = 0;
	static var BY_Y_SCALE:Number = 1;
	static var BY_FRAMES:Number = 2;
	static var BY_X_AXIS:Number = 3;
	static var BY_Y_AXIS:Number = 4;
	static var BY_ROTATION:Number = 5;
	static var BY_WIDTH:Number = 6;
	static var BY_HEIGHT:Number = 7;
	
	static var METHODS_COUNT:Number = 8
	
	private var __affectedMovieClip:MovieClip;
	private var __affectedMovieClipName:String;
	private var __minVal:Number;
	private var __maxVal:Number;
	private var __minRange:Number;
	private var __maxRange:Number;
	private var __ratio:Number;
	private var __methods:Array;
	private var __selectedMethod:Number;
	private var __progressFunc:Function;
	
	public function init() {
		__affectedMovieClip = __clip;
		__methods = new Array();
		progressMethod = BY_X_SCALE;
		__minRange = 0;
		__maxRange = 100;
		setBarValue(0,100);
	}
	
	private function getValByRange(newVal:Number):Number {
		return (newVal - __minRange) * __ratio + __minVal;
	}
	
	public function update(newVal:Number) {
		var nextVal:Number = getValByRange(newVal);
		if (__selectedMethod == 0) {
			for (var i:Number = 0; i<METHODS_COUNT; i++) {
				if (__methods[i]) {
					changeClip(i,nextVal);
				}
			}
		} else {
			changeClip(__selectedMethod,nextVal);
		}
	}
	
	public function loadEvent(evt:Object) {
		update(evt.progress);
	}
	
	private function changeClip(method:Number, newVal:Number) {
		switch (method) {
			case BY_X_SCALE:
				__clip._xscale = newVal;
				break;
			case BY_Y_SCALE:
				__clip._yscale = newVal;
				break;
			case BY_X_AXIS:
				__clip._x = newVal;
				break;
			case BY_Y_SCALE:
				__clip._y = newVal;
				break;
			case BY_WIDTH:
				__clip._width = newVal;
				break;
			case BY_HEIGHT:
				__clip._height = newVal;
				break;
			case BY_FRAMES:
				__clip.gotoAndStop(newVal);
				break;
			case BY_ROTATION:
				__clip._rotation = newVal;
				break;
		}
	}
	
	public function tuggleMethod(method:Number, val:Boolean) {
		__methods[method] = val;
		var selected:Number = 0;
		var count:Number = 0;
		for (var o in __methods) {
			if (__methods[o]) {
				count++
				selected = Number(o);
			}
		}
		if (count == 1) {
			__selectedMethod = selected;
		} else {
			__selectedMethod = 0;
		}
	}
	
	public function setRange(min:Number,max:Number) {
		__minRange = min;
		__maxRange = max;
		calcRatio();
	}
	
	public function setBarValue(min:Number,max:Number) {
		__minVal = min;
		__maxVal = max;
		calcRatio();
	}
	
	private function calcRatio() {
		var rangeDelta:Number = __maxRange - __minRange;
		var barDelta:Number = __maxVal - __minVal;
		__ratio = rangeDelta / barDelta;
	}
	
	public function set progressMethod(method:Number) {
		for (var i:Number = 0; i<METHODS_COUNT; i++) {
			__methods[i] = (i == method);
		}
		__selectedMethod = method;
	}
}