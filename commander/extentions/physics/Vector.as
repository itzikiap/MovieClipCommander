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
 import flash.geom.Point;

class iap.commander.extentions.physics.Vector {
	private var __direction:Number;
	private var __directionRad:Number;
	private var __module:Number;
	private var __x:Number;
	private var __y:Number;
	
	private var __mass:Number;
	private var __accelX:Number;
	private var __accelY:Number;
	
	function Vector(direction:Number, module:Number) {
		initVector(direction, module);
	}
	
	function initVector(mass:Number, direction:Number, module:Number) {
		//trace("getting init vector: "+arguments);
		_direction = (direction == undefined)?0:direction;
		_module = (module == undefined)?0:module;
		__mass = (mass == undefined)? 1:mass;
		calcMass();
	}
	
	/**
	* calculates the X and Y distances given distance and direction
	* @return	point containing x and y
	*/
	private function calcDistances() {
		__x = Math.cos(__directionRad) * __module;
		__y = Math.sin(__directionRad) * __module;
		calcMass();
	}
	
	private function calcMass() {
		__accelX = __x / __mass;
		__accelY = __y / __mass;
	}
	
	public function get _direction():Number {
		return __direction;
	}
	public function set _direction(value:Number) {
		__direction = value;
		var dir:Number = __direction - 90;
		__directionRad = Math.PI / 180 * dir;
		calcDistances();
	}
	
	public function get _module():Number {
		return __module;
	}
	public function set _module(value:Number) {
		__module = value;
		calcDistances();
	}
	
	public function get _x():Number {
		return __x;
	}
	public function get _y():Number {
		return __y;
	}
	
	public function get _point():Point{
		return new Point(__x, __y);
	}
	
	public function set _point(p:Point) {
		
	}
	
	public function set _mass(value:Number) {
		__mass = value;
		calcMass();
	}
	
	public function get _accelX():Number {
		return __accelX;
	}
	public function get _accelY():Number {
		return __accelY;
	}
	
	public function set _accelX(val:Number) {
		__accelX = val;
	}
	public function set _accelY(val:Number) {
		__accelY = val;
	}
	
	function toString():String {
		return "[Vector ("+[__direction, __module]+")]";
	}

}
