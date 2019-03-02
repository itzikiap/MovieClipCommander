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
 import iap.commander.extentions.Core;
import iap.commander.MovieClipCommander;
/**
* Align managment extention for MovieClipCommander
* For now, all alignment reffers relativly to the parent clip
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.Align extends iap.services.MovieClipService {
	private var __selectedAlign:String;
	private var __alignRelativeTo:MovieClipCommander;
	
	function init(autoAlign:Boolean, relativeTo:MovieClipCommander)	{
		__selectedAlign = "";
		relativeTo = (relativeTo == undefined) ? __commander._parent : relativeTo;
		setAutoAlign(autoAlign, relativeTo);
	}
	
	/**
	* align the clip to the right
	*/
	public function right(width:Number, height:Number) {
		width = (width == undefined) ? __alignRelativeTo._clip._width : width;
		var x:Number = width - __commander._clip._x;
		__commander._core.move(x, null);
		__selectedAlign = "right";
	}
	/**
	* align the clip to the left
	*/
	public function left(width:Number, height:Number) {
		var x:Number = __alignRelativeTo._clip._x;
		__commander._core.move(x, null);
		__selectedAlign = "left";
	}
	/**
	* align the clip to the center
	*/
	public function buttom(width:Number, height:Number) {
		height = (height == undefined) ? __alignRelativeTo._clip._height : height;
		var y:Number = height - __commander._clip._y;
		__commander._core.move(null, y);
		__selectedAlign = "buttom";
	}
	/**
	* align the clip to top
	*/
	public function top(width:Number, height:Number) {
		var y:Number = __alignRelativeTo._clip._y;
		__commander._core.move(null, y);
		__selectedAlign = "top";
	}
	/**
	* stick the clip in the center
	*/
	public function center(width:Number, height:Number) {
		width = (width == undefined) ? __alignRelativeTo._clip._width : width;
		height = (height == undefined) ? __alignRelativeTo._clip._height : height;
		var x:Number = width / 2 - __commander._clip._width / 2;
		var y:Number = height / 2 - __commander._clip._height / 2;
		
		__commander._core.move(x, y);
		__selectedAlign = "center";
	}
	
	/**
	* size the clip as a percentage of the size of the parent's clip
	* @param	percent	the percentage to size. assumes 100 if ommited
	*/
	public function sameSize(percent:Number) {
		if (percent == undefined) {
			percent = 100;
		}
		var width:Number = __alignRelativeTo._clip._width * percent /  100;
		var height:Number = __alignRelativeTo._clip._height * percent / 100;
		__commander._core.size(width, height);
	}
	
	/**
	* handleEvent method
	*/
	private function handleEvent(evt:Object) {
//		trace(this+", handle event of type: "+[evt.type,this, __selectedAlign, __alignRelativeTo]);
		switch (evt.type) {
			case Core.EVT_SIZE:
				this[__selectedAlign](evt.width, evt.height);
				break;
		}
	}
	
	public function setAutoAlign(val:Boolean, relativeTo:MovieClipCommander) {
		__alignRelativeTo = relativeTo;
		if (val == true) {
			relativeTo.addEventListener(Core.EVT_SIZE, this);
		} else {
			relativeTo.removeEventListener(Core.EVT_SIZE, this);
		}
	}
}
