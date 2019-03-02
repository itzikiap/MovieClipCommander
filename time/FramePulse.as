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
 import iap.functionUtils.Delegate;
import iap.functionUtils.FunctionHandler;
import iap.basic.Counter;

/**
* A frame pulse executes a function or a set of functons every frame
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.time.FramePulse{
	private static var FRAME_DELAY_MC:MovieClip;
	
	private var __executionHandlers:Array;
	private var __running:Boolean;
	private var __numOfHandlers:Number;
	private var __counter:Counter;

	private var __frameDelayMc:MovieClip;
	private static var __clipInitDepth:Number = 1;

	/**
	* for fast execution, arguments can be applyied
	* if arguments are give, one command would be executed next frame
	* @param	scope	the scope of the function
	* @param	func	the function to be executed
	* @param	args	arguments to be passed to the function BEFORE the default "count"
	* @param	autoRun	If true, run the command next frame
	*/
	public function FramePulse(scope:Object,func:Function,args:Array,autoRun:Boolean, limit:Number) {
		init();
		if (func == undefined) {
			if (autoRun == undefined) {
				autoRun = false;
			}
		} else {
			if (autoRun == undefined) {
				autoRun =true;
			}
			addFunc(scope,func,args);
		}
		if (autoRun) {
			run(limit);
		}
	}

	private function init() {
		__running = false;
		__counter = new Counter(0,999999);
        __numOfHandlers = 0;
		__executionHandlers  = new Array();
		initDelayerClip();
	}
	
	/**
	* creates the delayClip in the _root
	*/
	private function initDelayerClip() {
		if (FRAME_DELAY_MC == undefined) {
			FRAME_DELAY_MC = _root.createEmptyMovieClip("__frameDelayMc", 16874+random(100));
		}
		__frameDelayMc = FRAME_DELAY_MC.createEmptyMovieClip("__frameDelayMc"+__clipInitDepth,__clipInitDepth);
		__clipInitDepth++;
	}

	/**
	* adds function to run one frame after all the other commands
	* @param	scope	the scope of the unction
	* @param	func	the function refferance
	* @param	args	optional arguments to be passed before the default "counter"
	* @return	the uniqe ID of that function
	*/
	public function addFunc(scope:Object,func:Function,args:Array):Number {
		var funcHandler:FunctionHandler = new FunctionHandler(scope,func,args);
		__numOfHandlers = __executionHandlers.push(funcHandler);
        return funcHandler.id
	}
	
	/**
	* replaces a previous function by another one
	* if "fucId" is omitted, then all functions added untill now are replaced
	* if "args" is omitted, new function will not be passed the old args
	* @param	funcId	(optional) the id of  previos function
	* @param	scope	(optional) change the function scope
	* @param	func	(optional)change the function refferance
	* @param	args	(optional) optional arguments to be passed to function
	* @return	the function Id
	*/
	public function replaceFunc(funcId:Number, scope:Object, func:Function, args:Array):Number {
		var ret:Number = 0;
		if (funcId == -1 || funcId == undefined || funcId == null) {
			__executionHandlers = new Array();
			__numOfHandlers = 0;
			ret = addFunc(scope, func, args);
		} else {
			var funcHandler:FunctionHandler = FunctionHandler.getElementById(funcId);
			if (scope != undefined || scope != null) {
				funcHandler.scope = scope;
			}
			if (func != undefined || func != null) {
				funcHandler.execFunc = func;
			}
			funcHandler.args = args;
			ret = funcId;
		}
		return ret
	}

	/**
	* remove a function from the list by its ID
	* @param	funcId
	* @return	if the function was exist and removed
	*/
    private function removeFunc(funcId:Number):Boolean {
        var ret:Boolean = false;
        for (var o in __executionHandlers) {
            if (__executionHandlers[o].id == funcId) {
                __executionHandlers[o].splice(o,1);
                __numOfHandlers--
                ret = true;
                break;
            }
        }
        return ret;
    }
	
	/**
	* clears the functions list
	*/
	public function clearFuncList() {
		abort();
		__executionHandlers = new Array();
		__numOfHandlers = 0;
	}

	/**
	* starts the frames loop
	* @param	limit	how many loops to run
	*/
	public function run(limit:Number) {
		initEnterFrame();
        __running = true;
		if (limit!= undefined) {
			__counter.max = limit;
		}
	}

	/**
	* stops the frames loop
	*/
	public function abort() {
		if (__running) {
			destroyEnterFrame();
			__counter.reset();
			__running = false;
       		}
		__counter.max = 999999;
	}

	private function initEnterFrame() {
		if (__running) {
			abort();
		}
		__frameDelayMc.onEnterFrame = Delegate.create(this,frameDelayFunction);
	}

	private function destroyEnterFrame() {
		delete __frameDelayMc.onEnterFrame;
	}

	private function frameDelayFunction() {
		var count:Number = __counter.value;
		var final:Boolean = __counter.inc();
		for (var o:String in __executionHandlers) {
			__executionHandlers[o].execute(count, final);
		}
		if (final) {
			abort();
		}
	}
}