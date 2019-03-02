import iap.hash.MultipleHash;
import mx.events.EventDispatcher;

/**
* UNFINISHED!
*/
class iap.basic.GroupsManager extends org.as2lib.core.BasicClass {
	private var __groups:MultipleHash;
	
	var addEventListener:Function;
	var removeEventListener:Function;
	private var dispatchEvent:Function;
	
	function GroupsManager() {
		__groups = new MultipleHash();
		EventDispatcher.initialize(this);
	}
	
	function addToGroup(groupName:String, item:Object, state:Object):Number {
		__groups.addItem(groupName, item);
	}
	
	function changeState(groupName:String, item:Object, newState:String
}
