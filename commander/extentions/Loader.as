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
 import iap.time.FramePulse;
/**
* A complete solution for loading SWF, pictures and clip to the commander
* Also support loading and automatic resizing of the loaded clip to a specified region. (still in development)
* dispatches these events:
* @author I.A.P Itzik Arzoni @gmail.com
* @version 1.0
*/

class iap.commander.extentions.Loader extends iap.commander.extentions.AbstractLoader{
	/**
	* - loadRequest: fires when calling to "loadClip" function.
	* 	Extra info: {[B]url[/B]:<fileName>}
	*/
	static var EVT_LOAD_REQUEST:String = "loadRequest";
	/**
	* - loadFails: fires after timeout has reached without replay from the server
	* 	Extra info: {[B]success[/B]:false, [B]url[/B]:<fileName>}
	*/
	static var EVT_LOAD_FAILS:String = "loadFails";
	/**
	* - loadStart: fires either when the downloading actually begins. Also fires when fail
	* 	Extra info:	{[B]bytesTotal[/B]:<totalBytesToLoad>, [B]success[/B]:<if success>, [B]url[/B]:<fileName>}
	*/
	static var EVT_LOAD_START:String = "loadStart";
	/**
	* - loadProgress: fires each frame of loading progress
	* 	Extra info:	{[B]url[/B]:<fileName>, [B]bytesTotal[/B]:<totalBytesToLoad>, [B]bytesLoaded[/B]:<bytesLoadedSoFar>}
	*/
	static var EVT_LOAD_PROGRESS:String = "loadProgress";
	/**
	* - loadComplete: fires when loading is complete
	*   Extra info: {[B]bytesTotal[/B]:<__bytesTotal>, [B]bytesLoaded[/B]:<__bytesLoaded>, [B]url[/B]:<__fileName>}
	*/
	static var EVT_LOAD_COMPLETE:String = "loadComplete";
	/**
	* - loadInit: fires one frame after load complete
	* 	Extra info: {[B]url[/B]:<file name>}
	*/
	static var EVT_LOAD_INIT:String = "loadInit";
	
	// after this timeout, command has failed. (in cycles)
	private static var __timeout:Number = 18;
	private var __fileName:String;
	private var __loadInto:Boolean;
	private var __loadedClipName:String;
	private var __bytesLoaded:Number;
	private var __bytesTotal:Number;
	private var __loadCounter:Number;
	private var __timer:FramePulse;
	private var __lastSuccess:Boolean;
	private var __isLoaded:Boolean;
	private var __initObject:Object;
	private var __sizeRestrict:Boolean;
	private var __listenerId:Number;
	private var __initDelay:Number;
	
	//{region Public Interface
	public function init() {
		__loadInto = false;
		__loadedClipName = "";
		__timer = new FramePulse();
		__isLoaded = false;
		__sizeRestrict = false;
		__initDelay = 1;
		super.init();
	}
	
	/**
	* The main function to load a clip into the container "commnder"
	* dispatches event:
	* 	"loadRequest": fires just before request is sent to the server
	* 		extra info: {url:the files requested}
	* @param	fileName
	* @param	initObj
	*/
	public function loadClip(fileName:String, initObj:Object) {
		//trace("load clip: "+[__commander, fileName]);
		fileName = getProperFileName(fileName);
		__clip.loadMovie(fileName);
		__fileName = fileName;
		__timer.clearFuncList();
		__listenerId = __timer.addFunc(this, waitForLoad);
		__timer.run(__timeout);
		dispatchEvent(EVT_LOAD_REQUEST, {url:fileName});
		waitForLoad(0,false);
		__loadCounter = 0;
		if (__initObject == undefined) {
			__initObject = new Object();
		}
		for (var o:String in initObj) {
			__initObject[o]= initObj[o];
		}
	}
	
	/**
	* unload the entire clip from the container
	*/
	public function unload() {
		if (__isLoaded) {
			__clip.unloadMovie();
			__isLoaded = false;
		}
	}
	//}
	
