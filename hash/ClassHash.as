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
* This class provides a way to have a collection of instences
* enables you to set a startup function with parameters
* and also destruc function, with parameters
* @author I.A.P itzik arzoni (itzikiap@nana.co.il)
* @version 1.0
*/
class iap.hash.ClassHash extends iap.basic.IndexedHash {

	private var __initFunc:String;
	private var __initArguments:Array;

	private var __destroyFunc:String;
	private var __destroyArguments:Array;

	private var __preinstantiate:Boolean;

	public function ClassHash() {
		super();
		__preinstantiate = true;
		__initArguments = new Array();
		__destroyArguments = new Array();
	}

	/**
	* adds a class to the hash
	* create new instance if __preinstantiate is true
	* if key alreasy exist, then it will ignor the command
	* @param	key	the name for the new instance of the class
	* @param	classRef a refferance to the class constructor
	* @return   refference to new class
	*/
	public function addClass(key:String,classRef:Function,args:Array):Object {
		var newItem:Object;
		var ret:Object = false;
		if (!isExist(key)) {
			if (__preinstantiate) {
				newItem = new classRef();
				if (__initFunc != undefined) {
					var initArgs:Array = __initArguments.concat(args);
					newItem[__initFunc].apply(newItem,initArgs);
				}
			} else {
				newItem = classRef;
			}
			addItem(key,newItem);
			ret = newItem;
			//trace("~2Adding new class: "+ [key ,getItem(key)]);
		} else {
			trace("~5ERROR: Add class: '"+key+"' failed because key already exist.");
		}
		return ret
	}
	
	/**
	* checks if the class exist in the hash by comparing the constructor to a function
	* @param	constructorRef	refference to the function
	* @return	the hashing key (String) of the first class found, or undefined, if doesn't exist.
	*/
	public function isClassExist(constructorRef:Function):String {
		var ret:String = undefined;
		for (var o:String in __data) {
			if (__data[o] instanceof constructorRef) {
				ret = o;
				break;
			}
		}
		return ret;
	}

	/**
	* removes a class from the hash
	* @param	key
	* @return the item removed or false if wasn't exist
	*/
	public function removeClass(key:String):Boolean {
		var ret:Boolean = false;
		if (isExist(key)) {
			var item = getItem(key);
			if (__destroyFunc != undefined) {
				item[__destroyFunc].apply(item,__destroyArguments);
			}
			ret = true;
			removeItem(key);
		}
		return ret;
	}
	
	/**
	* run a a method of one of the classes
	* @param	key
	* @param	methodName
	* @param	args
	* @return	the return value of the method
	*/
	public function command(className:String,methodName:String,args:Array):Object {
		var item:Object = getItem(className);
		var ret:Object =  item[methodName].apply(item,args);
		return ret;
	}
	
	/**
	* set a property of on of the classes
	* @param	className
	* @param	propName
	* @param	value
	*/
	public function setProp(className:String,propName:String,value:Object) {
		var item = getItem(className);
		item[propName] = value;
	}
	
	/**
	* gets the property value of one of the classes
	* @param	className
	* @param	propName
	* @return
	*/
	public function getProp(className:String,propName:String):Object {
		var item = getItem(className);
		return item[propName];
	}

	/**
	* sets a function name to be issued when registering the service. its optional, 
	* but its better practice then relaying on the constructor
	* @param	funcName the function name String
	*/
	public function set initFunc(funcName:String) {
		__initFunc = funcName;
	}
	/**
	* initializtion arguments to pass the init function.
	* in the AddClass method you can specify additional arguments to be passed after these
	* @param	args
	*/
	public function set initArgs(args:Array) {
		__initArguments = args;
	}
	/**
	* the function name to be executed when removing the class
	*/
	public function set destroyFunc(funcName:String) {
		__destroyFunc = funcName;
	}
	/**
	* arguments to pass to the destroy function
	* @param	args	in the form of an array
	*/
	public function set destroyArgs(args:Array) {
		__destroyArguments = args;
	}
	
	public function set preInstenciate(val:Boolean) {
		__preinstantiate = val;
	}

	/**
	* gets the data object for fast access to all the instances
	* in the form of:
	* <code>
	*   var ch:ClassHash = new ClassHash();
	*   ch.addClass("Something",iap.some.thing.Something);
	*   ch._classes.Something.doThat();
	* </code>
	* @return
	*/
	public function get _classes():Object {
		return __data;
	}
	
	/**
	* experimental - immidiate access to each instance
	* in the form of:
	* <code>
	*   var ch:ClassHash = new ClassHash();
	*   ch.addClass("Something",iap.some.thing.Something);
	*   ch.Something.doThat();
	* </code>
	* this will not pass AS2 type checking, but when using from withing a frame it works
	* @param	propertyName
	* @return
	*/
	function __resolve(propertyName:String):Function {
		return __data[propertyName];
	}
	
	function toString():String {
		return "[type Class Hash]"
	}
}