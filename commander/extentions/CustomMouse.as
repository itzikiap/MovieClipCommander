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
 import iap.commander.extentions.Loader;
import iap.commander.extentions.Drag;
import iap.commander.MovieClipCommander;

/**
* Custom Mouse extention for MovieClipCommander
* does the management of custom mouse shapes
* Can load a movieclip with custom mouse library assets
* 
* It is better to use this only ones in the highest position of the root ;)
* 
* Using the folowing parameters to set its valueL:
* -mouseMode: the mode of the mouse. Actually a linkage for the main mouse icon
* -mouseExtra - a linkage to an extra mouse icon that it's parameters can be changed
* -mouseExtraProperties - properties for the movie clip that can be cahged
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.CustomMouse extends iap.services.MovieClipService {
	static var PARAM_MOUSE_MODE:String = "mouseMode";
	static var PARAM_MOUSE_EXTRA:String = "mouseExtra";
	/**
	* MovieClip properties to be copied to the movie clip that holds the
	* extra image. e.g. {_x:12, _y:20, _alpha:50}
	*/
	static var PARAM_MOUSE_EXTRA_PROPERTIES_OBJECT = "mouseExtraPropertis";
	
	static var DEFAULT_MOUSE_MODE:String = "arrow";
	
	private static var IMAGE_CLIP_NAME:String = "mouseImageMc";
	private var __hideMouse:Boolean;
	private var __drag:Drag;
	private var __loader:Loader;
	private var __image:MovieClipCommander;
	private var __extra:MovieClipCommander;
	private var __extraContent:MovieClipCommander;
	
	/**
	* initialize the mouse extention.
	* @param	mouseClipName	a clip to load with linkages for the mouse states
	*/
	function init(mouseClipName:String) {
		
		//__mouseClip = new MovieClipCommander(_root, "mouse", 16589);
		__image = MovieClipCommander(__commander.createChild("image", 3));
		__loader = Loader(__image.uniqueExtention("load", Loader));
		
		__drag = Drag(__commander.uniqueExtention("drag", Drag));
		__commander._core.move(_root._xmouse, _root._ymouse);
	
		__extra = MovieClipCommander(__commander.createChild("extra", 1));
		__extraContent = MovieClipCommander(__extra.createChild(IMAGE_CLIP_NAME, 1));
		__commander.addEventListener("paramChange", this);
		
		__commander._params.setParam(PARAM_MOUSE_MODE, DEFAULT_MOUSE_MODE);
		__commander._params.setParam(PARAM_MOUSE_EXTRA, "");
		__commander._params.setParam(PARAM_MOUSE_EXTRA_PROPERTIES_OBJECT, {});
		__commander._params.registerGlobalParam(PARAM_MOUSE_MODE);
		__commander._params.registerGlobalParam(PARAM_MOUSE_EXTRA);
		__commander._params.registerGlobalParam(PARAM_MOUSE_EXTRA_PROPERTIES_OBJECT);
		
		if (mouseClipName != undefined) {
			__loader.loadClip(mouseClipName);
		}
		
		__drag._stopOnClick = false;
		__drag.startDrag();
		
		__image.addEventListener(Loader.EVT_LOAD_INIT, this);
	}
	
	/**
	* sets the new mouse icon
	* set linbkage to undefined 
	* @param	iconLinkage	linkage to the new mouse icon
	*/
	private function setMouseIcon(iconLinkage:String) {
		var mouseIcon:MovieClip = MovieClip(__image._core._clip[IMAGE_CLIP_NAME]);
		mouseIcon.removeMovieClip();
		mouseIcon = __image._core._clip.attachMovie(iconLinkage, IMAGE_CLIP_NAME, 1);
		if (mouseIcon._visible == true) {
			Mouse.hide();
		} else {
			Mouse.show();
		}
	}
	
	/**
	* sets an extra mouse icon and wrap it with a movie clip commander
	* @param	extraLinkage	linkage to the new extra icon
	*/
	private function setMouseExtraImage(extraLinkage:String) {
		__extraContent.destroy();
		if (extraLinkage.length > 0) {
			__extraContent = MovieClipCommander(__extra.createChild(IMAGE_CLIP_NAME,1, extraLinkage));
		}
	}
	
	/**
	* set properties to the new mouse extra icon
	* @param	propertiesObj	properties for the mouse movie clip
	*/
	private function setExtraImageProperties(propertiesObj:Object) {
		__extra._core.applyPropertiesObject(propertiesObj);
	}
	
	/**
	* event handler
	*/
	private function handleEvent(evt:Object) {
		
		switch (evt.type) {
			case Loader.EVT_LOAD_INIT:
				setMouseIcon(__commander._params.getString(PARAM_MOUSE_MODE));
				break;
		}
	}
	
	/**
	* parameter change handler
	*/
	private function paramChange(evt:Object) {
		switch (evt.name) {
			case PARAM_MOUSE_MODE:
				setMouseIcon(evt.value);
				break;
			case PARAM_MOUSE_EXTRA:
				setMouseExtraImage(evt.value);
				break;
			case PARAM_MOUSE_EXTRA_PROPERTIES_OBJECT:
				setExtraImageProperties(evt.value);
				break;
		}
	}
	
	/**
	* change the mouse mode (actually the mouse icon linkage)
	*/
	public function set _mouseMode(val:String) {
		__commander._params.setParam(PARAM_MOUSE_MODE, val);
	}
	
	/**
	* the extra mouse icon linkage
	*/
	public function set _extraImageLinkage(val:String) {
		__commander._params.setParam(PARAM_MOUSE_EXTRA, val);
	}
	
	/**
	* extra mouse icon movie clip properties
	*/
	public function set _extraImageProperties(val:Object) {
		__commander._params.setParam(PARAM_MOUSE_EXTRA_PROPERTIES_OBJECT, val);
	}
	
	/**
	* refference to the extra mouse icon MovieClipCommander
	*/
	public function get _extraImageRef():MovieClipCommander {
		return __extraContent;
	}
}