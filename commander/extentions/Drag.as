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
 import iap.services.MovieClipService;
import flash.geom.Rectangle;
import flash.geom.Point;
import iap.app.GlobalParams;

/**
* click and drag operation
* with restriction rect
* generate the folowing events:
* @event startDrag	when the movieclip is being pressed and dragged
* @event stopDrag	when the movieclip is released and the dragging stops
* @event drag	when dragging, in each mouse move.
* 	extra info: {deltax: the delta of the X betwin the original and new values, deltay: delta of Y}
* @author I.A.P ItzikArzoni
*/

class iap.commander.extentions.Drag extends MovieClipService{
	/**
	* -startDrag	when the movieclip is being pressed and dragged
	*	Extra info: {}
	*/
	static var EVT_START_DRAG:String = "startDrag";
	/**
	* -stopDrag		when the movieclip is released and the dragging stops
	*	Extra info: {}
	*/
	static var EVT_STOP_DRAG:String = "stopDrag";
	/**
	* -drag		when dragging, in each mouse move.
	*	Extra info: {[B]deltax[/B]: the delta of the X betwin the original and new values, [B]deltay[/B]: delta of Y}
	*/
	static var EVT_DRAG:String = "drag";
	// private vars
	private var __dragging:Boolean;
	private var __limits:Rectangle;
	private var __attachToParent:Boolean;
	private var __mouseBias:Point;
	private var __lastCoords:Point;
	private var __updateAfterEvent:Boolean;
	private var __gridSize:Number;
	private var __attachToGrid:Boolean;
	private var __dragOnClick:Boolean;
	private var __stopOnClick:Boolean;
	
	public function init(autoDrag:Boolean) {
		__dragging = false;
		__attachToGrid = false;
		__gridSize = 1;
		_limits = undefined;
		_attachToParent = false;
		_updateAfterEvent = true;
		_dragOnClick = (autoDrag == true);
		_stopOnClick = true;
	}
	
	/**
	* start the drag operation, init all the related events and dispatch startDrag event
	* @param snapToMiddle	if true, the object's registration point get snapped to the mouse
	*/
	public function startDrag(snapToMiddle:Boolean) {
		if (!__dragging) {
			if (snapToMiddle == true) {
				__clip._x = __clip._parent._xmouse;
				__clip._y = __clip._parent._ymouse;
			}
			if (__stopOnClick) {
				removeClipEvent("onPress");
				registerClipEvent("onMouseUp", this);
			}
			registerClipEvent("onMouseMove", this);
			
			dispatchEvent(EVT_START_DRAG);
			__mouseBias = getCoords();
			__mouseBias.x -= __clip._x;
			__mouseBias.y -= __clip._y;
			if (__attachToGrid) {
				__mouseBias.x = int(__mouseBias.x / __gridSize);
				__mouseBias.y = int(__mouseBias.y / __gridSize);
			}
			__dragging = true;
		}
	}
	
	/**
	* stops the drag operation and dispatch stopDrag event
	*/
	public function stopDrag() {
		if (__dragOnClick) {
			activate();
		}
		removeClipEvent("onMouseUp");
		removeClipEvent("onMouseMove");
		dispatchEvent(EVT_STOP_DRAG);
		__dragging = false;
	}

	private function setGridSize(newSize:Number) {
		__gridSize = newSize;
	}
	
	/**
	* the main dragging loop
	*/
	private function doDrag() {
		var coords:Point = getCoords();
		var dx:Number = coords.x - __mouseBias.x;
		var dy:Number = coords.y - __mouseBias.y;
		if (!dispatchEvent(EVT_DRAG, {deltax:dx, deltay:dy})) {
			__commander._core.move(dx, dy);
		}
		if (__updateAfterEvent) {
			_global.updateAfterEvent();
		}
	}
	
