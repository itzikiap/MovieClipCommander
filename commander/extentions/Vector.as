import iap.services.*;
import iap.functionUtils.Delegate;
import iap.commander.extentions.Core;
/**
* Tester unit for MovieClipCommander
* moves the MovieClip providing speed and direction in degrees
* this is a simple vector. 
* a modified VectorForce extention that actually simulate physics forces, is in the "physics" package
*
* @author I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
* @version 1.0
*/
class iap.commander.extentions.Vector extends MovieClipService {
	private var __direction:Number;
	private var __speed:Number;/*
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
 
	private var __dx:Number;
	private var __dy:Number;
	private var __rotateToTarget:Boolean;
	private var __rotationBias:Number;
	private var __savedSpeed:Number;
	
	private var __moveService;
	
	private var delegateMoveLoop:Function;

	/**
	* must have function to initialize the plugin
	*/
	private function init() {
		delegateMoveLoop = Delegate.create(this,moveLoop)
		__rotationBias = 0;
		__rotateToTarget = false;
		__direction = 0;
		__speed = 0;
		__savedSpeed = 0;
		calcDistances();
		//trace(__commander._core);
		//trace("moveService: "+__moveService);
	}
	
	public function pause() {
		__savedSpeed = __speed;
		speed = 0;
	}
	
	public function resume() {
		speed = __savedSpeed
	}
	
	public function directTo(x1:Number, y1:Number) {
		direction = 180 / Math.PI * Math.atan2(y1-__clip._y, x1-__clip._x);
	}
	/**
	* set the direction of the movie clip in degrees
	* @param	newDir
	*/
	public function set direction(newDir:Number) {
		__direction = newDir;
		if (__rotateToTarget) {
			__moveService.rotate(__direction + __rotationBias);
		}
		calcDistances();
	}
	
	/**
	* set the speed in pixels per frame.
	* if speed is other then 0, it register an "onEnterFrame" clip event. if its 0, it removes this registration
	* @param	newSpeed
	*/
	public function set speed(newSpeed:Number) {
		__speed = newSpeed;
		if (__speed != 0) {
			registerClipEvent("onEnterFrame", delegateMoveLoop);
			calcDistances();
		} else {
			removeClipEvent("onEnterFrame");
		}
	}
	public function get direction():Number {
		return __direction;
	}
	public function get speed():Number {
		return __speed;
	}
	
	/**
	* the main move loop 
	* @param	evt
	*/
	private function moveLoop(evt:Object) {
		__moveService.moveBy(__dx,__dy);
	}
	
	private function calcDistances() {
		__dx = Math.cos(Math.PI / 180 * __direction) * __speed;
		__dy = Math.sin(Math.PI / 180 * __direction) * __speed;
	}
	
	public function set rotate(val:Boolean) {
		__rotateToTarget = val;
	}
	
	public function set rotationBias(val:Number) {
		__rotationBias = val;
	}

	public function set dx(newVal:Number) {
		__dx = newVal;
		if (__dx != 0) {
			registerClipEvent("onEnterFrame", delegateMoveLoop);
		} else if (__dy == 0) {
			removeClipEvent("onEnterFrame");
		}
	}
	public function set dy(newVal:Number) {
		if (__dy != 0) {
			registerClipEvent("onEnterFrame", delegateMoveLoop);
		} else if (__dy == 0) {
			removeClipEvent("onEnterFrame");
		}
		__dy = newVal;
	}
	public function get dx():Number {
		return __dx;
	}
	public function get dy():Number {
		return __dy;
	}
}
