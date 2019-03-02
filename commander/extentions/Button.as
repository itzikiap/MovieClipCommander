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
 import iap.app.extentions.Group;
import iap.commander.MovieClipCommander;
import iap.commander.extentions.Align;

/**
* Button component extention for MovieClipCommander
* This components does 3 things:
* Make the __clip behave like a button, by going to labels: "up", "down", "over".
* Send a click event, defaulted to send when onRelease, but can be changed to onRollOver, or whatever
* Combine with the Group extention to make several buttons behave as a radio button.
* 
* The button can be configured to be a double state, then it would look for the 
* "selected_up", "selected_down" and "selected_over" labels, if the button is selected.
* 
* init arguments: 
* @param id	define the ID of the button, usefull whith groups
* @param groupName	make the button part of a radio group, witch meens it is converted to doubleState
* 
* _params parameters:
* @param	buttonId	the ID of the button
* @param	click_triger	(default: "onRelease") when will the click event be sent
* @param	selected	if the button is selected. When set to true, in a group, all other of that group will be set to false
* @param	doubleState	is pressing on a button will change it "selected" state?
* @param	button_active	if the button is active or not active
* 
* @author Itzik Arzoni IAP (itzik.mcc@gmail.com)
*/

class iap.commander.extentions.Button extends iap.services.MovieClipService {
	/**
	* click - dispatches when the button is clicked.
	* extra info:
	* {[B]id[/B]:__buttonID, [B]group[/B]:__group.groupName, 
	* [B]selected[/B]:__selected, [B]grouped[/B]:(__group != undefined)}
	*/
	static var EVT_CLICK:String = "click";
	/**
	* buttonStateChange - dispatches when the state of the button was changed.
	* The button can have one of 6 states: "up", "down", "over" and "selected_up", "selected_down", "selected_over"
	* if [B]evt.handled[/B] is set - the extention will not handle the visuality of the state change
	* extra info:
	* [B]oldState[/B]: the old state
	* [B]state[/B]: the new state
	*/
	static var EVT_STATE_CHANGED:String = "buttonStateChange";
	
	static var PARAM_BUTTON_ID:String = "buttonId";
	static var PARAM_CLICK_TRIGGER:String = "click_triger"
	static var PARAM_SELECTED:String = "selected";
	static var PARAM_DOUBLE_STATE:String = "doubleState";
	static var PARAM_ACTIVE:String = "active";
	
	private var __doubleState:Boolean;
	private var __buttonID:String;
	private var __group:Group;
	private var __selected:Boolean;
	private var __buttonState:String;
	
	function init(btnId:String, groupName:String) {
		__doubleState = false;
		__selected = false;
		
		enableGroup(btnId, groupName);
		
		__commander.addEventListener("paramChange", this);
		
		__commander._params.setParam("click_trigger", "onRelease");
		__commander._params.setParam("selected", false);
		__commander._params.setParam("doubleState", false);
		__commander._params.setParam("button_active", true);
		setButtonLook("up");
	}
	
	/**
	* enables the group 
	* @param	id
	* @param	groupName
	*/
	public function enableGroup(btnId:String, groupName:String) {
		if (btnId != undefined) {
			__buttonID = String(__commander._params.setParam("buttonID", btnId));
		} else if (__buttonID == undefined) {
			__buttonID = String(__commander._params.getCreateParam("buttonID", _name+id));
		}
		if (groupName != undefined) {
			__group = Group(__commander.uniqueExtention(__buttonID, Group, [groupName, false]));
			__group.paramName = "selected";
			__group.exlusive = true;
			__commander._params.setParam("doubleState", true);
		}
	}
	
	/**
	* attaches a library asset to the button, streches it to feet 75% of the button, and centers it
	* @param	linkageName
	*/
	public function attachIcon(linkageName:String) {
		var icon:MovieClipCommander = MovieClipCommander(__commander.createChild("buttonIcon", __commander._depth.higher, linkageName));
		var align:Align = Align(icon.registerExtention("align", Align));
		align.sameSize(75);
		align.center();
	}
	
	/**
	* enables the button to recive click commands
	* @param	enable	if set to true, the button is enabled. false is not supported yet
	*/
	private function activateButton(enable:Boolean) {
		if (enable) {
			registerClipEvent("onRollOver", this);
			registerClipEvent("onRollOut", this);
			registerClipEvent("onPress", this);
			registerClipEvent("onRelease", this);
			registerClipEvent("onReleaseOutSide", this);
		} else {
			removeClipEvent("onRollOver", this);
			removeClipEvent("onRollOut", this);
			removeClipEvent("onPress", this);
			removeClipEvent("onRelease", this);
			removeClipEvent("onReleaseOutSide", this);
		}
	}
	
	/**
	* Handles the click event.
	* if no group and no double state, dispatches the event.
	* If there is a group defined, its dispatches the event and 
	* change the state of the button only if something was changed
	*/
	private function click() {
//		trace("~2button click: "+[this,__group , __buttonID]);
		if (__doubleState) {
			__commander._params.setParam("selected", !__selected);
		}
		dispatchClickEvent();
	}
	
	/**
	* dispatches the click event with all the informatein
	*/
	private function dispatchClickEvent() {
				dispatchEvent(EVT_CLICK, {id:__buttonID, group:__group.groupName, selected:__selected, grouped:(__group != undefined)});
	}
	
	/**
	* event handler
	*/
	private function handleEvent(evt:Object) {
		if (evt.type == __commander._params.getString("click_trigger")) {
			click();
		}
		switch (evt.type) {
			case "onRollOver":
				setButtonLook("over");
				break;
			case "onRollOut":
				setButtonLook("up");
				break;
			case "onPress":
				setButtonLook("down");
				break;
			case "onRelease":
				setButtonLook("up");
				break;
			case "onReleaseOutside":
				setButtonLook("up");
				break;
		}
	}
	
	private function paramChange(evt:Object) {
		//trace("~2Button Parameter change: "+[__commander, evt.name, evt.value]);
		switch (evt.name) {
			case PARAM_DOUBLE_STATE:
				__doubleState = evt.value;
				break;
			case PARAM_SELECTED:
				__selected = evt.value;
				setButtonLook("up");
				break;
			case PARAM_BUTTON_ID:
				__buttonID = evt.value;
				__group.getGroupId(__buttonID);
				break;
			case PARAM_ACTIVE:
				activateButton(evt.value);
				break;
		}
	}
	
	/**
	* sets the button look (state) - only if EVT_STATE_CHANGE was not handeled
	* @param	mode	the new state
	*/
	public function setButtonLook(mode:String) {
		var prefix:String = (__selected)? "selected_":"";
		mode = prefix + mode;
		if (!dispatchEvent(EVT_STATE_CHANGED, {state:mode, oldState:__buttonState})) {
			__clip.gotoAndStop(mode);
		}
		__buttonState = mode;
	}
}
