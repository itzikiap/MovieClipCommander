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
 //import mx.events.EventDispatcher;
//import mx.utils.Delegate;
import iap.basic.IndexedHash;

/**
 * ExtentionManager, Version 1.1
 * Open Architecture Enabled
 * Description:		A utility class core class to enable a managment of "plugins" or "extentions"
 * 				to classes that inherits from it
 *              Notice that this class is mostly static, and is ment for other classes to inherit
 * Last modified:	Now
 *
 * @author      Itzik I.A.P
 * @version		1
 */


 class iap.services.ExtentionManager{
    // an Index object for all extentions
    private var __extentions:IndexedHash;

    // empty constructor
    public function ExtentionHandeler() {
    }

  	/**
	* register one extention
	*
	* @param 	extentionName		the name of the extention
	* @param	extentionConstructor	 	a refferance to the extention constructor. must inherit from "LoaderExtention" class
	*/
    public function registerExtention(extentionName:String,extentionConstructor:Function) {
        var extentionObj:Object = new Object();
        var extentionExist:Boolean = isExtentionExist(extentionName);
        if (!extentionExist) {
            extentionObj.name = extentionName;
            extentionObj.handler = extentionConstructor;
            addExtention(extentionObj);
        }
    }

  	/**
	* get the refferance to the extention constructor
	*
	* @param 	extentionName		the name of the extention
	* @return	if exist: refferance to the extention constructor. if not: undefined
	*/
    public function getExtention(extentionName:String):Function {
        if (isExtentionExist(extentionName)) {
			var ret:Function = Function(extentions.getItem(extentionName));
            return ret;
        } else {
            return undefined;
        }
    }

    // internal "add" extention
    private function addExtention(extentionObj:Object) {
        __extentions.addItem(extentionObj.name,extentionObj.handler);
    }

  	/**
	* check if extention exist
	* @param 	extentionName		the name of the extention
	* @return	if exist: true if not: false
	*/
    public function isExtentionExist(extentionName:String):Boolean {
		var extentionExist:Boolean = extentions.isExist(extentionName);
        return extentionExist;
    }

    /**
    * get the extentions index
    */
    public function get extentions():IndexedHash {
		if (__extentions == undefined) {
			__extentions = new IndexedHash();
		}
        return __extentions;
    }
}
