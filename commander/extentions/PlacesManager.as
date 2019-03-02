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
import iap.commander.MovieClipCommander
class iap.commander.extentions.PlacesManager extends iap.services.MovieClipService
{
	private var __members:Array;
	private var __places:Array;
	private var __extantionTemplate:Object;
	function init(membersLinkageTemplate:String)
	{
		__members = new Array()
		__places = new Array()
		__commander._params.setParam("membersLinkageTemplate",membersLinkageTemplate)
		getPlaces()
	}
	
	public function clearMembers() {
		for (var o:String in __members) {
			__members[o].destroy();
		}
		__members = new Array();
	}
	
	public function addMember(memberLinkageNumber:Number, paramsDefinition:Object):MovieClipCommander {
		var template:String = __commander._params.getString("membersLinkageTemplate");
		var linkage = template+memberLinkageNumber;
		var nextPlaceNum:Number = __members.length;
		var nextPlaceMc:MovieClip = __places[nextPlaceNum];
		
		var newMember:MovieClipCommander = new MovieClipCommander(nextPlaceMc, "member", 1, linkage);
		newMember._params.importObject(paramsDefinition);
		for(var o  in __extantionTemplate)	{
			newMember.registerExtention(o,__extantionTemplate[o])
		}
		
		__members.push(newMember);
		return newMember
	}
	
	private function getPlaces() {
		__places = new Array();
		
		var flag:Boolean = true
		for (var i =0; flag; i++) {
			var placeClip:MovieClip = __clip["place"+i];
			placeClip.mark.unloadMovie()
			if (placeClip == undefined) {
				flag = false;
			} else {
				__places.push(placeClip);
			}
		}
	}
	
	public function setExtantions(o:Object)	{
		__extantionTemplate = o
	}
	
	public function get _members():Array {
		return __members
	}
}
