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
import iap.commander.extentions.DepthManager;
import iap.commander.extentions.Core;
import iap.app.extentions.Information;
import iap.services.Service;

/**
* Provides the Services hook up functionality for the MovieClip
* Changes V1.1
* 	- _params property, default extention for information saving
* Changes V1.2
* 	- registerExtention does not have a return value, to prevent the need of typecasting
* @author I.A.P Itzik Arzoni @gmail.com
* @version 1.2
*/

class iap.commander.MovieClipCommander extends iap.commander.MovieClipEvents implements iap.commander.ICommander{
	private var __extentions:ServiceProvider;
	private var __commands:Object;
	private var __parent:MovieClipCommander;
	private var __information:Information;
	private var __core:Core;
	private var __depthManager:DepthManager;
	
	private var __DefaultConstructor:Function = MovieClipCommander;

	/**
	* initialize the extention engine.
	* the constructor gets a clip refferance. if this is the only argument, the operation is performed on the clip.
	* if provided clipName, then the new clip is created inside the clipRef
	* if provided linkage, the new created clip eould be attached from the library, rether then created empty
	* @param	clipRef refferance to the clip
	* @param	clipName if exist, new clip name that would be created
	* @param	depth the new clip depth
	* @param	linkage if exist, the linkage of the symbol to attach
	*/
	public function MovieClipCommander(clipRef:MovieClip,clipName:String,depth:Number,linkage:String) {
//		trace("init movieClipCommander");
		super (clipRef,clipName,depth,linkage);
		__extentions = new ServiceProvider(this);
		__extentions.initFunc = "registerService";
		__extentions.initArgs = [__clip];
		__commands = __extentions.serviceLink;
		__information = Information(registerExtention("information", Information));
		__core = Core(registerExtention("core", Core));
		__depthManager = DepthManager(registerExtention("depthManager", DepthManager));
		if (linkage != undefined) {
			__information.setParam("linkage", linkage);
		}
	}
	
	/**
	* register an extention, a class that extends MovieClipService
	* any arguments passed in "args" are passed directly to the extention "init" function
	* NEW IN VERSION 1.2:
	* 	Remove the return type, to prevent the need of typecasting in use.
	* 
	* @param	name	the extention name, usually the class name
	* @param	extentionClass	the constructor function of the extention
	* @param	args	array of arguments to be passed to the extention "init" function
	* @return	refferance to the created extention to be manipulated directly
	*/
	
	public function registerExtention(name:String,extentionClass:Function,args:Array):Service {
		var newExtention:Service = Service(__extentions.registerService(name,extentionClass,args.concat([name])));
		return newExtention;
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
		var ret = (__extentions.registerUniqueService(name, extentionClass, args));
//		trace("got unique extention: "+[this, name, ret]);
		return ret;
	}
	
	/**
	* removes an extention from the commander
	* @param	name	the name of the extention to be removed
	*/
	public function removeExtention(name:String) {
		__extentions.removeService(name);
	}
	
	public function unwrap() {
		super.unwrap();
		var extentions:Array = __extentions._names;
		for (var o:String in extentions) {
			removeExtention(o);
		}
	}

	
	/**
	* destroys the clip, the commander, the event and all of the child clips and extentions
	*/
	public function destroy() {
		super.destroy();
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
	
	/**
	* the core object - all the core MovieClip actions can be performed by this Object
	* @return
	*/
	public function get _core():Core {
		return __core;
	}
	
	/**
	* Making the _clip unaccessible from the outside
	* by making this inherited getter private :)
	
	private function get _clip():MovieClip {
		return __clip
	}*/
	
	public function get _depth():DepthManager {
		return __depthManager;
	}
	
	public function get _parent():MovieClipCommander {
		return MovieClipCommander(super._parent);
	}
	
	/**
	* For an easy access to _commands, I made this "__resolve" function
	* the resolve function automatically removes a "_" prefix from the requested propery
	* If no prefix exist, it return "undefined"
	* @param	propName	a preinstalled command, prefixed with underscore "_"
	* @return	the desired plugin
	* THIS FUNCTION AS BEEN DEPRECATED
	* To avoid making the class dynamic
	function __resolve(propName:String):Object {
		if (propName.charAt(0) != "_") {
			return undefined;
		}
		return __commands[propName.substring(1)];
	}
	*/
}
