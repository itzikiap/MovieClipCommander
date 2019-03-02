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
 import iap.services.ServiceProvider;
import iap.services.Service;
import iap.app.extentions.Information;

/**
* Main class for application management classes
* Uses the Commander extention handlig methodology
* This intended to be extended, rether then be used as is
* and write extentions to it.
* 8
* Contains the Information extention as a default extention.
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.AppCommander extends iap.events.EventsBroadcaster implements iap.commander.ICommander {
	private var __extentions:ServiceProvider;
	private var __commands:Object;
	private var __parent:AppCommander;
	private var __information:Information;
	private var __name:String;
	
//	private var __DefaultConstructor:Function = MovieClipCommander;

	/**
	* initialize the extention engine.
	* @param	name	the name of the app commander
	* @param	parant	the creator of the application
	*/
	public function AppCommander(name:String, parent:AppCommander) {
		super();
		name = (name == undefined)?super.toString():name;
		__name = name;
		__extentions = new ServiceProvider(this);
		__extentions.initFunc = "registerService";
		__extentions.initArgs = [""];
		__commands = __extentions.serviceLink;
		__information = Information(registerExtention("Information", Information));
	}
	
	/**
	* register an extention, a class that extends MovieClipService
	* any arguments passed in "args" are passed directly to the extention "init" function
	* @param	name	the extention name, usually the class name
	* @param	extentionClass	the constructor function of the extention
	* @param	args	array of arguments to be passed to the extention "init" function
	* @return	refferance to the created extention to be manipulated directly
	*/
	public function registerExtention(name:String,extentionClass:Function,args:Array):Service {
		var newExtention:Service = Service(__extentions.registerService(name,extentionClass,args.concat([name])));
		return Service(newExtention);
	}
	
	/**
	* Verify the existance of a service. If doesn't exist, than it make one
	* This is experimental and not recommended for use
	* @param	name			suggested extention name
	* @param	extentionClass	extention class constructor
	* @param	args			arguments to pass to "init" function
	* @return	refferance to the service
	*/
	public function uniqueExtention(name:String, extentionClass:Function,args:Array):Service {
		return Service(__extentions.registerUniqueService(name, extentionClass, args));
	}
	
	/**
	* removes an extention from the commander
	* @param	name	the name of the extention to be removed
	*/
	public function removeExtention(name:String) {
		__extentions.removeService(name);
	}
	
	/**
	* destroys the clip, the commander, the event and all of the child clips and extentions
	*/
	public function destroy() {
		var extentions:Array = __extentions._names;
		for (var o:String in extentions) {
			removeExtention(o);
		}
	}
	
	/**
	* shortcut to accessing the commands
	* This property contain refferences to all the extentions registered, by name
	* @return	refference to all the extentions
	*/
	public function get _commands():Object {
		return __commands;
	}
	
	/**
	* Store parameters to be used thrueout the commander
	* Each parameter change dispatches "paramChange" event
	*/
	public function get _params():Information {
		return __information
	}
	
	public function get _parent():AppCommander {
		return _parent;
	}
	
	public function get _name():String {
		return	__name;
	}
	
	function toString():String {
		return "[AppCommander "+__name+"]";
	}
}
