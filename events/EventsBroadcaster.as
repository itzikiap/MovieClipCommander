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
 import iap.events.EventDispatcher;

/**
* General event broadcaster to be used as a super class
* Support the absic event broadcaster functionality:
* addEventListener
* removeEventListener
* dispatchEvent
* 
* ADDED:
*  + Now support event returning true if one of the listeners handled the event
* 		setting "evt.handled" to true in one of the listeners would do it
* @author I.A.P itzik arzoni (itzik.mcc@gmail.com)
*/
class iap.events.EventsBroadcaster {
	private var __dispatcherFunction:Function;
	
	/**
	* EventBroadcaster constroctor
	*/
	function EventsBroadcaster() {
		EventDispatcher.initialize(this, "__dispatcherFunction");
	}
	
	/**
	* add a listener for a particular event
	* @param event the name of the event ("click", "change", etc)
	* @param the function or object that should be called
	*/
	public function addEventListener(eventName:String, listener:Object){
	}
	
	/**
	* remove a listener for a particular event
	* @param event the name of the event ("click", "change", etc)
	* @param the function or object that should be called
	*/
	public function removeEventListener(eventName:String, listener:Object){
	}
 	/**
	* Dispatches the requested event
	* 
	* by default provides the folowing information:
	* - type: the provided event name
	* - target: the "this"
	* - handled
	* @param	eventInfo	(optional) extra information to send. 
	* @param	eventName	the event name
	* @return true if the	event was consumed
	*/
	public function dispatchEvent(eventInfo:Object, eventName:String):Boolean {
		if (typeof(eventInfo) == "string") {
			eventName = String(eventInfo);
			eventInfo = new Object();
		}
		if (eventInfo.type == undefined) {
			eventInfo.type = eventName;
		}
		if (eventInfo.target) {
			eventInfo.target = this;
		}
		//trace("~2Dispatch event: "+eventInfo.type);
			//for( var i:String in eventInfo ) trace( "key: " + i + ", value: " + eventInfo[ i ] );

		__dispatcherFunction(eventInfo);
		return  (eventInfo.handled == true);
	}
}