	/**
	* the main dragging loop with restriction and attach to grid
	* for speed sake I made to very similar methods instead of using if() statement
	* the "move" command is called with pixels coordinates, but the event is given the "grid" coordinates
	* Dispatches event:
	* 	"drag": on each change of place, considering the grid size. i.e. if a gridSize of 10 px, 5px movement would be ignored
	* 		extra info: {dx, dy:the amount of points the object moved since the drag was started. in "grid" coordinates}
	*/
	private function doRestrictDrag() {
		var coords:Point = getCoords();
		if (__attachToGrid) {
			coords.x = int(coords.x / __gridSize);
			coords.y = int(coords.y / __gridSize);
		}
		if (!__lastCoords.equals(coords)) {
			var dx:Number = coords.x - __mouseBias.x;;
			var dy:Number = coords.y - __mouseBias.y;;
			if ((__limits != undefined) && (!__limits.contains(dx, dy))) {
				if (dx < __limits.left) {
					dx = __limits.left;
				} else if (dx > __limits.right) {
					dx = __limits.right;
				}
				if (dy < __limits.top) {
					dy = __limits.top;
				} else if (dy > __limits.bottom) {
					dy = __limits.bottom;
				}
			}
			__lastCoords = coords;
			if (!dispatchEvent(EVT_DRAG, {deltax:dx, deltay:dy})) {
				__commander._core.move(dx * __gridSize, dy * __gridSize);
			}
			if (__updateAfterEvent) {
				_global.updateAfterEvent();
			}
		}
	}

	/**
	* returns the coordinates of the mouse on the root
	* @return the coordinates in the format of {x:   , y:  }
	*/
	private function getCoords():Point {
		return new Point(_root._xmouse,_root._ymouse);
	}
	
	private function activate() {
		registerClipEvent("onPress", this);
	}
	
	private function deactivate() {
		removeClipEvent("onPress");
	}
	
	
	private function handleEvent(evt:Object) {
		//trace(this+" handle event: +evt.type");
		switch(evt.type) {
			case "onPress":
				this.startDrag();
				break;
			case "onMouseMove":
				if (__limits == undefined && !__attachToGrid) {
					doDrag();
				} else {
					doRestrictDrag();
				}
				break;
			case "onMouseUp":
				if (__stopOnClick) {
					this.stopDrag();
				}
				break;
		}
	}
	/**
	* parameter change handler
	*/
	private function paramChange(evt:Object) {
		switch (evt.name) {
			case "gridSize":
				setGridSize(evt.value);
				break;
			case "limits":
				_limits = evt.value;
				break;
		}
	}
	
	/**
	* sets the bounding box limits of the dragged area
	*/
	public function set _limits(newLimits:Rectangle) {
		if (newLimits == false) {
			__limits = undefined;
		} else {
			__limits = newLimits;
		}
	}
	
	public function get _limits():Rectangle {
		return __limits
	}

	/**
	* Starts the drag operation automaticaly on click
	*/
	public function set _dragOnClick(val:Boolean) {
		stopDrag();
		if (val) {
			activate();
		} else {
			deactivate();
		}
		__dragOnClick = val;
	}
	
	public function get _dragOnClick():Boolean {
		return	__dragOnClick;
	}
	
	/**
	* stops the drag operation automaticaly on click
	*/
	public function set _stopOnClick(val:Boolean) {
		__stopOnClick = val;
	}
	
	public function set _attachToParent(val:Boolean) {
		__attachToParent = val;
	}
	
	/**
	* if set to true make the movieclip move in a defined grid. 
	* i.e - jumps between gaps
	*/
	public function set _attachToGrid(val:Boolean) {
		if (!__attachToGrid && val) {
			GlobalParams.registerParam("gridSize", __commander._params);
			__commander.addEventListener("paramChange", this);
			setGridSize(__commander._params.getNumber("gridSize"));
		}
		__attachToGrid = val;
	}

	/**
	* would there be a call to updateAfterEvent() on each mouse move
	*/
	public function set _updateAfterEvent(val:Boolean) {
		__updateAfterEvent = val;
	}
	public function get _updateAfterEvent():Boolean {
		return __updateAfterEvent
	}
	
	/**
	* is the commander currently dragging
	*/
	public function get _dragging():Boolean {
		return __dragging;
	}
}
