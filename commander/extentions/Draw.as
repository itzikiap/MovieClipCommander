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
 import iap.services.MovieClipService;

/**
* basic Poly Draw extention for MovieClipCommander with the ability to fill
* @author I.A.P ItzikArzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.Draw extends MovieClipService{
	private var __fill:Boolean;
	private var __fillColor:Number;
	private var __fillAlpha:Number;
	private var __lineStyle:Array;

	private static var TAN_PI_8:Number;
	private static var SIN_PI_4:Number;

	public function init(lineColor:Number, lineAlpha:Number, fillColor:Number, fillAlpha:Number, toFill:Boolean) {
		if (SIN_PI_4 == undefined) {
			SIN_PI_4 = Math.sin(Math.PI/4);
			TAN_PI_8 = Math.tan(Math.PI/8);
		}
		var lc:Number = (lineColor == undefined) ? 0: lineColor;
		var la:Number = (lineAlpha == undefined) ? 100: lineAlpha;
		lineStyle(1,lc,la);
		_fillColor = (fillColor == undefined) ? 0: fillColor;
		_fillAlpha = (fillAlpha == undefined) ? 100: fillAlpha;
		_fill = (toFill == true);
	}
	
	/**
	* sets the default line style.
	* all the arguments of MovieClip.lineStyle method
	*/
	public function lineStyle(thickness:Number, rgb:Number, alpha:Number, pixelHinting:Boolean, noScale:String, capsStyle:String, jointStyle:String, miterLimit:Number) {
		__lineStyle = arguments;
	}
	
	/**
	* Draw a line from one point to the other
	* @param	x1
	* @param	y1
	* @param	x2
	* @param	y2
	*/
	function line(x1:Number, y1:Number, x2:Number, y2:Number) {
		__clip.moveTo(x1,y1);
		lineTo(x2,y2);
	} 
	
	/**
	* Draw a line from current cursor position to the specified point
	* @param	x1
	* @param	y1
	*/
	function lineTo(x1:Number, y1:Number) {
		applyLineStyle();
		__clip.endFill();
		__clip.lineTo(x1,y1);
	}
	
	/**
	* Draw a cross
	* @param	x1	center x
	* @param	y1	center y
	* @param	size	the size of the cross
	* @param	angle	if angle is 45, the cross will be X, otherwise it would be +
	*/
	function cross(x1:Number, y1:Number, size:Number, angle:Number) {
		var len:Number = size / 2;
		if (angle == 45) {
			line(x1-len, y1-len, x1+len, y1+len);
			line(x1-len, y1+len, x1+len, y1-len);
		} else {
			line(x1-len, y1, x1+len, y1);
			line(x1, y1+len, x1, y1-len);
		}
	}
	
	/**
	* draws a closed polygone can be filled or not, depending on "fill" value
	* on argument of an array containig little arrays of dots
	* [[0,10],[30,15],[50,32]]
	* will draw a poligone from point (0,10) to (30,15) to (50,32) and the back to (0,10)
	* @param	points	array of points
	*/
	public function poly(points:Array) {
		applyLineStyle();
		var pointNum:Number = 0;
		if (__fill) {
			__clip.beginFill(__fillColor,__fillAlpha);
		}
		var point = points[pointNum]
		__clip.moveTo(point[0],point[1]);
		for (pointNum = 1; pointNum < points.length; pointNum++) {
			point = points[pointNum]
			__clip.lineTo(point[0],point[1]);
		}
		point = points[0]
		__clip.lineTo(point[0],point[1]);
		if (__fill) {
			__clip.endFill(__fillColor,__fillAlpha);
		}

	}
	
	/**
	* Draws a rectangle given the opposite corners
	*/
	public function rect(x1:Number,y1:Number,x2:Number,y2:Number) {
		poly([[x1,y1],[x1,y2],[x2,y2],[x2,y1]]);
	}
	
	/**
	* Draws a diamond given the center point and a radios
	*/
	public function diamond(x1:Number,y1:Number,r:Number) {
		poly([[x1,y1-r],[x1+r,y1],[x1,y1+r],[x1-r,y1]]);
	}

	
	/**
	* Draws a circle using center and radius
	* @param	x	the x center
	* @param	y	the y center
	* @param	r	the circle radius
	*/
	public function circle(x:Number,y:Number,r:Number) {
		applyLineStyle();
		__clip.lineStyle.apply(__clip,__lineStyle);
		if (__fill) {
			__clip.beginFill(__fillColor,__fillAlpha);
		}
		__clip.moveTo(x+r, y);
		__clip.curveTo(r+x, TAN_PI_8*r+y, SIN_PI_4*r+x, SIN_PI_4*r+y);
		__clip.curveTo(TAN_PI_8*r+x, r+y, x, r+y);
		__clip.curveTo(-TAN_PI_8*r+x, r+y, -SIN_PI_4*r+x, SIN_PI_4*r+y);
		__clip.curveTo(-r+x, TAN_PI_8*r+y, -r+x, y);
		__clip.curveTo(-r+x, -TAN_PI_8*r+y, -SIN_PI_4*r+x, -SIN_PI_4*r+y);
		__clip.curveTo(-TAN_PI_8*r+x, -r+y, x, -r+y);
		__clip.curveTo(TAN_PI_8*r+x, -r+y, SIN_PI_4*r+x, -SIN_PI_4*r+y);
		__clip.curveTo(r+x, -TAN_PI_8*r+y, r+x, y);
		if (__fill) {
			__clip.endFill(__fillColor,__fillAlpha);
		}
	}
	
	public function clear() {
		__clip.clear();
	}
	
	private function applyLineStyle() {
		__clip.lineStyle.apply(__clip,__lineStyle);
	}
	
	//{region getters / setters
	/**
	* if true, the polygones would be filled
	*/
	public function set _fill(value:Boolean) {
		__fill = value;
	}

	/**
	* the fill color
	*/
	public function set _fillColor(value:Number) {
		_fill = true;
		__fillColor = value;
	}
	
	/**
	* The fill Alpha
	*/
	public function set _fillAlpha(value:Number) {
		__fillAlpha = value;
	}

	public function get _fill():Boolean {
		return __fill;
	}
	
	public function get _fillColor():Number {
		return __fillColor;
	}
	
	public function get _fillAlpha():Number {
		return __fillAlpha;
	}
	//}end region

}
