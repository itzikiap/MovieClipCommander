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
import iap.functionUtils.Delegate;
import iap.hash.CounterHash;

/**
* provides a platform to centrlize the clip events to a form of
* addClipEvent to register an event. for multiple events
* All clip events are sent in that format inside the evt object:
* target - The movie clip
* commander - the movie clip commander
* 
* @author I.A.P Itzik Arzoni @gmail.com
* @version 1.1 05/03/2006
*/

class iap.commander.MovieClipEvents extends iap.commander.MovieClipWrapper{
	private static var MAX_EVENTS:Number = 7;
	private var __eventsCount:CounterHash;

	private var __dispatcherFunction:Function;
//	public var addEventListener:Function;
//	public var removeEventListener:Function;
	
	/**
	* pass all the paramenters to super, and initialize the events
	* @param	clipRef refferance to the clip
	* @param	clipName if exist, new clip name that would be created
	* @param	depth the new clip depth
	* @param	linkage if exist, the linkage of the symbol to attach
	*/
	public function MovieClipEvents(clipRef:MovieClip,clipName:String,depth:Number,linkage:String) {
		super(clipRef,clipName,depth,linkage);
		EventDispatcher.initialize(this, "__dispatcherFunction");
		__eventsCount = new CounterHash();
	}
	
	/**
	* adds an event to the clip, firt attach the real clip event to a generic function that call dispatch
	* All clip events are sent in that format inside the evt object:
	* target - The movie clip
	* commander - the movie clip commander
	* @param	eventName
	* @param	eventObj
	*/
	public function addClipEvent(eventName:String,eventObj:Object) {
		initClipEvent(eventName);
		if (!__eventsCount.isExist(eventName)) {
			__eventsCount.addCounter(eventName,0, MAX_EVENTS);
		}
		if (!__eventsCount.inc(eventName)) {
			addEventListener(eventName,eventObj);
		}
	}
	
	/**
	* removes one event from the clip. if no events registered, remove the function that calls the dispatch
	* @param	eventName
	* @param	eventObj
	*/
	public function removeClipEvent(eventName:String,listener:Object) {
		removeEventListener(eventName,listener);
		if (__eventsCount.dec(eventName)) {
			destroyClipEvent(eventName);
		}
	}
	
	/**
	* initialize the selected event of the clip to a generic dispatcher
	* this method causes overhead, therefor it is used only by demaned
	* @param	eventName
	*/
	private function initClipEvent(eventName:String) {
		if (eventName.indexOf("on") == 0) {
			if (__clip[eventName] == undefined) {
				__clip[eventName] = Delegate.createExtendedDelegate(this,clipEvent,[eventName]);
				__eventsCount.addCounter(eventName,0,MAX_EVENTS)
			}
		}
	}
	
	
	/**
	* destroy the callback function of an event from the clip
	* @param	eventName
	*/
	private function destroyClipEvent(eventName:String) {
		delete __clip[eventName];
		__eventsCount.removeClass(eventName);
	}
	
	public function unwrap() {
		super.unwrap();
		var clipEvents:Array = __eventsCount.names;
		for (var o:String in clipEvents) {
			destroyClipEvent(o);
		}
		EventDispatcher.initialize(this);
	}
	
	/**
	* destroys the clip, its wrapper, events and all of its child clips.
	*/
	public function destroy() {
		super.destroy();
		dispatchEvent("destroyingClip");
		unwrap();
	}
	
	
	public function addEventListener(eventName:String, listener:Object){
	}
	
	public function removeEventListener(eventName:String, listener:Object){
	}
	
	/**
	* Dispatches the requested event
	* by default provides the folowing information:
	* - type: the provided event name
	* - handled
	* @param	eventInfo	(optional) extra information to send. 
	* @param	eventName	the event name
	* @return true if the	event was consumed
	*/
	public function dispatchEvent(eventInfo:Object, eventName:String):Boolean {
		var debugTrace:Boolean = arguments[2];
		if (typeof(eventInfo) == "string") {
			eventName = String(eventInfo);
			eventInfo = new Object();
		}
		if (eventInfo == undefined) {
			eventInfo = new Object();
		}
		if (eventInfo.type == undefined) {
			eventInfo.type = eventName;
		}
		if (eventInfo.target == undefined) {
			eventInfo.target = this;
		}
		if (eventInfo.clip == undefined) {
			eventInfo.clip = __clip;
		}
		
		if (debugTrace == true) {
			trace("~2 ------- Dispatch Event debug trace ("+this+")");
			for( var i:String in eventInfo ) trace( " - key: " + i + ", value: " + eventInfo[ i ] );
			trace("---");
		}
		__dispatcherFunction(eventInfo);
		return  (eventInfo.handled == true);
	}
	
	/**
	* dispatches a clip event
	* @param	eventName
	*/
	private function clipEvent(eventName:String) {
		var evt:Object = new Object();
		evt.commander = this;
		evt.type = eventName;
		evt.clip = evt.target = __clip;
		this.dispatchEvent(evt);
	}
		
	public function get _clip():MovieClip {
		return __clip;
	}
}
