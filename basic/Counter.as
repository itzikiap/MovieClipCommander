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
* Provides a counter that counts values
* Can be linked to another counter and inc/dec its value 
* whenever this counter riches its limits.
* At reach of maximum / minimum value its either stops there, or
* if linked counter is registered, it wraps to the opposing limit
* If requested (to save loops and stuff) it broadcast "change" event
* Changes:
* 	Version 2: 
* 		- broadcast on change event
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
* @version		2
*/

class iap.basic.Counter extends iap.events.EventsBroadcaster {
	/**
	* counterValueChange - dispatches when a value is changed 
	* ONLY IF REGISTRATION TO VALUE CHANGE IS REQUESTED
	* extra info: 
	* 	[B]value[/B] - the new value
	* 	[B]mined[/B] - does last operation reached the minimum
	* 	[B]maxed[/B] - does last operation reached the maximum
	*/
	static var EVT_VALUE_CHANGE:String = "counterValueChange"
	
	private var __min:Number;
	private var __max:Number;
	private var __next:Counter;
	private var __count:Number;
	private var __last:Number;
    private var __delta:Number;
    private var __lastOp:String;
	
	private var __requestBroadcast:Boolean;

	/**
	* construct the counter
	* @param	Nmin	the counters minimum value
	* @param	Nmax	the counter maximum value
	* @param	Nnext	(optional) link to the next counter
	*/
    function Counter(Nmin:Number,Nmax:Number,Nnext:Counter) {
		__requestBroadcast = false;
		if (Nmin != undefined) {
			init(Nmin, Nmax, Nnext);
		}
    }
	
	/**
	* initialize the counter
	* @param	Nmin	the counters minimum value
	* @param	Nmax	the counter maximum value
	* @param	Nnext	(optional) link to the next counter
	*/
	public function init(Nmin:Number,Nmax:Number,Nnext:Counter) {
	    __min = (Nmin == undefined) ? 0: Nmin;
        __max = (Nmax == undefined) ? Number.MAX_VALUE : Nmax; ;
        __count = __min;
	    link = Nnext;
        __delta = 1;
        __lastOp = "";
	}

	/**
	* increase the counter value
	* @return	true, if operation reached the max limit
	*/
    function inc():Boolean {
        var ret:Boolean = false;
		__last = __count;
        __lastOp = "";
        __count += __delta;
        if (__count >= __max) {
            __lastOp = "maxed"
            if (__next != undefined) {
                __next.inc();
                __count = __min;
            } else {
                __count = __max;
            }
            ret = true;
        }
		dispatchChange();
        return ret;
    }

	/**
	* decreese the counter value
	* @return	true, if counter reached its lower limit
	*/
    function dec():Boolean {
        var ret:Boolean = false;
		__last = __count;
        __lastOp = "";
        __count -= __delta;
        if (__count <= __min) {
            __lastOp = "mined";
            if (__next != undefined) {
                __next.dec();
                __count = __max;
            } else {
                __count = __min;
            }
            ret = true;
        } else if (__count == __min) {
			ret = true;
		}
		dispatchChange();
        return ret;
    }
	
	/**
	* dispatches the changed only if this operation required
	*/
	private function dispatchChange() {
		if (__requestBroadcast) {
			dispatchEvent({value:__count, mined:mined, maxed:maxed}, EVT_VALUE_CHANGE);
		}
	}
	
	/**
	* undo last operation
	* @return	the undoen value
	*/
	public function undo():Number {
		__count = __last;
		dispatchChange();
		return __count;
	}
	
	/**
	* resets the counter
	*/
	public function reset() {
		value = __min;
	}

	/**
	* How much will the counter increese
	*/
    function set delta(newDelta:Number) {
        __delta = newDelta;
    }

    function get delta():Number {
        return __delta;
    }

	/**
	* link to the next counter
	*/
    function set link(newLink:Counter) {
        __next = newLink;
    }

	/**
	* the counter's value
	*/
    function set value(newVal:Number) {
        // make sure counter withing range
		__last = __count;
        __count = Math.min(__max,Math.max(newVal,__min));
		dispatchChange();
    }

    function get value():Number {
        return __count;
    }

	/**
	* counter maximum limit
	*/
    function set max(newVal:Number) {
        __max = newVal;
        value = __count;
    }

    function get max():Number {
        return __max;
    }

	/**
	* counter minimum limit
	*/
    function set min(newVal:Number) {
        __min = newVal;
        value = __count;
    }

    function get min():Number {
        return __min;
    }
	
	/**
	* set to true to broadcast change event
	*/
	public function set broadcast(val:Boolean) {
		__requestBroadcast = val;
	}

    /**
    * check weather the last operation reached the maximum state
    */
    function get maxed():Boolean {
        return (__lastOp == "maxed");
    }

    /**
    * check weather the last operation reached the maximum state
    */
    function get mined():Boolean {
        return (__lastOp == "mined");
    }
}
