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

/**
* Key based hashing to XML
* Takes an XML and parse its childNodes. doing it recursively
* For each "ChildNode", new XmlHash instance is created.
* The new instance can be parsed instansly, if "parseOnAccess" is false
* or it can be parsed when first accessing its content.
* The key can be set to anyone of the atrributes of the XMLNode, or the nodeName
* 
* @author 	I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
* @version 	1.0
*/
dynamic class iap.hash.XmlHash extends iap.hash.MultipleHash {
	private var __hashKey:String;
	private var __rawXml:XMLNode;
	
	private var __attributes:Object;
	private var __nodeValue:String;
	
	private var __id:String;
	
	private var __parseOnAccess:Boolean;
	private var __parsed:Boolean;
	
	/**
	* Constructor.
	* Can be used to instantly hash the content of an XML 
	* or store it for on access parsing.
	* if both arguments ommited, than use dataProvider to parse the XML
	* @param	keyName			Specify the attribute key to use as indexing
	* @param	xmlData 		(optional) the XMLNode to be parsed
	* @param	parseOnAccess 	(optional) if true XML is stores for on access parsing
	*/
	public function XmlHash(keyName:String, xmlData:XMLNode, parseOnAccess:Boolean){
		embedKey = true;
		__parsed = false;
		if (keyName == undefined) {
			__hashKey = "nodeName";
		} else {
			__hashKey = keyName;
		}
		__attributes = new Object();
		if (parseOnAccess) {
			__parseOnAccess = true;
			if (xmlData != undefined) {
				__rawXml = xmlData;
			}
		} else {
			__parseOnAccess = false;
			if (xmlData != undefined) {
				dataProvider = xmlData;
			}
		}
	}

	/**
	* parse the rawXml data to hash
	* @return	the hash itslef (this) to use as part of a chain
	*/
	public function parseData():XmlHash {
		if (!__parsed) {
			parseNode();
			parseChildNodes();
			__parsed = true;
		}
		return this;
	}
	
	/**
	* Called from parseData, parses the current node data:
	* attributes and internal value;
	*/
	private function parseNode() {
		__attributes = __rawXml.attributes;
		__nodeValue = __rawXml.nodeValue;
	}
	
	/**
	* Called from parseData, parses the list of childNodes
	*/
	private function parseChildNodes() {
		for (var o:String in __rawXml.childNodes) {
			var item:XMLNode = __rawXml.childNodes[o];
			if (item.nodeType == 1) {
				var key:String;
				if (__hashKey == "nodeName") {
					key = item.nodeName;
				} else {
					key = item.attributes[__hashKey];
				}
				if (key != undefined) {
					var itemObj:XmlHash = new XmlHash(__hashKey, item, __parseOnAccess);
					addItem(key, itemObj);
				} else {
					trace("ERROR: XmlHash.parseChildNode: Undefined key in XML attributes: "+__hashKey);
				}
			}
		}
	}
	
	/**
	* gets the selected Item and parse it if not parsed yet
	* if number of items with the same key, and no itemNum specified
	* it returns an array of all matching items
	* @param	key  the selected key
	* @param	itemNum  item nuber in list of keys
	* @return	the selected Item
	*/
	public function getItem(key:String,itemNum:Number):XmlHash {
		return XmlHash(super.getItem(key,itemNum)).parseData();
	}
	
	public function getByPath(path:String):Object {
		var nodesArr:Array = path.split(".");
		if (nodesArr.length == 1) {
			return getItem(nodesArr[0]);
		} else {
			return 
		}
	}
	
	/**
	* if set to true, the XML will only be parsed when it is requested first
	* else, if false its parsing the entire XML when the data arrives
	*/
	public function get parseOnAccess():Boolean {
		return __parseOnAccess;
	}
	
	public function set parseOnAccess(val:Boolean) {
		__parseOnAccess = val;
	}
	
	/**
	* gets the XML data and parse it, regardless of the parseOnAccess settings
	* @param	xmlData
	*/
	public function set dataProvider(xmlData:XMLNode) {
		//if (__rawXml != undefined) {
			__rawXml = xmlData;
			parseData();
		//}
	}
	
	/**
	* The key of this particular node. Write only ones
	* @param	newId
	*/
	public function set id(newId:String) {
		if (__id == undefined) {
			__id = newId;
		}
	}
	
	public function get id():String {
		return __id;
	}
	/**
	* access to a specifid attribute or the attributes collection
	*/
	public function get attributes():Object {
		return __attributes;
	}
	
	public function get value():String {
		return __nodeValue;
	}
	
	/**
	* for direct access
	* called whenever the instance of XmlHash is called with an unknown member.
	* if that member exist in the attributes, thats the value returned
	* if not, the first key with that name is returned
	* TODO: support dot syntax mixed with [ ] to retrive the exact item
	* @param	value	the value to retrive
	* @return	the desired value
	*/
	public function __resolve(value:String):Object {
		var val:Object = __attributes[value];
		if (val == undefined) {
			val = getItem(value, 0);
		}
		return val;
	}
	
}
