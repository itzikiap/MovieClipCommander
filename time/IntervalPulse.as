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
 import iap.events.EventDispatcher;
/**
* Description here...
* @author I.A.P Itzik Arzoni @gmail.com)
* @version 1.0
*/

class iap.time.IntervalPulse extends iap.time.Timer {
	private var __intervalId:Number;
	private var __intervalTime:Number;
	private var __cycles:Number;
	private var __cyclesLimit:Number;
	private var __callObject:Object;
	private var __callFunction:String;
	private var __running:Boolean;
	
	
	
	private var __costumeScope:Object;
	private var __costumeFunction:String;
	private var __costumeArguments:Array;

	
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;

	public function IntervalPulse(costumeObj:Object, costumeFunction:String, interval:Number, limit:Number, args:Array) {
		super();
		__cycles = 0;
		EventDispatcher.initialize(this);
		setFunction(this,"intervalDispatcher");
		if (costumeFunction != undefined) {
			__costumeScope = costumeObj;
			__costumeFunction = costumeFunction;
			__costumeArguments = args;
			setFunction(this,"doIntervalPulse");
			if (interval != undefined) {
				startPulse(interval,limit);
			}
		}
	}
	
	static function create(costumeObj:Object, costumeFunction:String, interval:Number, limit:Number, args:Array):IntervalPulse {
		var newInterval = new IntervalPulse(costumeObj, costumeFunction, interval, limit, args);
		return newInterval;
	}
	/**
	* this function sets a custom function to be a callback function when the pulse is dispatched
	* @param	objRef	the refferance to the object (scope)
	* @param	funcName	
	* @param	args
	*/
	public function customCallBack(objRef:Object, funcName:String, args:Array) {
		__costumeScope = objRef;
		__costumeFunction = funcName;
		__costumeArguments = args;
		setFunction(this,"doIntervalPulse");
	}
	
	private function setFunction(objRef:Object,funcName:String) {
		stopPulse();
		__callObject = objRef;
		__callFunction = funcName;
	}
	
	/**	starts the interval, if limit < 0 then the interval will
	 *  be infinite. 
	 *
	 * @param	interval	- The time in miliseconds between every execution 	
	 * @param	limit		- The number of Iterations to start
	 */
	public function startPulse(interval:Number,limit:Number) {

		if (interval == undefined) {
			interval = __intervalTime;
		}
		__intervalTime = interval;
		if (limit == undefined) {
			limit = __cyclesLimit;
		}
		reset();
		clearInterval(__intervalId);
		__running = true;
		if (limit > 0){
			__cyclesLimit = limit+__cycles;
		}else{
			__cyclesLimit = -1;
		}
		__intervalId = setInterval(__callObject,__callFunction,interval,__costumeArguments);
	}
	
	private function intervalDispatcher() {
		var evt:Object = new Object();
		evt.type = "timerPulse"
		evt.target = this;
		dispatchEvent(evt);
		if (++__cycles == __cyclesLimit) {
			stopPulse();
		}
	}
	
	private function doIntervalPulse() {
		var last:Boolean = (++__cycles == __cyclesLimit);
		if (last) {
			stopPulse();
		}
		__costumeScope[__costumeFunction].apply(__costumeScope,__costumeArguments.concat([this,last]));
	}
	
	/** stop the current running interval pulse
	  *
	  */
	public function stopPulse() {
		clearInterval(__intervalId);
//		reset();
//		pause();
		__running = false;
		var evt:Object = new Object();
		evt.type = "stopPulse";
		evt.target = this;
		dispatchEvent(evt);
	}
	
	public function reset() {
		super.reset();
		stopPulse();
		__cycles = 0;
	}
	
	public function toString():String {
		return "[IntervalPulse "+__cycles+"]"
	}
	
//{ GETTER-SETTER
	public function set cyclesLimit(limit:Number) {
		__cyclesLimit = int(limit);
	}
	
	public function get cyclesLimit():Number {
		return __cyclesLimit;
	}
	
	public function set cycles(num:Number) {
		__cycles = int(num);
	}
	
	public function get cycles():Number {
		return __cycles;
	}

	public function get _running() {
		return __running;
	}
	/**
	* set/get a costume scope to run
	*/
	public function set _costumeScope(p_costumeScope:Object) {
		this.__costumeScope = p_costumeScope;
	}
	/**
	* a costume function to run
	*/
	public function set _costumeFunction(p_costumeFunction:String) {
		this.__costumeFunction = p_costumeFunction;
	}
	/**
	* costume arguments to send to the function
	*/
	public function set _costumeArguments(p_costumeArguments:Array) {
		this.__costumeArguments = p_costumeArguments;
	}
	public function get _costumeScope():Object {
		return this.__costumeScope;
	}
	public function get _costumeFunction():String {
		return this.__costumeFunction;
	}
	public function get _costumeArguments():Array {
		return this.__costumeArguments;
	}
//}
}