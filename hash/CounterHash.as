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
 

import iap.basic.Counter;
/**
* a collection of counters
* @author I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
* @version 1.0
*/

class iap.hash.CounterHash extends iap.hash.ClassHash {
	private var __prefix:String;
	
	public function CounterHash() {
		super();
		__prefix = "";
		initFunc = "init";
	}

	/**
	* add a named counter to the list
	* @param	name
	* @param	min
	* @param	max
	* @return refferance to the counter
	*/
	public function addCounter(name:String,min:Number,max:Number):Counter {
		var ret:Counter = Counter(addClass(__prefix+name,Counter,[min,max]));
		return ret;
	}
	
	/**
	* increese the value of a named counter
	* @param	key
	* @return	true if reached max
	*/
	public function inc(key:String):Boolean {
		var _counter:Counter = Counter(getItem(__prefix+key));
		var ret:Boolean = _counter.inc();
		return ret;
	}
	
	/**
	* decrease the value of a named counter
	* @param	key
	* @return	true if reached min
	*/
	public function dec(key:String):Boolean {
		var _counter:Counter = getCounter(key);
		var ret:Boolean = _counter.dec();
		return ret;
	}
	
	/**
	* return a counter object by its name
	* @param	key	the name for the counter
	* @return	refference to the counter
	*/
	public function getCounter(key:String):Counter {
		var _counter:Counter = Counter(getItem(__prefix + key));
		return _counter
	}
	
	/**
	* gets the value of a counter by key
	* @param	key
	* @return	the value of one counter
	*/
	public function getValue(key:String):Number {
		return getCounter(key).value;
	}
}