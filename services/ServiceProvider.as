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
 import iap.hash.ClassHash;
import iap.services.IServiceType;

/**
* provides a service manager functionality
* keep a list of classes that implemets the Service interface
* manage them and their commands.
* also provides a link to an external object for fast command access
* @author I.A.P Itzik Arzoni @gmail.com
* @version 1.0 05/03/2006
*/
class iap.services.ServiceProvider{

	private var __services:ClassHash;
	private var __outsideQuickLink:Object;
	private var __serviceUser:Object;
	private var __defaultArguments:Array;
	private var __extraInitArgs:Array;

    /**
	* @param	serviceUser	the caller of ServiceProvider. usually the use is: new SrviceProvider(this)
    */
    public function ServiceProvider(serviceUser:Object) {
		__services = new ClassHash();
		initFunc = "registerService";
		destroyFunc = "unregisterService";
		__serviceUser = serviceUser;
		__services.initArgs =  [__serviceUser];
    }

	/**
	* register a service in the collection
	* @param	name		name for the service
	* @param	classFunc	the service constructor (class)
	* @param	args		(optional) arguments to pass to the "init" function
	* @return	refference to the service
	*/
	public function registerService(name:String,classFunc:Function,args:Array):IServiceType {
		var ret = (__services.addClass(name,classFunc,[name].concat(__extraInitArgs).concat(args)));
//		trace("add class to service: "+ret);
		return ret;
	}
	
	/**
	* register a service only if it doesn't exist
	* if it exist, the name and args arguments are ignored
	* @param	name		suggested name for the service
	* @param	classFunc	refference to the constructor
	* @param	args		arguments to pass to the init function
	* @return	refference to the service
	*/	
	public function registerUniqueService(name:String,classFunc:Function,args:Array):IServiceType {
		var ret:IServiceType;
		var exist:String = __services.isClassExist(classFunc);
		if (exist == undefined) {
			ret = registerService(name, classFunc, args);
		} else {
			ret = getService(exist);
		}
//		trace("got unique service: "+[name, exist, ret]);
		return ret;
	}

	public function removeService(name:String):Boolean {
		var ret:Boolean = __services.removeClass(name);
		return ret;
	}
	
	/**
	* retrive one service from the list
	* @param	serviceName
	* @return	
	*/
	public function getService(key:String):IServiceType {
		var ret:IServiceType = IServiceType(__services.getItem(key));
		return ret;
	}

	/**
	* run a command of one of the services
	* @param	serviceName
	* @param	commandName
	* @param	args
	* @return
	*/
	public function command(serviceName:String,commandName:String,args:Array):Object {
		return __services.command(serviceName,commandName,args);
	}


	public function set initFunc(funcName:String) {
		__services.initFunc = funcName;
	}
	public function set initArgs(args:Array) {
		__extraInitArgs = args;
	}
	public function set destroyFunc(funcName:String) {
		__services.destroyFunc = funcName;
	}
	public function set destroyArgs(args:Array) {
		__services.destroyArgs = args;
	}
	
	public function isExist(serviceName:String):Boolean {
		return __services.isExist(serviceName);
	}
	/**
	* provide an outside class the ability to quickly point to a service
	* @param	objRef  the object that will reffer to the services list
	*/
	public function get serviceLink():Object {
		return __services._classes;
	}
	
	public function get _count():Number {
		return __services._count
	}
	
	public function get _names():Array {
		return __services.names;
	}

}