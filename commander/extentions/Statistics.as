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
 import iap.commander.extentions.Text;
import iap.app.GlobalParams;
import iap.basic.IndexedHash;

/**
* Display statistics in a movieClip
* Statistics is a parameter with a basic value (string, number, boolean)
* This extention is somewhat pretty specific. 
* It requires that that the label names with the proper parameter names
* would xist in the movieclip.
* (It does creates them if they don't exist, but no formatting is added)
* @TODO - support saving of history (when nedded)
*/
class iap.commander.extentions.Statistics extends iap.services.MovieClipService {
	private var __statistics:IndexedHash;
	
	function init(statisticsList:Array) {
		__commander.addEventListener("paramChange", this);
//		__commander._core.move(__commander._parent._params.getNumber("statistics.x"), __commander._parent._params.getNumber("statistics.y"))
		__statistics = new IndexedHash();
		addStatisticsList(statisticsList);
	}
	
	/**
	* adds a label and define a global param value to listen as statistics
	* @param	statisticName	the name of the label or global param
	*/
	private function addStatisticsLabel(statisticName:String) {
		var txt:Text = Text(__commander.registerExtention(statisticName, Text, [statisticName+"Txt"]));
		GlobalParams.registerParam(statisticName, __commander._params);
		__statistics.addItem(statisticName, txt);
	}
	
	/**
	* adds a list of statistics labels
	* @param	list	an array of names
	*/
	public function addStatisticsList(list:Array) {
		for (var o:String in list) {
			addStatisticsLabel(list[o]);
		}
	}
	
	private function paramChange(evt:Object) {
		if (__statistics.isExist(evt.name)) {
			var txt:Text = Text(__statistics._lastItem);
//			trace("changing statistics value: "+[evt.name, __statistics._lastItem, evt.value]);
			txt.text = evt.value;
		}
	}
}
