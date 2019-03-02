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
* Provides basic one line text field
* @author I.A.P Itzik arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.Text extends MovieClipService {
	/**
	* textChange
	* {[B]oldText[/B]:__text, [B]newText[/B]:newText}
	*/
	static var EVT_CHANGED:String = "textChange";
	
	static var PRM_TEXT_FIELD_NAME:String = "textFieldName";
	
	private var __text:String;
	private var __textField:TextField;
	private var __textFormat:TextFormat;
	
	public function init(textFieldName:String) {
		if (textFieldName == undefined) {
			textFieldName = __commander._params.getString(PRM_TEXT_FIELD_NAME);
		}
		if (textFieldName != undefined) {
			__textField = __clip[textFieldName];
			if (__textField == undefined) {
				trace("~5ERROR: wrapping of text field failed: "+textFieldName+" in "+__clip);
			}
		} else {
			createTextField();
		}
	}
	
	public function removeTextField() {
		__textField.removeTextField();
		__textField = undefined;
	}
	
	public function createTextField(fillClip:Boolean) {
		if (__textField == undefined) {
			__clip.createTextField("textInstance"+__id, __commander._depth.higher,0,0,10,10);
			__textField = __clip["textInstance"+__id];
			__commander._params.setParam(PRM_TEXT_FIELD_NAME, "textInstance"+__id);
			__textField.selectable = false;
			__textFormat = new TextFormat();
			if (fillClip == true) {
				__textField._width = __clip._width;
				__textField._height = __clip._height;
			} else {
				__textField.autoSize = "left";
			}
		}
	}
	
	private function defineText(newText:String) {
		dispatchEvent(EVT_CHANGED, {oldText:__text, newText:newText});
		__text = newText;
		__textField.text = newText;
	}
	
	/**
	* Sets a generic style for all new text.
	* @param	font	font to be used
	* @param	size	size of text
	* @param	textColor	text color
	* @param	bold	is it bold
	* @param	italic	is it italic
	* @param	underline	is it underline
	* @param	url	if typed, the text become a link
	* @param	window	
	* @param	align	the alingment of text("left", "center", "right")
	* @param	leftMargin	space of text from the left boundry
	* @param	rightMargin	space of text from the right boundry
	* @param	indent	Number of TABs before the text
	* @param	leading	nuber of empty lines before the text
	*/
	public function textStyle(font:String,size:Number,textColor:Number,
                    	bold:Boolean,italic:Boolean,underline:Boolean,
                    	url:String,window:String,align:String,
                    	leftMargin:Number,rightMargin:Number,indent:Number,leading:Number) {
		__textFormat = new TextFormat(font,size,textColor,bold,italic,underline,url,window,align,leftMargin,rightMargin,indent,leading);
		__textField.setNewTextFormat(__textFormat);
	}
	
	/**
	* sets a new property of the text format.
	* every property that is being set, will be applyed to all new text
	* If you want to apply changes to all the existing text, use "applyTextFormat"
	* @param	propName	The name of the format property to change
	* @param	val		new value
	*/
	public function setTextFormatProperty(propName:String, val:Object) {
		__textFormat[propName] = val;
		__textField.setNewTextFormat(__textFormat);
	}
	
	/**
	* Apply all the changes made to the text format, to all the existing text 
	* (as opposed to only new text)
	*/
	public function applyTextFormat() {
		__textField.setTextFormat(__textFormat);
	}
	
	
	/**
	* move the textfield inside the movie clip
	* @param	evt	the x coordinates
	* @param	y	the y coordinates
	*/
	public function move(_x:Object, _y:Number) {
		__textField._x = int(_x);
		__textField._y = int(_y);
	}
	
	public function set _selectable(sel:Boolean){
		__textField.selectable = sel;
	}
	public function set _wordWrap(bool:Boolean){
		__textField.wordWrap = bool;
	}
	
	public function get _wordWrap():Boolean{
		return __textField.wordWrap;
	}
	
	public function set _miltiline(bool:Boolean){
		__textField.multiline = bool;
	}
	
	public function get _multiline() {
		return __textField.multiline; 
	}
	
	public function size(evt:Object) {
		__textField._width = evt.width;
		__textField._height = evt.height;
	}
	
	public function resize(width:Number,height:Number){
		__textField._width = width;
		__textField._height = height;
	}
	
	public function set _text(val:String) {
		defineText(val);
	}
	
	public function get _text():String {
		return __text;
	}
	
	public function get _height():Number {
		return __textField._height;
	}
	
	public function get _width():Number {
		return __textField._height;
	}
	/**
	* gets the text extents height for a general Text
	*/
	public function get _eheight():Number {
		var extent:Object = __textFormat.getTextExtent("aJljgI|");
		return 10;
	}
	
	function unregisterService() {
		super.unregisterService();
		removeTextField();
	}
}
