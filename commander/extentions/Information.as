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
 import iap.basic.IndexedHash;
import iap.app.GlobalParams;
/**
* provides a way to save information related to the MovieClipCommander
* This information is shared with all extentions and off coarse outside
* 
* dispatches param change event:
* 	paramChange - 
* 		extra info: {name: parameter name, value:new value}
*HISTORY:
* 	V1.0
* 	  -support dispatch events
* 
* Future planes:
* 	-import from XML
* @author I.A.P itzik arzoni (itzik.mcc@gmail.com)
* @version 1.0
*/
dynamic class iap.commander.extentions.Information extends iap.services.MovieClipService {
	private var __parameters:IndexedHash;
	private var __globalParam:Object;
	
	public function init(initParams:Object) {
		__parameters = new IndexedHash();
		__parameters.importFromObject(initParams);
		__globalParam = new Object();
	}
	
	/**
	* set a desired parameter. overwrite if exist
	* dispatches param change event:
	* 	"paramChange"
	* 		extra info: {name: the parameter name, value:new value}
	* @param	name	paramenter name
	* @param	value	parameter value. Any type (Object)
	* @return	the new value entered
	*/
	public function setParam(name:String, value:Object):Object {
		//trace("setting param: "+[name,value]);
		if (value != undefined) {
			var oldVal:Object = __parameters.getItem(name);
			if (value != oldVal) {
				__parameters.addItem(name, value);
				dispatchEvent("paramChange", {name:name, value:value});
				if (__globalParam[name] && arguments[2] == undefined) {
					GlobalParams.setParam(name, value, this);
				}
			}
		}
		return value;
	}
	
	/**
	* set the Information class to register itself to GlobalParams class
	* with a specific parameter.
	* That way, each change of the parameter in the global param, will reflect here
	* Work in both ways.
	* @param	paramName	the parameter to register
	* @param	noFeedBack	set this to true, only to prevent loop calling to GlobalParams
	*/
	public function registerGlobalParam(paramName:String, noFeedBack:Boolean) {
		if (!(noFeedBack == true)) {
			GlobalParams.registerParam(paramName, this);
		}
		__globalParam[paramName] = true;
	}
	
	/**
	* get the parameter as a generic object, no type casting
	* @param	name	parameter name
	* @return	object as the value, false if not exist
	*/
	public function getObject(name:String):Object {
		return __parameters.getItem(name);
	}
	
	/**
	* get the desired parameter as number
	* @param	name	parameter name
	* @return	Number of the value. NaN if not a number or doesn't exist
	*/
	public function getNumber(name:String):Number {
		return Number(__parameters.getItem(name));
	}
	
	/**
	* get prameter string representation
	* @param	name	parameter name
	* @return	String of value
	*/
	public function getString(name:String):String {
		return __parameters.getItem(name).toString();
	}
	
	/**
	* get parameter Boolean representation
	* @param	name	parameter name
	* @return	true if = true, "true", "yes", "on", other then 0. case sensitive
	*/
	public function getBool(name:String):Boolean {
		var val:Object = __parameters.getItem(name);
		//trace("Parameter getBool: "+name+" = "+val+". "+__commander);
		var ret:Boolean;
		if (val == true || val == "true" || val == "yes" || val == "on" ||  val > 0) {
			ret = true
		} else {
			ret = false;
		}
		return ret;
	}
	
	/**
	* get an array represntation of the parameter.
	* if it was object, the array is is created with 
	* the Object data as the fields, disgarding the names
	* @param	name
	* @return
	*/
	public function getArray(name:String):Array {
		var item:Object = __parameters.getItem(name);
		var ret:Array;
		if (item instanceof Array) {
			ret = Array(item);
		} else {
			ret = new Array();
			for (var o:String in item) {
				ret.unshift(item[o]);
			}
		}
		return ret;
	}
	
	/**
	* Gets a parameter value, if it is not exist, if not, sets one with the given value
	* The given value is Ignored if the parameter exist
	* @param	name	the name of the parameter
	* @param	value	a default value
	*/
	public function getCreateParam(name:String, value:Object) {
		if (__parameters.isExist(name)) {
			var val:Object = getObject(name);
			return val;
		} else {
			return setParam(name, value);
		}
	}
	
	/**
	* easy way to access a parameter.
	*/
	public function __resolve(name:String):Object {
		return getObject(name);
	}
}
