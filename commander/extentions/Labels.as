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
* labels manager extention for MovieClipCommander
* make it easy to manage animation with labels. 
*
* v1.1:
*	Thanks to Eitan Avgil (Zaphod) scanning the hard coded labels created in authoring time is supported!!
*
* @author I.A.P Itzik Arzoni
*/
class iap.commander.extentions.Labels extends iap.services.MovieClipService {
	private var __labels:IndexedHash;
	
	function init(labelsArr:Array) {
		__labels = new IndexedHash();
		if (labelsArr != undefined) {
			mapFramesByLabels(labelsArr);
		}
	}

	/**
	* Map the labels of the __commander movie clip and saves 
	* the assosiated frame numbers
	* @param	labelsArr	an array of labels names
	*/
	public function mapFramesByLabels(labelsArr:Array) {
		var savedFrame:Number = __clip._currentframe;
		for (var o in labelsArr ) {
			var name:String = labelsArr[o];
			var frameNum:Number = getLabledFrameNum(name);
			__labels.addItem(name, frameNum);
		}
		__clip.gotoAndStop(savedFrame);
	}
	
	/**
	* import labels from an object of {name:number} definition
	* @param	definition of labels
	*/
	function importLabelsObject(labelsDef:Object) {
		__labels.importObject(labelsDef);
	}

	/**
	* scan the label number according the label name
	* @param	labelName	the name of the label to scan
	*/
	private function getLabledFrameNum(labelName:String):Number {
		__clip.gotoAndStop(labelName);
		var destFrame = __clip._currentframe;
		return destFrame;
	}

	/**
	* gets a frame according to the label
	*/
	public function getFrame(label:String):Number {
		var ret:Number = Number(__labels.getItem(label));
		return ret;
	}
	
	public function debugTrace() {
		var obj:Object = __labels.exportObject();
		trace("~2 ------- debug trace for "+__commander);
		for (var name:String in obj) {
			trace(" - - label: "+name+": "+obj[name]);
		}
		trace("~2 ------- END debug trace for "+this);
	}
	
	/**
	* returns the label of th current frame
	*/
	public function get _currentLabel():String {
		var ret:String = __labels.getName(__clip._currentframe);
		return ret;
	}
}
