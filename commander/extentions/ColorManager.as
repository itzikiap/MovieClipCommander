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
 /**
* color manager extention 
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/

class iap.commander.extentions.ColorManager extends iap.services.MovieClipService {
	static var EVT_CLEAR_DONE = "clearDone"
	/**
	* the colorManager class colors a movieclip with one hexadecimal value, or changes seperated RGB channels.  
	*/
	
	private var __color:Color;
	private var __colorTransform:Object;

	function init() {
		__commander.addEventListener("paramChange",this);
		setBrightness(0);
		__color = new Color (__clip);
		__colorTransform = new Object();
		__colorTransform.aa = 100;
		__colorTransform.ab = 255;
	}
	
	/**
	* sets hexadecimal code to the movieclip the __color refers to. 
	* @param	color
	*/
	private function setColor(color:Number){
		__color.setRGB(color)
	}
	
	/**
	* sets the __colorTransform objects parameters on the __color objects. 
	* this function serves all the RGB seperated controll, and the clearTransform func'
	*/
	private function setColorTransform(){
		__color.setTransform(__colorTransform);
	}
		
	/**
	* removes all color effects fron the __clip
	*/
	public function clearTransform(){
		__color.setTransform({ra:100, rb:0, ga:100, gb:0, ba:100, bb:0});
		
	}
	
	/**
	* 
	* @return an object that holds all color transform parameters
	*/
	public function get _transform():Object {
		return __color.getTransform();
	}
	
	/**
	* returns the hexadecimal color that effects __clip
	* @return
	*/
	public function get _color():Number {
		return __color.getRGB();
	}
	
	/**
	* public setTransform with an external color object. Ignors the __colorTransform
	* @param	obj  a color object
	*/
	public function set _transform(obj:Object) {
		__color.setTransform(obj);
	}
	
	/**
	* sets the color to the __clip with one hexadecimal value
	* @param	value
	*/
	public function set _color(value:Number) {
		setColor(value);
	}
	
	/**
	* sets the red offset value of the __colorTransform object and changes the __clip
	* @param	value from -255 to 255
	*/
	public function set _redOffset(value:Number) {
		__colorTransform.rb = value;
		setColorTransform();
	}
	
	/**
	* sets the green offset value of the __colorTransform object and changes the __clip
	* @param	value from -255 to 255
	*/
	public function set _greenOffset(value:Number) {
		__colorTransform.gb = value;
		setColorTransform()
	}
	/**
	* sets the blue offset value of the __colorTransform object and changes the __clip
	* @param	value from -255 to 255
	*/	
	public function set _blueOffset(value:Number) {
		__colorTransform.bb = value;
		setColorTransform()
	}
	/**
	* sets the alpha offset value of the __colorTransform object and changes the __clip
	* @param	value from -255 to 255
	*/	
	public function set _alphaOffset(value:Number) {
		__colorTransform.ab = value;
		setColorTransform()
	}
	
	/**
	* sets the red multiplyer value of the __colorTransform object and changes the __clip
	* @param	value from -100 to 100
	*/	
	public function set _redMultiplier(value:Number) {
		__colorTransform.ra = value;
		setColorTransform()
	}
	
	/**
	* sets the green multiplyer value of the __colorTransform object and changes the __clip
	* @param	value from -100 to 100
	*/	
	public function set _greenMultiplier(value:Number) {
		__colorTransform.gb = value;
		setColorTransform()
	}
	
	/**
	* sets the green multiplyer value of the __colorTransform object and changes the __clip
	* @param	value from -100 to 100
	*/	
	public function set _blueMultiplier(value:Number) {
		__colorTransform.bb = value;
		setColorTransform()
	}
	
	/**
	* sets the alpha multiplyer value of the __colorTransform object and changes the __clip
	* @param	value from -100 to 100
	*/	
	public function set _alphaMultiplier(value:Number) {
		__colorTransform.ab = value;
		setColorTransform()
	}
	
	
	/** - By Izikon
	* set the brithness to the __clip
	* @param value from -100 to 100
	*/
	public function setBrightness(value:Number)	{
		__commander._params.setParam("brightness", value);
	}
	
	/**
	* event handler
	* Handles the changing of "brightness" param
	*/
	private function paramChange(evt:Object)	{
//		trace("param change: "+[this, evt.name,evt.value]);
			if(evt.name=="brightness")	{
				var value:Number = evt.value;
				if(value<0)	{
					value = 100 + value
					__colorTransform.ra = value
					__colorTransform.rb = 0
					__colorTransform.ga = value
					__colorTransform.gb = 0
					__colorTransform.ba = value
					__colorTransform.bb = 0
				}else{
					__colorTransform.ra = 100 - value
					__colorTransform.rb = int(value * 2.56);
					__colorTransform.ga = 100 - value
					__colorTransform.gb = int(value * 2.56);
					__colorTransform.ba = 100 - value
					__colorTransform.bb = int(value * 2.56);
				}
				setColorTransform()
			}
		}
}
