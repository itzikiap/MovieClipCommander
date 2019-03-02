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
 * * IndexHash, Version 1
 * Description:	provides a basic name based hashing and data collection
 * 				also support multiple data on the same index name (with an aray)
 *              future planes: -seperate basic hashing and duplicate hashing
 *                             -seperate "data" handling and "classes" handling
 *
 * @author      I.A.P Itzik Arzoni (itzikiap@gmail.com)
 * @version		1
 */

class iap.hash.MultipleHash extends iap.basic.IndexedHash{
	private var __allowDuplicates:Boolean;
	
    /**
    * Const the multiple hash
    */
    public function MultipleHash() {
		super();
        __allowDuplicates = true;
    }

	/**
	* addItem: Adds item.
	* creates an array with a key (if it doesn't exist) and 
	* @param	key the key to store the items in
	* @param	item the data
	* @return	number of items on the key
	*/
    public function addItem(key:String,item:Object):Number {
		var ret:Number = 0;
		if (__embedKey) {
			item.id = key;
		}
		ret = addItemToExsisting(key,item);
		__lastKey = key;
		return ret;
		
    }

	/**
	* gets one item based on its key and number
	* If item nunmber ommited it returns an array with all the items of that key
	* deppending if there is only one item.
	* @param	key the key of the item to retrive
	* @return 	the item or array or undefined if no item founed
	*/
    public function getItem(key:String,itemNum:Number):Object {
		if (isExist(key,itemNum)) {
			__lastKey = key;
			if (itemNum != undefined) {
				return __data[key][itemNum];
			} else {
				var item:Array = __data[key];
				if (item.length > 0) {
					return __data[key];
				}
			}
		} else {
			return undefined
		}
    }

	/**
	* removes item from the hash
	* @param	key	the name of the key
	* @param	itemNum	the number of item to remove from this key
	* @return the removed item or false if wasn't exist
	*/
    public function removeItem(key:String,itemNum:Number):Object {
		if (isExist(key,itemNum)) {
			var item:Object;
			if (__allowDuplicates) {
				item = removeDuplicateItems(key,itemNum);
			} else {
				item = __data[key];
				delete __data[key];
			}
			return item;
		} else {
			return false
		}
	}

	/**
	* checks if current index exist
	* @param	key	the name of the key
	* @param	itemNum if omitted, checks the whole key. if exist checks the specified index inside the key
	* @return   true if found
	*/
	public function isExist(key:String,itemNum:Number):Boolean {
		var ret:Boolean = false;
		if (itemNum == undefined) {
			if (__data[key] != undefined) {
				ret = true;
			}
		} else {
			if (__data[key][itemNum] != undefined) {
				ret = true;
			}
		}
		return ret;
	}

	/**
	* removes one or all duplicate items if __aloowDuplicates is on
	* @param	key	the naem of the key
	* @param	itemNum if omitted, removes all and delete the key
	* @return   the last item removed (in case of removing all of them, is the last to be added)
	*/
    private function removeDuplicateItems(key:String,itemNum:Number):Object {
		var item:Object;
        if (itemNum != undefined) {
            item = removeDuplicateItem(key,itemNum);
        } else {
            var itemArr = __data[key]
            var itemsCount = itemArr.length;
            for (var i = itemsCount; i>0; i--) {
                item = removeDuplicateItem(key,0);
            }
        }
        if (__data[key].length == 0) {
            delete __data[key];
        }
		return item
    }

	/**
	* removes one duplicate item (duplicate item is an item that shares the same key with oters)
	* @param	key	the name of the key
	* @param	itemNum	the item to remove
	* @return   the removed item
	*/
    private function removeDuplicateItem(key:String,itemNum:Number):Object {
        var itemArr = __data[key];
		var item = itemArr[itemNum];
        itemArr.splice(itemNum,1);
		return item;
    }

	/**
	* for duplicate proccessing
	* @param	key	the name of the key
	* @param	item	the item to add
	* @return	number of items in specified key
	*/
    private function addItemToExsisting(key:String,item:Object):Number {
        if (__data[key] == undefined) {
            __data[key] = new Array();
        }
		var itemsArr:Array = __data[key];
		for (var o:String in itemsArr) {
			if (itemsArr[o] == item) {
				return __data[key].length;
			}
		}
        __data[key].push(item);
		return __data[key].length;
    }


	/**
	* The default beaviour of MultipleHash is to allow duplicates
	*/
    public function set allowDuplicates(newVal:Boolean) {
        __allowDuplicates = newVal;
    }
	public function get allowDuplicates():Boolean {
		return __allowDuplicates;
	}
}
