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
 import iap.app.groups.Group;
import iap.hash.ClassHash;
import iap.app.groups.IGroupMember;

/**
* This class gives a cross application group managment
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.groups.GroupsManager {
	private static var __groups:ClassHash;
	
	/**
	* initialize the group manager
	*/
	public static function initialize() {
		__groups = new ClassHash();
		__groups.initFunc = "registerGlobalGroup";
//		trace(__groups);
	}
	
	/**
	* join a member to the group
	* @param	member	a member
	* @param	groupName	the group to join
	* @return
	*/
	public static function joinToGroup(member:IGroupMember, groupName:String):Group {
		if (!__groups.isExist(groupName)) {
			var g = __groups.addClass(groupName, Group, [groupName]);
		}
		var g = __groups.getItem(groupName)
		var group:Group = Group(__groups.getItem(groupName));
		group.addMember(member);
		return group;
	}
	
	/**
	* retrive a group by its name
	* @param	groupName	the group name
	* @return	the group
	*/
	public static function getGroup(groupName:String):Group {
		var group:Group = Group(__groups.getItem(groupName));
		return group
	}
}
