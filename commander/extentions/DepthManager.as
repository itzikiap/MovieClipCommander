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
* DepthManager extention for MovieClipCommander
* ---------------------------------------------
* MovieClipCommander service to manage all the depths of the children in the Commander
* Its a core Service and is loaded automaticaly to the commander
* 
* V1.0
*   - suports command "higher" to always give the next hieghest depth
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.DepthManager extends iap.services.MovieClipService {
	private static var DEPTH_DELTA:Number = 24;
	private static var INNER_DEPTH_DELTA:Number = 3;
	private static var LOWER_MULTIPLIER:Number = 5;
	private var __lastDepth:Number;
	private var __tops:Array;
	private var __bottoms:Array;
	private var __depths:Array;
	
	function init() {
		__lastDepth = 1000;
		__depths = new Array();
		__tops = new Array();
		__bottoms = new Array();
		__depths.push(__lastDepth);
	}
	
	/**
	* insert a depth indo the "taken depths" array
	* @param	val	the depth value
	* @param	list	into witch list to insert the depth
	*/
	private function insertDepth(val:Number, list:String):Number {
		var depthArr:Array = this["__"+list+"s"];
		depthArr.push(val);
		while (depthArr.sort(Array.NUMERIC || Array.UNIQUESORT) == 0) {
			depthArr.pop();
			depthArr.push(++val);
		}
		return val;
	}
	
	/**
	* gets a higher depth then the last one
	*/
	public function get higher():Number {
		var depth:Number = __lastDepth;
		depth += INNER_DEPTH_DELTA;
		__lastDepth = insertDepth(depth, "depth");
		return __lastDepth;
	}
	
	/**
	* gets a lower depth then the last one
	Does not crash with higher
	*/
	public function get lower():Number {
		var depth:Number = __lastDepth;
		depth -= INNER_DEPTH_DELTA*LOWER_MULTIPLIER;
		__lastDepth = insertDepth(depth, "depth");
		return __lastDepth;
	}
	
	/**
	* gets the hiest depth ever. higher then the last highers, and higher then all the other "higher"
	*/
	public function get highest() {
		var depth:Number = __depths[__depths.length-1];
		depth += DEPTH_DELTA;
		__lastDepth = insertDepth(depth, "depth");
		return __lastDepth;
	}

	/**
	* gets the lowest depth
	*/
	public function get lowest() {
		var depth:Number = __depths[0];
		depth -= DEPTH_DELTA;
		__lastDepth = insertDepth(depth, "depth");
		return __lastDepth;
	}
}
