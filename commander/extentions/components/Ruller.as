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
 import iap.commander.extentions.Draw;
import iap.commander.MovieClipCommander;

/**
* Ruller component extention for movieclip commander
* This component is incompleted and needs to be refactored
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.components.Ruller extends iap.services.MovieClipService {
	private var __mainRullerTicAttachment:String;
	private var __subRullerTicAttachment:String;
	private var __fromNumber:Number;
	private var __toNumber:Number;
	private var __subDivision:Number;
	private var __division:Number;
	private var __ticWidth:Number;
	private var __ticksHolder:MovieClipCommander;
	private var __limiter:MovieClipCommander;
	private var __rullerHeight:Number;
	private var __limit:Number;
	private var __rulerWidth:Number;
	
	
	
	/**
	* initialize the component
	* @param	width	the width of the ruller
	* @param	mainDivision	the main (big) division
	* @param	subDivision		the sub (small) division
	* @param	fromNumber	the start number
	* @param	toNumber	the end number
	*/
	private function init(width:Number, mainDivision:Number,subDivision:Number,fromNumber:Number,toNumber:Number){
		/// todo later
		__subRullerTicAttachment = "shortRullerTic";
		__mainRullerTicAttachment = "longRullerTic";
		__subDivision = subDivision;
		__division = mainDivision;
		__fromNumber = fromNumber;
		__toNumber = toNumber;
		__rullerHeight = __clip._parent._height-1;
		__rulerWidth = width;
		__ticksHolder = MovieClipCommander(__commander.createChild("ticsHolder", __commander._depth.higher));
		var draw:Draw = Draw(__ticksHolder.uniqueExtention("draw",Draw));
		build();
		
		
		__limit = __toNumber-__fromNumber;
		createLimiter();
	}
	
	/**
	* 
	* @param	color
	* @param	alpha
	* @param	subDivWidth
	*/
	public function setNotchesSkin(color:Number, alpha:Number, subDivWidth:Number) {
		__ticksHolder._clip.clear();
		//createNotches(color, alpha, subDivWidth);
	}
	
	public function setNumbersVisibility(val:Boolean) {
		__clip.ticsText._visible = val;
	}
	
	public function build() {
		__ticWidth= __rulerWidth/(__toNumber - __fromNumber);

		//ruler build
		createNotches();
		createLabels();
	}
	
	private function rebuild() {
		build();
		positionLimit();
	}

	private function makeLabel(tic:Number,xPos:Number,mc:MovieClip){
		mc.createTextField("label"+tic,mc.getNextHighestDepth(),0,0,1,1);
		var txt:TextField = mc["label"+tic]
		txt._x = xPos;
		txt._y = -__rullerHeight
		txt._height = __rullerHeight
		txt._width = 1;
		txt.autoSize = "center";
		txt.selectable = false;
		var format:TextFormat = txt.getTextFormat();
		format.size = 14;
		format.font = "Arial (Hebrew)";
		format.bold = true;
		format.color = 0x577216;
		txt.setNewTextFormat(format);
		txt.text = String(tic+__fromNumber);
		//txt.setTextFormat(StaticDefenitions.Instance.rullerTextFormat);
	}

	private function createNotches(notchesColor:Number, notchesAlpha:Number, subDivWidth:Number) {
		notchesColor = (notchesColor == undefined)? 0:notchesColor;
		notchesAlpha = (notchesAlpha == undefined)? 100:notchesAlpha;
		subDivWidth = (subDivWidth == undefined)? 2:subDivWidth;
		var draw:Draw = __ticksHolder._commands.draw;
		draw.clear();
		for (var i = 0; i <= __toNumber - __fromNumber ; i+=__division) {
			var xlocation:Number = i*__ticWidth
			if (i % __subDivision == 0) {
				draw.lineStyle(subDivWidth,notchesColor,100,undefined,undefined,"none")
			} else  {
				draw.lineStyle(0,notchesColor,40,undefined,undefined,"none")
			}	
			draw.line(xlocation,0 , xlocation ,__rullerHeight)
		}
		__ticksHolder._core.property("_alpha", notchesAlpha);
		__ticksHolder._core.property("_visbile", (notchesAlpha == 0));
	}
	
	public function createLabels() {
		var ticsText:MovieClip
		if (__clip.ticsText._visible) {
			__clip.ticsText.removeMovieClip();
			ticsText = __clip.createEmptyMovieClip("ticsText",__commander._depth.higher)
		}
		for (var i = 0; i <= __toNumber - __fromNumber ; i+=__division) {
			var xlocation:Number = i*__ticWidth
			if (i % __subDivision == 0) {
				makeLabel(i, xlocation,ticsText);
			}
		}
	}
	
	private function createLimiter() {
		__limiter = MovieClipCommander(__commander.createChild("limiter", __commander._depth.higher));
		__limiter.registerExtention("draw", Draw);
		drawLimiter();
		positionLimit();
		_limiterColor = 0x2ff000;
	}

	private function drawLimiter() {
		var draw:Draw = __limiter._commands.draw;
		draw.clear();
		draw._fillColor = 0x000000;
		draw.lineStyle(0,0,0);
		draw.rect(0,0,100,__rullerHeight);
	}
	
	private function positionLimit() {
		var limitWidth = (__toNumber - __limit)*__ticWidth;
		__limiter._clip._width = limitWidth;
		__limiter._clip._x = __toNumber *__ticWidth - limitWidth;
		//trace("position limiter: "+[__toNumber,__limit,__toNumber - __limit,__ticWidth,(__toNumber - __limit)*__ticWidth, __toNumber *__ticWidth - limitWidth]);
	}
	
	
	public function set _limiterColor(val:Number) {
		if (val != undefined) {
			var lc:Color = new Color(__limiter._clip);
			lc.setRGB(val);
		}
	}
	
	public function set _limiterAlpha(val:Number) {
		__limiter._clip._alpha = val;
	}
	
	public function set _limit(val:Number){
		__limit = val;
		positionLimit();
	}
	
	public function get _limit():Number {
		return __limit;
	}
	
	public function set _length(val:Number) {
		if (__limit == _length) {
			_limit = val;
		}
		__toNumber = val - __fromNumber;
		rebuild();
	}
	
	/**
	* the length of the ruller in tics. 
	*/
	public function get _length():Number {
		return __toNumber-__fromNumber;
	}
	
	public function get _ticWidth():Number {
		return __ticWidth;
	}
}
