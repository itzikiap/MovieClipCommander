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
 import iap.hash.MultipleHash;
import iap.app.extentions.Information;

/**
* A global static function to manage data flow with all the MovieClipCommanders
* The concept is to register each Information class instance to listen to a specific
* parameter change in this function
* must call "init" as the first command
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.GlobalParams {
	private static var __parameters:MultipleHash;

	/**
	* a function to initialize the variables
	*/
	public static function init() {
		__parameters = new MultipleHash();
	}
	
	/**
	* register a _params instance with a param change event
	* @param	paramName	the name of the parameter to register
	* @param	infoClassRef	a refferance to the Information instance
	* @return	the parameter value	*/
	public static function registerParam(paramName:String, infoClassRef:Information):Object {
		if (__parameters == undefined) {
			init();
		}
		__parameters.addItem(paramName, infoClassRef);
		if (__parameters.getItem(paramName) == undefined) {
			trace("~3WARNING: GlobalParams: registring undefined param: "+[paramName, infoClassRef, __parameters.getItem(paramName)]);
		}
		infoClassRef.registerGlobalParam(paramName, true);
		return	getParam(paramName);
	}
	
	/**
	* register a Information class with a set of parameters
	* @param	parametersArray	an array with all the parameters to register to this class
	* @param	infoClassRef	the instance that listen to all the parameter changes
	*/
	public static function registerParamsSet(parametersArray:Array, infoClassRef:Information) {
		for (var o:String in parametersArray) {
			registerParam(parametersArray[o], infoClassRef);
		}
	}
	
	/**
	* sets the parameter, calls each of the registered classes for that param
	* @param	paramName	the name of the parameter to change
	* @param	value	the new value
	* @param	callerParam	a refferance to the class that called this, to prevent circular calling
	*/
	public static function setParam(paramName:String, value:Object, callerParam:Information) {
//		trace("set param: "+[paramName,__parameters.getItem(paramName)]);
		var registered:Array = Array(__parameters.getItem(paramName));
		if (registered == null) {
			trace("~5ERROR: GlobalParam: set param name: '"+paramName+"' with no registered listeners");
		} else {
			for (var o:String in registered) {
				if (registered[o] != callerParam) {
					Information(registered[o]).setParam(paramName, value, "flag");
				}
			}
		}
	}
	
	/**
	* gets the desired parameter as an Object
	* @param	paramName	the parameter name
	* @return	An object
	*/
	public static function getParam(paramName:String) {
		var registered:Array = Array(__parameters.getItem(paramName));
		if (registered == null) {
			//trace("~5ERROR: GlobalParam: Get param name: '"+paramName+"' with no registered listeners");
			return undefined;
		} else {
			return Information(registered[0]).getObject(paramName);
		}
	}
	
	/**
	* traces all the listeners to a global param
	* @param	targetParam	a target param to 
	* @param	caller	for better debugging, a refference to whom called this function
	*/
	public static function debugTraceTarget(targetParam:String, caller:Object) {
		trace("~2-------------- GlobalParam tracing listeners to param: "+targetParam+((caller == undefined)? "": " from "+caller));
		var registered:Array = Array(__parameters.getItem(targetParam));
		for (var o:String in registered) {
			trace(" -> "+o+": "+registered[o]);
		}
		trace("~2-------------- Done tracing: "+registered.length+" entries.");
	}
}
