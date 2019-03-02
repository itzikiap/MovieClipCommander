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
 import iap.commander.extentions.physics.Vector;
import iap.hash.ClassHash;
import iap.functionUtils.Delegate;
import iap.commander.extentions.Core;
import flash.geom.Point;

/**
* Vector forces handling extention for MovieClipCommander
* moves the MovieClip providing forces that effect it
*
* This extention provides a way to move a movie clip according to vector calculation
* And providing a pretty accurate simulation of physical movement.
* 
* Each force is a vector that has an effect on the movie clip, providing its mass.
* You can have a vector for gravity (direction down, and a permenent force)
* Or a vector for driving forward or several vectors at a time
* 
* Use "addForce" to add one vector of spped and direction
* The acceleration to a certain direction is calculated based o the mass of the movieclip
* Mass is not something that can be seen, however, if mass is not specified, 
* it is being calculated based on the clip's size
* 
* 
* @author I.A.P Itzik Arzoni {@gmail.com)
* @version 1.0
*/
class iap.commander.extentions.physics.VectorForce extends iap.services.MovieClipService {
	private var __stopTrashold:Number;
	
	private var __forces:ClassHash;
	private var __forcesObj:Object;
	private var __friction:Number;
	private var __mainVector:Vector;
	private var __mass:Number;
	
	private var __turnAcceleration:Number;
	private var __vectorPoint:Point;

	private var __rotateToTarget:Boolean;
	private var __rotationBias:Number;

	/**
	* must have function to initialize the extention
	*/
	private function init(mass:Number) {
		__rotationBias = 0;
		__rotateToTarget = true;
		//__mainVector = new Vector(0,0);
		__vectorPoint = new Point(0,0);
		
		__turnAcceleration = 0;
		// a constant friction value. This needs to be figured out for better precision
		__friction = .90;
		__stopTrashold = 0.02;
		__mass = (mass == undefined) ? ((__clip._width + __clip._height) / 2) : mass;
		
		__forces = new ClassHash();
		__forces.initFunc = "initVector";
		__forces.initArgs = [__mass];
		__forcesObj = __forces._classes;
		
		resume();
	}
	
	/**
	* turns the movie clip's moving direction to a certain diraction
	* @param	bias
	*/
	public function turn(bias:Number) {
		__mainVector._direction += bias;
	}
	
	/**
	* pause the forces calculation
	*/
	public function pause() {
		removeClipEvent("onEnterFrame");
	}
	
	/**
	* resume the calculations
	*/
	public function resume() {
		registerClipEvent("onEnterFrame", this);
	}
	
	/**
	* reset all the forces effects
	*/
	function reset() {
		__vectorPoint = new Point(0,0);
	}
	
	/**
	* disable a force, does not remove it from the forces
	* @param	name	the force name
	*/
	function disableForce(name:String) {
		var force:Vector = __forces.getItem(name);
		force._accelX = 0;
		force._accelY = 0;
	}
	
	/**
	* reenables the force
	* @param	name	the force name
	*/
	function enableForce(name:String) {
		var force:Vector = __forces.getItem(name);
		force._mass = force._mass;
	}

	/**
	* returns a direction from the movie clip to a certain point
	* this method has no action
	* @param	x1	x value of the point
	* @param	y1	y value of the point
	* @return	the new direction
	*/
	public function directTo(x1:Number, y1:Number):Number {
		return (180 / Math.PI * Math.atan2(y1, x1));
	}
	
	/**
	* adds a force to act on the movieclip
	* @param	name	the force name
	* @param	direction	the direction
	* @param	force	the force strength
	* @return
	*/
	function addForce(name:String, direction:Number, force:Number):Vector {
		return Vector(__forces.addClass(name, Vector, [direction, force]));
	}
	
	/**
	* gets a vector by its name
	* @param	name	the vector name
	* @return	the vector
	*/
	function getForce(name:String):Vector {
		return Vector(__forces.getItem(name));
	}
	
	/**
	* changes the direction of a certain vector, based on its name
	* @param	name	the vector name
	* @param	newDirection	the new direction
	*/
	function changeForceDirection(name:String, newDirection:Number) {
		__forces.setProp(name, "_direction", newDirection);
	}
	
	/**
	* 
	* @param	name
	* @param	newModule
	*/
	function changeForceModule(name:String, newModule:Number) {
		__forces.setProp(name, "_module", newModule);
	}

	
	
	private function calcNewAcceleration():Point {
		var forces:Object = __forces._classes;
		var accelX:Number = 0;
		var accelY:Number = 0;
		for (var o:String in forces) {
			var force:Vector = forces[o];
			accelX += force._accelX;
			accelY += force._accelY;
		}
		
		return new Point(accelX, accelY);
	}
	
	/**
	* onEnterFrame
	* Event Handler
	* the main move loop
	*/
	private function onEnterFrame(evt:Object) {
		var accel:Point = calcNewAcceleration();

		__vectorPoint = __vectorPoint.add(accel);
		__vectorPoint.x *= __friction;
		__vectorPoint.y *= __friction;
		//trace("on enter frame");
		__commander._core.moveBy(__vectorPoint.x,__vectorPoint.y);
	}
	
	/**
	* set the direction of the movie clip in degrees
	*/
	public function set _direction(newDir:Number) {
		var speed:Number = __vectorPoint.length;
		__mainVector = new Vector(newDir, speed, __mass);
		__vectorPoint.x = __mainVector._x;
		__vectorPoint.y = __mainVector._y;
	}
	public function get _direction():Number {
		return directTo(__vectorPoint.x, __vectorPoint.y);
	}
	
	/**
	* set the speed in pixels per frame.
	*/
	public function set _speed(value:Number) {
		__vectorPoint.normalize(value);
	}

	public function get _speed():Number {
		return __vectorPoint.length;
	}
	
	/**
	* When set to true, the object rotation will be rotated to the calulated direction
	*
	public function set _rotate(val:Boolean) {
		__rotateToTarget = val;
	}
	public function set _rotationBias(val:Number) {
		__rotationBias = val;
	}
	public function get _acceleration():Number	{
		return __acceleration;
	}
	
	public function get _turnAcceleration():Number	{
		return __turnAcceleration;
	}
	public function set _turnAcceleration( val:Number ):Void	{
		__turnAcceleration = val;
		calcNewDirection();
	}
	*/

	public function get _friction():Number {
		return __friction;
	}
	public function set _friction( val:Number ):Void	{
		__friction = val;
	}
}
