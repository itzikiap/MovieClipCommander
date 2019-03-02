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
 import iap.commander.ICommander;

class iap.app.extentions.sequences.SequenceStep implements iap.app.extentions.sequences.IAnimationStep{
	private var __extentionName:String;
	private var __command:String; 
	private var __arguments:Array;
	private var __event:String;
	private var __customeCommander:ICommander;
	private var __eventTest:Object;

	function SequenceStep(extentionName:String, command:String, args:Array, event:String, eventTest:Object) {
		defineStep(extentionName, command, args, event);
		__eventTest = eventTest
	}
	
	function defineStep(extentionName:String, command:String, args:Array, event:String) {
		__extentionName = extentionName;
		__command = command;
		__arguments = args;
		__event = event;
	}
	
	function execute(commander:ICommander):ICommander {
		commander = getCommander(commander);
		var scope:Object = commander["_commands"][__extentionName];
		scope[__command].apply(scope, __arguments);
		return commander;
	}
	
	function getCommander(commander:ICommander):ICommander {
		
		if (__customeCommander != undefined) {
			commander = __customeCommander;
		}
		return commander
	}
	
	function verifyEvent(evt:Object):Boolean {
		var ret:Boolean = true;
		for (var o:String in __eventTest) {
			if (evt[o] != __eventTest[o]) {
				ret = false;
				continue;
			}
		}
		return ret;
	}
	
	public function getEvent():String {
		return __event;
	}
	
	public function getCustomeCommander():ICommander	{
		return __customeCommander;
	}
	public function setCustomeCommander( val:ICommander )	{
		__customeCommander = val;
	}
	
	function toString():String {
		return "[SequenceStep "+__command+" in " + __extentionName+"]";
	}
}
