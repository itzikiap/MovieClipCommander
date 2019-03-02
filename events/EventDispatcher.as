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
* base class for event listening and dispatching
* based on Macromedia class
*/
class iap.events.EventDispatcher
{
	/**
	* make a instance of ourself so we can add methods to other objects
	*/ 
	static var EVENT_DISPATCHER:EventDispatcher = undefined;

	/**
	* internal function for removing listeners
	* @param	queue	the events queue
	* @param	event	evenv name
	* @param	handler	the handler to remove
	*/
	static function _removeEventListener(queue:Object, event:String, handler) {
		if (queue != undefined)	{
			var l:Number = queue.length;
			var i:Number;
			for (i = 0; i < l; i++)	{
				var o = queue[i];
				if (o == handler) {
					queue.splice(i, 1);
					return;
				}
			}
		}
	}

	/**
	* add listening and dispatching methods to an object
	* @param object the object to receive the methods
	*/
	static function initialize(object:Object, dispatcherName:String) {
		if (dispatcherName == undefined) {
			dispatcherName = "dispatchEvent";
		}
		if (EVENT_DISPATCHER == undefined) {
			EVENT_DISPATCHER = new EventDispatcher();
		}
		object.addEventListener = EVENT_DISPATCHER.addEventListener;
		object.removeEventListener = EVENT_DISPATCHER.removeEventListener;
		object[dispatcherName] = EVENT_DISPATCHER.dispatchEvent;
		object.dispatchQueue = EVENT_DISPATCHER.dispatchQueue;
	}

	/**
	* internal function for dispatching events
	* @param	queueObj	Object containing the listeners queue
	* @param	eventObj	Object containing event information. As a refference
	*/ 
	function dispatchQueue(queueObj:Object, eventObj:Object):Void
	{
		var queueName:String = "__q_" + eventObj.type;
		var queue:Array = queueObj[queueName];
		if (queue != undefined) {
			var i:String;
			// loop it as an object so it resists people removing listeners during dispatching
			for (i in queue) {
				var o = queue[i];
				var oType:String = typeof(o);
				// a handler can be a function, object, or movieclip
				if (oType == "object" || oType == "movieclip")	{
					// first check if a function handleEvent exist, and call it. 
					// if not, check if a function with the event name exist, and call it.
					//trace("~2Dispatching event "+queueName+" to listener ("+this+"): "+[o, o.handleEvent]);
   					if (o.handleEvent != undefined) {
   						o.handleEvent(eventObj);
   					} 
					if (o[eventObj.type] != undefined) {
						o[eventObj.type](eventObj);
   					}
				}
				else {// it is a function 
					o.apply(queueObj, [eventObj]);
				}
			}
		}
	}

	/**
	* dispatch the event to all listeners
	* @param eventObj an Event or one of its subclasses describing the event
	*/
	function dispatchEvent(eventObj:Object) {
		if (eventObj.target == undefined) {
			eventObj.target = this;
		}
		if (this[eventObj.type + "Handler"] != undefined) {
			this[eventObj.type + "Handler"](eventObj);
		}
		// Dispatch to objects that are registered as listeners for
		// this object.
		this.dispatchQueue(this, eventObj);
	}

	/**
	* add a listener for a particular event
	* @param event the name of the event ("click", "change", etc)
	* @param the function or object that should be called
	*/
	function addEventListener(event:String, handler) {
		var queueName:String = "__q_" + event;
		if (this[queueName] == undefined){
			this[queueName] = new Array();
		}
		// hide the queue
		_global.ASSetPropFlags(this, queueName,1);
		EventDispatcher._removeEventListener(this[queueName], event, handler);
		this[queueName].push(handler);
	}

	/**
	* remove a listener for a particular event
	* @param event the name of the event ("click", "change", etc)
	* @param the function or object that should be called
	*/
	function removeEventListener(event:String, handler)	{
		var queueName:String = "__q_" + event;
		EventDispatcher._removeEventListener(this[queueName], event, handler);
	}
}

