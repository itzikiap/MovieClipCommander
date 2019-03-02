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
* provides a basic structure for making each instance of a class have a unique ID
* ment to be extended
* @author I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.basic.UniqeElement {

	/**
	* unique ID of that class
	*/
    private var __id:Number;

	/**
	* counter for ID's
	*/
    private static var __idCounter:Number = 0;
	/**
	* saves all instances by ID for getElementById
	*/
    private static var indexArray:Array = [];

    /**
    * Constructor of unique element. 
    */
	public function UniqeElement() {
        __id = __idCounter;
        __idCounter++;
        indexArray[id] = this;
    }

    /**
    * return the instance by its ID
    * @param	idNum	the ID of the instance to fetch
    */
	public static function getElementById(idNum:Number) {
        return indexArray[idNum];
    }

	/**
	* gets the instance ID number
	*/
    function get id():Number {
        return __id;
    }
	
	function toString():String {
		return "[Uniqu ID: "+__id+"]";
	}
}