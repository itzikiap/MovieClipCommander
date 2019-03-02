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
* Core extention to MovieClipCommander
* provides the core commands for a movieclip like move resize and stuff
* dispaches an event for every action
* @author I.A.P itzik Arzoni (itzik.mcc@gmail.com)
* @version 1.0
*/
class iap.commander.extentions.Core extends iap.services.MovieClipService {
	/**
	* Sends the event when move requested
	* 	Extra info: {[B]x[/B]:newX, [B]y[/B]:newY, [B]oldx[/B]:__clip._x, [B]oldy[/B]:__clip._y}
	*/
	static var EVT_MOVE:String = "move";
	/**
	* Sends when size operation is requested
	* 	Extra info: {[B]width[/B]:width, [B]height[/B]:height}
	*/
	static var EVT_SIZE:String = "size";
	/**
	* Sends when scale is being requested
	*	Extra info: {[B]xscale[/B]:sx, [B]yscale[/B]:sy}
	*/
	static var EVT_SCALE:String = "scale";
	/**
	* Sends when rotation change is requested
	*	Extra info: {[B]rotation[/B]:rot, [B]oldRotation[/B]:__clip._rotation}
	*/
	static var EVT_ROTATE:String = "rotate";
	/**
	* Sends when a property is changed.
	*	Extra info: {[B]name[/B]:<property name>, [B]value[/B]:<property value>, [B]oldValue[/B]:<old value>, [B]<propertyName>[/B]:<propertyValue> }
	*/
	static var EVT_PROPERTY:String = "property";
	// private vars
/*	private var __directMove:Boolean;
	private var __directSize:Boolean;
	private var __directScale:Boolean;
	private var __directElse:Boolean;
*/
	public function init() {
	}
	
	/**
	* moves the clip to a specified location
	* event info:
	* 	-x:	the new x location
	* 	-y:	the new y location
	* 	-oldx:	the old x location
	* 	-oldy:	the old y location
	* @param	newX
	* @param	newY
	*/
	public function move(newX:Number,newY:Number) {
		if (!dispatchEvent(EVT_MOVE, {x:newX, y:newY, oldx:__clip._x, oldy:__clip._y})) {
			__clip._x = newX;
			__clip._y = newY;
		}
	}
	
	/**
	* moves to a place relative to current position
	* events same as "move"
	* @param	dx
	* @param	dy
	*/
	public function moveBy(dx:Number, dy:Number) {
		move(__clip._x+dx, __clip._y+dy);
	}
	
	/**
	* size the clip
	* event info:
	* 	-width:	the new width
	* 	-height:	the new height
	* @param	width
	* @param	height
	*/
	public function size(width:Number, height:Number) {
		if (!dispatchEvent(EVT_SIZE, {width:width, height:height})) {
			__clip._width = width;
			__clip._height = height;
		}
	}
	
	/**
	* scale the clip
	* event info:
	* 	-xscale:	new x scale
	* 	-yscale:	new y scale
	* @param	sx
	* @param	sy
	*/
	public function scale(sx:Number, sy:Number) {
		if (!dispatchEvent(EVT_SCALE, {xscale:sx, yscale:sy})) {
			__clip._xscale = sx;
			__clip._yscale = sy;
		}
	}
	
	/**
	* rotate the clip
	* event info:
	* 	-rotation:	the now rotation
	* 	-oldRotation:	the old rotation
	* @param	rot
	*/
	public function rotate(rot:Number) {
		if (!dispatchEvent(EVT_ROTATE, {rotation:rot, oldRotation:__clip._rotation})) {
			__clip._rotation = rot;
		}
	}
	
	/**
	* general function to change a proprty of the clip
	* event info:
	* 	-<propertyName>:	new value
	* @param	propertyName	the of the property to change
	*/
	public function property(propertyName:String, val:Object) {
		
		var evtName:String = propertyName.slice(1);
		var evt:Object = new Object();
		evt.name = propertyName;
		evt.value = val;
		evt.oldValue = __clip[evtName];
		evt[evtName] = val;
		var ret:Boolean = dispatchEvent(EVT_PROPERTY, evt);
		if (!ret) {
			__clip[propertyName] = val
		}
	}
	
	/**
	* apply all the properties given in an Object to the movieclip
	* using "property" to disatch the event
	* @param	propertiesObj	properties Object in the form of: {_x:4, _height:6}
	*/
	public function applyPropertiesObject(propertiesObj:Object) {
		for (var o:String in propertiesObj) {
			if (o.indexOf("_") > -1) {
				property(o,propertiesObj[o] )
			}
		}
	}
	
	/**
	* Get a refferance to the clip. Use with causion
	*/
	public function get _clip():MovieClip {
		return	__clip;
	}
}
