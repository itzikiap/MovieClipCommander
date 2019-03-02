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
* A general function handler, right now it ment for delegation purposes
* gives the ability to save a function with arguments and scope to execute
* @author I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.functionUtils.FunctionHandler  extends iap.basic.UniqeElement{
	private var __scope:Object;
	private var __functionDelegate:Function;
	private var __arguments:Array;

	/**
	* create on wrapper of a function with scope and arguments
	* @param	scope
	* @param	func
	* @param	args	in the form of an array
	*/
	public function FunctionHandler(scope:Object,func:Function,args:Array) {
		__scope = scope;
		__functionDelegate = func;
		__arguments = new Array();
		if (args.length > 0){
			__arguments = __arguments.concat(args);
		}
	}

	/**
	* calls the function with saved scope
	*/
	public function execute() {
		var args:Array;
		args = __arguments.concat(arguments);
		__functionDelegate.apply(__scope,args);
	}

	/**
	* calls the function with a different scope and arguments
	* @param	newScope
	* @param	functionArgs
	*/
	public function exeuteToScope(newScope:Object,functionArgs:Array){
		var lastScope = __scope;
		__scope = newScope;
		execute(functionArgs);
		__scope = lastScope;
	}

	/**
	* static function to quickly create a function handler.
	* @param	scope
	* @param	func
	* @param	args
	* @return	a refference to created function handler
	*/
	public static function create(scope:Object,func:Function,args:Array) : FunctionHandler {
		var funcHandle = new FunctionHandler(scope,func,args);
		return funcHandle.execute;
	}

	/**
	* get or set the scope to execute the function
	*/
	function set scope(newScope:Object) {
		__scope = newScope;
	}
    function get scope():Object {
        return __scope;
    }
	
	/**
	* get or set a new function with same scope
	*/
	public function set execFunc(newFunc:Function) {
		  __functionDelegate = newFunc;
	}
	
	public function get execFunc():Function {
		return __functionDelegate;
	}

	/**
	* change the arguments
	*/
    function set args(newArgs:Array) {
        __arguments = newArgs;
    }
	
    function get args():Array {
        return __arguments;
    }
}
