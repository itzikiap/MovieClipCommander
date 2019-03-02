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
* provides a way to save the state of a movieclip like:
* selected - not selected
* moving - stoping - waiting
* All states are Strings or boolean
* dispatches two kinds of events:
* "stateChange" that contains in the evt info the "state" and "oldState"
* specific state event called by the name given to the service then _ then the string representation of the new state
* 
* Make sure to use one State service to each kind of states.
* Selecte/unselect cannot be with moving/stopping/waiting
* therefor, provide two "state" services to the commander with different names
* 
* the "init" funct6ion gets one argument: the first state.
* if not provided, then you'll need to change the state using "changeState" 
* wich will dispatch the events
* 
* @author I.A.P itzik arzoni (itzik.mcc@gmail.com)
* @version 1.0 12/03/2006
*/
class iap.commander.extentions.State extends iap.services.MovieClipService {
	static var TRUE:Number = 0;
	static var FALSE:Number = 1;
	
	private var __type:Number;
	
	private var __lastState:Number;
	private var __currentState:Number;
	
	public function init(firstState:Object) {
		__statesArray = states;
		__currentState = firstState;
		__lastState = firstState;
		__statesNames = new Object();
		for (var o:String in __statesArray) {
			__statesNames[o] = o;
		}
		__isBool = isBool;
	}
	
	/**
	* changes the state of the service
	* fires 2 kinds of events:
	* "stateChange" with this info in the evt:
	* 	-state:	the new state
	* 	-oldState: the old state
	* and an event named like this:
	* <service given name>+"_"+<state name>
	* 
	* for example, if the service name is "Selected" and is changes to "true"
	* the service name would be:
	* "Selected_true"
	* @param	newState	the new state. String or Boolean
	*/
	public function changeState(newState:Object) {
		dispatchEvent("stateChange", {state:newState, oldState:__lastState});
		dispatchEvent(_name+"_"+String(newState), {oldState:__lastState});
		__lastState = __currentState;
		__currentState = newState;
	}
	
	/**
	* changes or gets the state by assignment
	*/
	public function set state(newState:Object) {
		changeState(newState);
	}
	
	public function get state():Object {
		return __currentState;	
	}
}