	//{ region Timer Loops listeners
	/**
	* first loop that waits for the server to start loading
	* called by "__timer"
	* dispatches events:
	* 	"loadStart": fires when loading is started or failed(!)
	* 		Extra info: {bytesTotal:total bytes of clip, success:if loading was success, url:fileName}
	* 	"loadFail": fires if loop timed out (loading failed)
	* 		Extra info: {success:false, url:fileName}
	* @param	count	the loop count. Number of frames passed
	* @param	last	is this the last call before timeout
	*/
	private function waitForLoad(count:Number, last:Boolean) {
//		trace("wait for load "+count+":" +last+"("+arguments+")");
		__bytesTotal = __clip.getBytesTotal();
		if (__bytesTotal > 14) {
			__timer.abort();
//			__timer.clearFuncList();
			__timer.replaceFunc(-1, this, loadingLoop)
			__timer.run();
			dispatchEvent(EVT_LOAD_START, {bytesTotal:__bytesTotal, success:true, url:__fileName});
			__lastSuccess = true;
			__bytesLoaded = __clip.getBytesLoaded();
			if (__bytesLoaded == __bytesTotal) {
				loadComplete();
			}
		} else if (last) {
			trace("~5RUNTIME ERROR: Loading of file '"+__fileName+"' into "+__clip+" failed.");
			__timer.abort();
			dispatchEvent(EVT_LOAD_FAILS, {success:false, url:__fileName});
			dispatchEvent(EVT_LOAD_START, {bytesTotal:-1, success:false, url:__fileName});
			dispatchEvent(EVT_LOAD_COMPLETE, {bytesTotal:0, bytesLoaded:0, url:__fileName, success:false})
			__lastSuccess = false;
			__isLoaded = false;
		}
	}
	
	/**
	* The waiting loop for the loading.
	* called by frame pulse.
	*/
	private function loadingLoop(count:Number, last:Boolean) {
//		trace("loading loop: "+[count, last]);
		__bytesLoaded = __clip.getBytesLoaded();
		dispatchEvent(EVT_LOAD_PROGRESS, {url:__fileName, bytesTotal:__bytesTotal, bytesLoaded:__bytesLoaded, elapsed:count});
		if (__bytesLoaded == __bytesTotal) {
			loadComplete();
		}
	}
	
	/**
	* called when the loading is complete
	* also aplly the init object
	*/
	private function loadComplete() {
		//trace("loadComplete "+__clip);
		//trace("clip ratio on load complete: "+[__clip._width, __clip._height, (__clip._width / __clip._height)]);
		for (var o:String in __initObject) {
			__clip[o] = __initObject[o];
		}
		removeSizeRestriction();
		dispatchEvent(EVT_LOAD_COMPLETE, {bytesTotal:__bytesTotal, bytesLoaded:__bytesLoaded, url:__fileName, success:true})
		__timer.abort();
		__timer.clearFuncList();
		__timer.addFunc(this, doneLoading);
		__timer.run(__initDelay);
	}

	/**
	* called one frame (or as defined) after loading complete, to let all the frame to get initialize
	*/
	private function doneLoading(count:Number, last:Boolean) {
//		trace("done loading (load init) "+arguments);
		if (last) {
			__isLoaded = true;
			__clip.commander = __commander;
			dispatchEvent(EVT_LOAD_INIT, {url:__fileName});
		}
	}
	//}
	
	//{region helper commands
	/**
	* changes the size of the loaded clip to fit the defined size
	*/
	private function sizeChange(evt:Object) {
		__initObject._width = evt.width;
		__initObject._height = evt.height;
		evt.handled = true;
		
	}
	
	/**
	* rmoves the size restrictions from the loaded clip
	*/
	private function removeSizeRestriction() {
		if (__sizeRestrict) {
			__sizeRestrict = false;
			delete __initObject.height;
			delete __initObject.width;
			__commander.removeEventListener("size", iap.functionUtils.Delegate.create(this, sizeChange));
		}
	}
	//}end region
	
	//{region Getters/Setters
	/**
	* returns the last URL
	*/
	public function get _url():String {
		return __fileName
	}
	
	/**
	* returns the clip's total bytes
	*/
	public function get _bytesTotal():Number {
		return __bytesTotal;
	}
	
	/**
	* returns the clip's loaded bytes
	*/
	public function get _bytesLoaded():Number {
		return __bytesLoaded;
	}
	
	/**
	* returns the percentage of the loaded clip
	*/
	public function get _percentLoaded():Number {
		return __bytesLoaded / __bytesTotal * 100;
	}
	
	/**
	* return true if last loading was success
	*/
	public function get _lastSuccess():Boolean {
		return __lastSuccess;
	}
	
	/**
	* return true if the files is loaded
	*/
	public function get _isLoaded():Boolean {
		return __isLoaded;
	}
	
	/**
	* if set to true, the loaded image will get the width and height set 
	* by the current movie clip size, or every call to _core.size
	*/
	public function set _forceSize(value:Boolean) {
		if (value) {
			if (__initObject == undefined) {
				__initObject = new Object();
			}
			__initObject._width = __clip._width;
			__initObject._height = __clip._height;
			__sizeRestrict = true;
			__commander.addEventListener("size", iap.functionUtils.Delegate.create(this, sizeChange));
		} else {
			removeSizeRestriction();
		}
	}
	
	public function progress(meter:Number):Number {
		return __bytesLoaded / __bytesTotal * meter;
	}
	
	/**
	* How many frames to delay after load before sending "loadInit" event
	* Default is one
	*/
	public function get _initDelay():Number{
		return __initDelay;
	}
	
	public function set _initDelay( val:Number ):Void {
		__initDelay = val;
	}

	//}
}
