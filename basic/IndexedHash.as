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
 * IndexHash, Version 1
 * Description:	provides a basic name based hashing and data collection
 * 				also support multiple data on the same index name (with an aray)
 *              future planes: -seperate basic hashing and duplicate hashing
 *                             -seperate "data" handling and "classes" handling
 * Last modified:	08/02/2006 13:0
 * Changes:
 *   +getItem now returns undefined instead of false if no item exist
 *
 * @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
 * @version		1
 */

class iap.basic.IndexedHash{

	/**
	* the main data holder
	*/
    private var __data:Object;
	/**
	* number of items
	*/
    private var __itemsCount:Number;

	/**
	* saved the last created/accessed/deleted index
	*/
	private var __lastKey:String;

	/**
	* saved the last created/accessed/deleted item (for speed, mainly)
	*/
	private var __lastItem:Object;

	/**
	* to embed the key into the data added
	* i.e: newItem.id = key
	*/
    private var __embedKey:Boolean;

    /**
    * Constructor
    */
    public function IndexedHash() {
        __data = new Object();
        __lastKey = "";
		__lastItem = new Object();
        __itemsCount = 0;
        __embedKey = false;
    }

	/**
	* addItem: Adds item
	* if item exist, it gets overriden
	* @param	key the key to store the items in
	* @param	item the data
	* @return	if item was exist before adding.
	*/
    public function addItem(key:String,item:Object):Boolean {
		var ret:Boolean = isExist(key);
        if (__embedKey) {
            item.id = key;
        }
		__data[key] = item;
		if (!ret) __itemsCount++;
		_lastKey = key;
//		trace("adding item: "+[key, __data[key]]);
		return ret;
    }

	/**
	* gets one item based on its key
	* @param	key the key of the item to retrive
	* @return the item or undefined if no item founed
	*/
    public function getItem(key:String) {
		return __data[key];
    }

	/**
	* removes item from the hash
	* @param	key	the name of the item to remove
	* @return the removed item or false if wasn't exist
	*/
    public function removeItem(key:String):Object {
		if (isExist(key)) {
			var item:Object;
			item = __data[key];
			delete __data[key];
			__itemsCount--;
			return item;
		} else {
			return undefined
		}
	}

	/**
	* replaceItem, if item does not exist - it does not creates one
	* @param	key
	* @return	the removed key, or false if nothing performed
	*/
	public function replaceItem(key:String, value:Object):Object {
		var item:Object = removeItem(key);
		if (item != false) addItem(key,value);
		return item;
	}
	/**
	* checks if current index exist
	* @param	key
	* @param	itemNum if omitted, checks the whole key. if exist checks the specified index inside the key
	* @return   true if found
	*/
	public function isExist(key:String):Boolean {
		var ret:Boolean = true;
		var item = __data[key];
		
		if (item == undefined) {
			ret = false;
		} else {
			__lastKey = key;
			__lastItem = item;
		}
//		trace("indexed hash - is exist "+[key, ret]);
		return ret;
	}

	/**
	* return the name of a given object if it exist in the hash
	* @param	objToFind
	* @return
	*/
	public function getName(objToFind:Object):String {
		if (__embedKey) {
			return objToFind.id;
		}
		var items:Array = names;
		var foundName:String;
		for (var o in items) {
			if (__data[items[o]] == objToFind) {
				foundName = items[o];
			}
		}
		return foundName;
	}
	
	/**
	* import a set of "key - data" from an object
	* @param	inputObj	the source object
	* @param	fromNew		destroy all the previous keys
	* @return	number of keys
	*/
	public function importObject(inputObj:Object, fromNew:Boolean):Number {
		if (fromNew == true) {
			destroy();
		}
		for (var o:String in inputObj) {
			addItem(o,inputObj[o]);
		}
		return __itemsCount;
	}
	
	/**
	* export the hash to an object
	* @return	plain object containing the hash
	*/
	public function exportObject():Object {
		var data:Object  = new Object();
		for (var o:String in __data) {
			data[o] = __data[o];
		}
		return data;
	}
	
	public function destroy() {
		__data = new Object();
		__itemsCount = 0;
		__lastKey = "";
	}

	/**
	* getter setter section
	*/
    function set embedKey(newVal:Boolean) {
        __embedKey = newVal;
    }

    function get embedKey():Boolean {
        return __embedKey;
    }

	public function get _count():Number {
		return __itemsCount;
	}

	/**
	* return the names of the data elements
	* @return an array of the names
	*/
	public function get names():Array {
		var ret:Array = new Array();
		for (var o in __data) {
			ret.unshift(o);
		}
		return ret;
	}
	
	public function set _lastKey (val:String) {
		__lastKey = val;
		__lastItem = getItem(val);
	}
	
	public function get _lastKey():String {
		return __lastKey;
	}

	public function get _lastItem():Object {
		return __lastItem;
	}
}
