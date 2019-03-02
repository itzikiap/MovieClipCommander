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

interface iap.app.extentions.sequences.IAnimationStep {
	function defineStep(extentionName:String, command:String, args:Array, event:String);
	function execute(commander:ICommander):ICommander;
	
	function verifyEvent(evt:Object):Boolean;
	function getEvent():String;
	function getCommander(commander:ICommander):ICommander;
	function getCustomeCommander():ICommander;
	function setCustomeCommander(val:ICommander);
}
