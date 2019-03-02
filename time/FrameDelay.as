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
* execute a set of commands in consequent frames
* each function given is executed in a different frame
* i.e. if 5 functions are given, they are executed in 5 frames one after another
* 
* @author I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
* @version 1.0
*/
class iap.time.FrameDelay extends iap.time.FramePulse {
    private var __delta:Counter;
	private var __frameDelta:Number;

	
	/**
	* constructor of the frame delay. can get arguments for auto run
	* @param	scope	the scope of the first function
	* @param	func	a refference to the function to run
	* @param	args	an array of arguments to pass to the function
	* @param	autoRun	set to true to auto execute the frame delay
	*/
	public function FrameDelay(scope:Object,func:Function,args:Array,autoRun:Boolean) {
		super(scope, func, args, autoRun, 1);
	}
	
	/**
	* initialize the frame delay
	*/
	private function init() {
		__delta = new Counter(0,0,__counter);
		super.init();
	}
	
	/**
	* creates an instance of the frame delay
	* @param	scope	the scope of the first function
	* @param	func	a refference to the function to run
	* @param	args	an array of arguments to pass to the function
	* @param	autoRun	set to true to auto execute the frame delay
	*/
	static function create(scope:Object,func:Function,args:Array,autoRun:Boolean) {
		return new FrameDelay(scope, func, args, autoRun);
	}
	
	/**
	* override the frame delay function as declared in FramePulse
	* This frame delay executes one function at a time and abort at end
	*/
	private function frameDelayFunction() {
		if (__delta.inc()) {
            __executionHandlers[__counter.value].execute(__counter.value);
            if (__counter.inc()) {
                abort();
            }
        }
	}
	
	/**
	* runs the frame delay
	*/
	function run() {
		super.run(__numOfHandlers);
	}
	
	/**
	* specify a number of frames between each execution
	*/
    function set delta(newDelta:Number) {
        __delta.max = newDelta;
    }

    function get delta():Number {
        return __delta.max;
    }
}