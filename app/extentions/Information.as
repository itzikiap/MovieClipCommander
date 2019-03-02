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
* Information and parameter extention for AppCommander
* ----------------------------------------------------
* provides a way to save information related to the MovieClipCommander
* This information is shared with all extentions and off coarse outside
* 
* dispatches param change event:
* 	paramChange - 
* 		extra info: {name: parameter name, value:new value}
*HISTORY:
* 	V1.0
* 	  -support dispatch events
* 	V2.0
* 	  -Generlized to work with AppCommander (Before was MovieClipCommander)
* 
* @author I.A.P itzik arzoni (itzik.mcc@gmail.com)
* @version 2.0
*/
class iap.app.extentions.Information extends iap.services.Service {
	private var __parameters:IndexedHash;
	private var __globalParam:Object;
	
	public function init(initParams:Object) {
//		trace("param init");
		__parameters = new IndexedHash();
		__parameters.importObject(initParams);
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
		//trace("setting param: "+[__commander,name,value]);
		if (value != undefined) {
			var oldVal:Object = __parameters.getItem(name);
			if (value != oldVal) {
				__parameters.addItem(name, value);
				dispatchEvent("paramChange", {name:name, value:value});
				// calling from "GlobalParam" gets an extra parameter to prevent feedback.
				if (__globalParam[name] && arguments[2] == undefined) {
					GlobalParams.setParam(name, value, this);
				}
			}
		} else {
			trace("~5ERROR:"+__commander+" attempt to setParam ("+name+") with undefined value. Operation ignored. ");
		}
		return value;
	}
	
	/**
	* set the Information class to register itself to GlobalParams class
	* with a specific parameter.
	* That way, each change of the parameter in the global param, will reflect here
	* Called from external extention or class, [B]and[/B] from GlobalParams
	* @param	paramName	the parameter to register
	* @param	noFeedBack	set this to true, only to prevent loop calling to GlobalParams
	*/
	public function registerGlobalParam(paramName:String, noFeedBack:Boolean) {
		if (!(noFeedBack == true)) {
			var value:Object = GlobalParams.registerParam(paramName, this);
			if (value != undefined) {
				setParam(paramName, GlobalParams.registerParam(paramName, this));
			}
		}
		__globalParam[paramName] = true;
	}
	
	/**
	* get the parameter as a generic object, no type casting
	* @param	name	parameter name
	* @return	object as the value, false if not exist
	*/
	public function getObject(name:String):Object {
		return getParam(name);
	}

	/**
	* get the parameter as a generic object, no type casting
	* @param	name	parameter name
	* @return	object as the value, false if not exist
	*/
	public function getParam(name:String) {
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
	* @return	String of value. empty string if not exist
	*/
	public function getString(name:String):String {
		var ret:String = __parameters.getItem(name).toString();
		return (ret == undefined)? "":ret;
	}
	
	/**
	* get prameter stored as XML
	* ONLY work for stored XML objects, does not convert.
	* @param	name	parameter name
	* @return	The XML
	*/
	public function getXML(name:String):XMLNode {
		var ret:XMLNode = getParam(name);
		return ret;
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
		var lcVal:String = val.toLowerCase();
		if (val == true || lcVal == "true" || lcVal == "yes" || lcVal == "on" || lcVal == "positive" || val > 0) {
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
		var item = __parameters.getItem(name);
		var ret:Array;
		if (item instanceof Array) {
			ret = item;
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
	* gets an untyped parameter from GlobalParams
	* @param	name	the parameter name
	* @return	the untyped parameter value
	*/
	public function getGlobalParam(name:String) {
		return GlobalParams.getParam(name);
	}
	
	/**
	* set a new parameter based on a parameter on global param
	* @param	name	the new param name
	* @param	globalParam	the global parameter name
	*/
	public function setParamFromGlobal(name:String, globalParam:String) {
		setParam(name, getGlobalParam(globalParam));
	}
	
	/**
	* import parameters from an Object data
	* @param	dataObject	the object to be imported
	*/
	public function importObject(dataObject:Object) {
		for (var o:String in dataObject) {
			setParam(o, dataObject[o]);
		}
	}
	
	/**
	* export the parameters to an object
	* @return	an object containing the parameters
	*/
	public function exportObject():Object {
		return __parameters.exportObject();
	}
	

	public function getTransferData():Object {
		var data:Object = exportObject();
		return data;
	}
	
	public function setTransferData(transferData:Object) {
		importObject(transferData);
	}


	/**
	* Traces all the params stored for debug purposes
	*/
	public function debugTrace() {
		trace("~2------------------_params trace for: "+__commander);
		var names:Array = __parameters.names;
		for (var o:String in names) {
			var pre:String = "- "+o+"  ";
			if (__globalParam[names[o]]) {
				pre+="(Global)";
			}
			trace("~2"+pre+names[o]+"\t= \t"+__parameters.getItem(names[o]));
		}
		trace("~2------------------"+__commander);
	}
}
