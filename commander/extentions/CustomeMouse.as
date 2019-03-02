import iap.commander.extentions.Loader;
import iap.commander.extentions.Drag;
import iap.commander.MovieClipCommander;

/**
* Custom Mouse extention for MovieClipCommander
* does the management of custom mouse shapes
*/
class iap.commander.extentions.CustomeMouse extends iap.services.MovieClipService {
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
	
	private function setMouseIcon(iconLinkage:String) {
		var mouseIcon:MovieClip = MovieClip(__image._core._clip[IMAGE_CLIP_NAME]);
		mouseIcon.removeMovieClip();
		mouseIcon = __image._core._clip.attachMovie(iconLinkage, IMAGE_CLIP_NAME, 1);
		if (mouseIcon == undefined) {
			Mouse.show();
		} else {
			Mouse.hide();
		}
	}
	
	private function setMouseExtraImage(extraLinkage:String) {
		__extraContent.destroy();
		if (extraLinkage.length > 0) {
			__extraContent = MovieClipCommander(__extra.createChild(IMAGE_CLIP_NAME,1, extraLinkage));
		}
	}
	
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
	//	trace("param change"+this+": "+[evt.name,evt.value]);
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
	
	public function set _mouseMode(val:String) {
		__commander._params.setParam(PARAM_MOUSE_MODE, val);
	}
	
	public function set _extraImageLinkage(val:String) {
		__commander._params.setParam(PARAM_MOUSE_EXTRA, val);
	}
	
	public function set _extraImageProperties(val:Object) {
		__commander._params.setParam(PARAM_MOUSE_EXTRA_PROPERTIES_OBJECT, val);
	}
	
	public function get _extraImageRef():MovieClipCommander {
		return __extraContent;
	}
}