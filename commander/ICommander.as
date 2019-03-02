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
 import iap.services.Service;

interface iap.commander.ICommander {
	public function registerExtention(name:String,extentionClass:Function,args:Array):Service;

	public function uniqueExtention(name:String, extentionClass:Function,args:Array):Service;

	public function removeExtention(name:String) ;
	
	public function dispatchEvent(eventInfo:Object, eventName:String):Boolean ;
	
	public function addEventListener(eventName:String, listener:Object);
	
	public function removeEventListener(eventName:String, listener:Object);
	
//	public function get _name():String;
//	
//	public function get _parent();
//	
//	public function get _commands():Object;
//	
//	public function get _params():iap.app.extentions.Information;
}
