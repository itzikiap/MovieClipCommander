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
 import iap.services.ServiceProvider
import iap.commander.MovieClipCommander;
import iap.services.IServiceType
import iap.basic.IndexedHash;
import iap.commander.ICommander;

/**
* MovieClipCommander implementation of the Service interface
* provides the functionality to register itself, get itselfs name and register and unregister events
* the dispatch event automaticaly sends the basic information.
* the information is in that format inside the evt object:
* 	-type:	 	the event type. must be costume event, not clip event
* 	-target:	the MovieClip itself
* 	-commander: the MovieClipCommander instance
* 	-service:	this
* 
* @author I.A.P itzik arzoni @gmail.com 
* @version 1.0 05/03/2006
*/
class iap.services.MovieClipService extends iap.services.Service  implements IServiceType{
    private var __clip:MovieClip;
	private var __events:IndexedHash;
	private var __commander:MovieClipCommander;
	/**
	* constructor
	* @param	manager a refferance to the service manager
	*/
	function MovieClipService(manager:ServiceProvider) {
		super(manager);
		__manager = manager;
	}

	/**
	* creates a movieclip commander on the specified MovieClip and register
	* a desired extention to it, and return it.
	* @param	mcRef	a refference to the movieclip to be assigned
	* @param	name	name of the new service
	* @param	constructorRef	[B]important[/B]: constructor of the new extention
	* @param	args	optional arguments
	* @return	a refference to the created extention
	*/
	static function create(mcRef:MovieClip, serviceName:String, constructorRef:Function, args:Array):MovieClipService {
		if (mcRef == undefined) {
			trace("~5**ERROR**: Attempt to create a service "+serviceName+" on an undefined clip! Operation ignore.");
		}
		var mcc:MovieClipCommander = new MovieClipCommander(mcRef);
		var service:MovieClipService = MovieClipService(mcc.uniqueExtention(serviceName, constructorRef, args));
		return service;
	}

	/** 
	* a must have function to register the service and initialize it
	* [B] - PLEASE DO NOT CALL THIS FUNTION DIRECTLY - [/B]
	* @param	caller
	*/
	public function registerService(caller:ICommander, name:String, extra) {
		__events = new IndexedHash();
		__clip = extra;
		__name = name;
		__commander = MovieClipCommander(caller);
		init.apply(this, arguments.slice(3));
//		super.registerService(iap.commander.Commander(caller), name, extra);
		//delete registerService;
	}
	
	/** 
	* a function to register a clip event into MovieClipManager
	* if event type of "this" instance already exist, then delete it and register the new one.
	* @param	eventName
	* @param	listener
	*/
	private function registerClipEvent(eventName:String, listener:Object) {
		if (!__events.isExist(eventName)) {
			__events.addItem(eventName,listener);
			__commander.addClipEvent(eventName,listener);
		} else {
			removeClipEvent(eventName);
			__events.addItem(eventName,listener);
			__commander.addClipEvent(eventName,listener);
		}
	}

	/**
	* removes a registered event
	* @param	eventName
	*/
	private function removeClipEvent(eventName:String) {
		var listener:Object = __events.removeItem(eventName);
		if (listener != false) {
			__commander.removeClipEvent(eventName,listener);
		}
	}
	
	/**
	* register a movie clip in the first level inside the movie clip that the 
	* extention will use as the "clip"
	* All frame events are still related to the main clip
	* MovieClipCommander still reffers to the master clip
	* All the other registered extentions still reffers to the master clip
	* @param	newClipName	the name of the internal clip as String (not refference!)
	*/
	public function registerAffectedClip(newClipName:String) {
		var newClip:MovieClip = __clip[newClipName];
		if (newClip != undefined) {
			__clip = newClip;
		}
	}
	
	/**
	* dispaches a general event from the MovieClipManager
	* its automatically adds all the basic information to the event object.
	* the information is in that format inside the evt object:
	* [B]-type[/B] - the event type. must be costume event, not clip event
	* [B]-commander[/B] - the MovieClipCommander
	* [B]-target[/B] - the clip itself
	* [B]-service[/B] - this service
	* @param	eventName
	* @param	extraInfo extra information to add to the event object
	* @return	true if the event wan handled (listeners responsibility)
	*/
	private function dispatchEvent(eventName:String, extraInfo:Object):Boolean {
		if (extraInfo == undefined) {
			extraInfo = new Object();
		}
		extraInfo.target = __clip;
		return super.dispatchEvent(eventName, extraInfo);
	}

	/**
	* unregister the service and its events. called just before destruction
	*/
	public function unregisterService() {
		var eventNames:Array = __events.names;
		for (var o in eventNames) {
			removeClipEvent(eventNames[o]);
		}
	}
	
	public function get _commander():MovieClipCommander {
		return __commander;
	}

	public function toString():String {
		return "[extention "+__name+" for "+__commander._name+"]";

	}
}