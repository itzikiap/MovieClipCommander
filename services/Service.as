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
import iap.app.AppCommander;
 import iap.commander.ICommander;
import iap.services.ServiceProvider;

class iap.services.Service implements iap.services.IServiceType{
	private static var __id:Number = 0;
	private var __name:String;
	private var __manager:ServiceProvider;
	
	private var __commander:AppCommander;


	/**
	* the Service constructor
	* @param	manager a refferance to the service manager
	*/
	function Service(manager:ServiceProvider) {
		__id++;
		__manager = manager;
		__name = "UNREGISTERED";
//		trace("Service "+id);
	}
	
	/** 
	* a must have function to register the service and initialize it
	* [B] - PLEASE DO NOT CALL THIS FUNTION DIRECTLY - [/B]
	* @param	caller	the commander that called the service
	* @param	name		the name of the service
	* @param	extra	extra parameter
	*/
	public function registerService(caller:AppCommander, name:String, extra) {
		__name = name;
		__commander = caller;
		init.apply(this, arguments.slice(3));
		//delete registerService;
	}

	/**
	* This function must be implemented in all the derived classes
	* called from "registerService"
	*/
	private function init() {
	}
	
	/**
	* dispaches a general event from the Manager
	* its automatically adds all the basic information to the event object.
	* the information is in that format inside the evt object:
	* [B]-type[/B] - the event type. must be costume event, not clip event
	* [B]-commander[/B] - the AppCommander
	* [B]-service[/B] - this service
	* @param	eventName
	* @param	extraInfo extra information to add to the event object
	* @return	true if the event wan handled (listeners responsibility)
	*/
	private function dispatchEvent(eventName:String,extraInfo:Object):Boolean {
		extraInfo.type = eventName;
		extraInfo.service = this;
		extraInfo.commander = __commander;
		return __commander.dispatchEvent(extraInfo);
	}

	/**
	* A must have function for a service
	*/
	public function unregisterService() {
	}
	
	/**
	* unique identification of the service
	*/
	public function get id():Number {
		return __id;
	}
	public function set id( val:Number ):Void {
		__id = val;
	}

	/**
	* the name of the service, supplyed by ServiceProvider
	*/
	public function get _name():String {
		return __name;
	}

	/**
	* The commander this extention is attached to
	*/
	public function get _commander():ICommander {
		return __commander;
	}
	
	function toString():String {
		return "[extention "+__name+" for "+__commander["_name"]+"]";
	}
}
