/**
* IteratorHash version 1
* Description: Uses the Index hash to iterate thrugh the values
* 			use "firstItem" to reset the iteration and return the first value
* 			use "nextItem" to each time get the next item. return undefined at end
* last modified: 24/12/2006 11:49
*
* @author      I.A.P Itzik Arzoni (itzikiap@gmail.com)
* @version		1
*/
class iap.hash.IteratorHash extends iap.basic.IndexedHash {
	private var __lastIndex:Number;
	private var __names:Array;
	
	function IteratorHash()	{
		__lastIndex = 0;
		__names = new Array();
	}
	
	/**
	* addItem: Adds item
	* if item exist, it gets overriden
	* @param	key the key to store the items in
	* @param	item the data
	* @return	if item was exist before adding.
	*/
    public function addItem(key:String,item:Object):Boolean {
		var ret:Boolean = addItem(key, item);
		if (!ret) {
			__names = names;
			firstItem();
		}
		return ret;
	}
	
	
	/**
	* removes item from the hash
	* @param	key	the name of the item to remove
	* @return the removed item or false if wasn't exist
	*/
    public function removeItem(key:String):Object {
		var ret:Boolean = removeItem(key, item);
		if (!ret) {
			__names = names;
			firstItem();
		}
		return ret;
	}
	
	/**
	* return the first item in the iteration
	* @return	an object of the first item
	*/
	public function firstItem():Object {
		__names = names;
		setIndex(0);
		return __lastItem
	}
	
	/**
	* return the next item in the iteration
	* @return	an object of the item in the next index
	*/
	public function nextItem():Object {
		setIndex(__lastIndex +1);
		return __lastIndex;
	}
	
	/**
	* sets the index
	* @param	val	the new index value
	*/
	private function setIndex(val:Number) {
		__lastIndex = val;
		__lastKey = __names[val];
		__lastItem = __names[__lastKey];
	}
}
