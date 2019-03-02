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
 import iap.basic.IndexedHash;
import iap.app.groups.IGroupMember;

/**
* manage one group
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.groups.Group {
	private var __name:String;
	private var __exlusiveStatus:Boolean;
	private var __selected:IGroupMember;
	private var __members:IndexedHash;
	
	/**
	* initialize the group
	* @param	gname	group name
	*/
	function Group(gname:String) {
		__name = gname;
		__members = new IndexedHash();
		__exlusiveStatus = false;
		__selected = null;
	}
	
	/**
	* register the group to be global
	* @param	name
	*/
	private function registerGlobalGroup(name:String) {
		__name = name;
	}
	
	/**
	* adds a member to the group
	* @param	member	must implement IGroupMember
	*/
	public function addMember(member:IGroupMember) {
		if (__members.isExist(member.getGroupId())) {
			trace("~5ERROR: addMember to group, Member: '"+member.getGroupId()+"' already exist in group: '"+__name+"'.");
		} else {
			__members.addItem(member.getGroupId(), member);
		}
	}
	
	/**
	* removes an item from group
	* @param	member	the member to be removed. NOT ITS NAME
	*/
	public function removeMember(member:IGroupMember) {
		if (!__members.isExist(member.getGroupId())) {
			trace("~5ERROR: removeMember from group, Member: '"+member.getGroupId()+"' does not exist in group: '"+__name+"'.");
		} else {
			__members.removeItem(member.getGroupId());
		}
	}
	
	/**
	* set a specific group member to its status
	* Usualy used by the member itself to set its status
	* @param	member	the member reference
	* @param	status	the status as an object (converted to string)
	*/
	public function setStatus(member:IGroupMember, status:Object) {
		member.setGroupStatus(String(status));
	}
	
	/**
	* select one member (set its status to true, and all the other to false)
	* usualy used by the member to select itself
	* @param	member	member reference
	* @param	status	the boolean, can be false, then only the single member is being changed
	*/
	public function select(member:IGroupMember, status:Boolean) {
		if (status) {
			__selected = member;
		}
		if (status && __exlusiveStatus) {
			var memberName:String = member.getGroupId();
//			trace("Group: "+__name+" notify "+status+" to: "+names);
			selectMember(memberName);
		} else {
			setStatus(member, status);
		}
	}
	
	/**
	* set a specific group member to its status
	* @param	member	the member name
	* @param	status	the status as an object (converted to string)
	*/
	public function setMemberStatus(memberName:String, status:Object) {
		var member:IGroupMember = IGroupMember(__members.getItem(memberName));
		setStatus(member, status);
	}
	
	/**
	* select one member (set its status to true, and all the other to false)
	* @param	member	member name
	*/
	public function selectMember(memberName:String) {
		var names:Array = __members.names;
		for (var o:String in names) {
			var vname:String = names[o];
			var toSelect:Boolean = (vname == memberName);
			var vmember:IGroupMember = IGroupMember(__members.getItem(vname));
			setStatus(vmember, toSelect);
		}
	}
	
	/**
	* If set to true, this group acts as a radio buttons set
	* Only one member can have a surtain status, like "selected"
	*/
	public function get exlusiveStatus():Boolean {
		return __exlusiveStatus;
	}
	public function set exlusiveStatus( val:Boolean ):Void {
		__exlusiveStatus = val;
	}
	
	/**
	* set or get the selected group member
	*/
	public function get selected():IGroupMember {
		return __selected;
	}
	public function set selected(member:IGroupMember) {
		select(member, true);
	}
	
	/**
	* retruns the group name
	*/
	public function get name():String {
		return __name;
	}
	
	function toString():String {
		return "[Group "+__name+"]";
	}
}
