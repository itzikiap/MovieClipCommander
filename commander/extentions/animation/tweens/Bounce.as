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
* Linear tweening calculation class for ParamTween extention
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.animation.tweens.Bounce implements iap.commander.extentions.animation.tweens.ITween{
	private var __start:Number;
	private var __end:Number;
	private var	__delta:Number;
	private var __lastValue:Number;
	private var __duration:Number;
	
	/**
	* empty constructor
	*/
	function Bounce() {
	}
	
	/**
	* a function to precalculate the required data for the tweening
	* @param	startValue	the begining value
	* @param	endValue	the end value
	* @param	duration	the duration in frames
	*/
	public function preCalc(startValue:Number, endValue:Number, duration:Number) {
		if (duration == undefined) {
			duration = 14
		}
		__start = startValue;
		midCalc(endValue,duration);
		__lastValue = __start;
	}
	
	/**
	* retrives the next value based on time
	* @param	t	frames
	* @return	the next calculated value
	*/
	public function getNextValue(t:Number):Number {
		//trace("get next value: "+[__lastValue,__delta,__lastValue+__delta]);
		__lastValue = A * Math.sin(t / (2 * __duration * Math.pi));
		return __lastValue;
	}
	
	/**
	* recalculating in the middle of the way (if neccesery)
	* @param	endValue	the destination value
	* @param	duration	the duration
	*/
	public function midCalc(endValue:Number, duration:Number) {
		__end = endValue;
		var distance:Number = (endValue - __start);
		if (distance == 0) {
			__delta = 0;
		} else {
			__delta =  distance/ duration;
		}
		
		//trace("mid calc: "+[__start, arguments, __delta]);
	}
	
	/**
	* retrive the end value
	* @return	the end value
	*/
	public function getEndValue():Number {
		return __end;
	}
}
