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
import iap.events.EventDispatcher;
import iap.functionUtils.Delegate;
import iap.manager.*;
import iap.services.ExtentionManager;

/**
 * LoadingManager, Version 2
 * Open Architecture Enabled
 * Description:		A utility class for the managing of simultaneous downloads
 * 				That have a common goal
 *
 * @author		       Liron Le-Fay
 * @author of V2       Itzik I.A.P
 * @version		2
 */

 class iap.manager.LoadingManager{
	/**
	* "loadingManagerComplete" - loading of all data completed
	* extra event info:
	*   downloads: a key-value object containing all the downloads.
	*/
	static var EVT_LOAD_COMPLETE:String = "loadingManagerComplete";
	
	//a array of objects need __downloading
	private var __downloadsList:Array;
    // name indexed object
    private var __downloadsIndex:Object;
	//the number of pendeing downloads
	private var __pendingDownloads:Number;
	//a flag indicating whether the __downloading sarted or not
	private var __downloading:Boolean;
    //objects array
    private var __downloadedObjects:Array;
	//the registered extentions
	private var __extentions:ExtentionManager;
	// prefix and postfix to add to the filename

	//dispatch an event
	private var dispatchEvent:Function;
	/**
	* set an object to listen to LoadingManager  event
	*
	* @param 	type		event type
	* @param		listener 	an object to listen to the event
	*/
	public var addEventListener:Function;
	/**
	* set an object to stop listening to LoadingManager  events
	*
	*  @param	listener 	an object toremive from the listeners list
	*/
    public var removeEventListener:Function;

    /**
	* Initialize the loading manager
	*/
	public function LoadingManager() {
        initializeExtentions();
		EventDispatcher.initialize(this);
		reset();
	}

	/**
	 * add a download to the downloads list
     * As of V2 this method is private
	 *
	 * @param	target	the object to do the __downloading
	 * @param	type		type of the file to be downloaded
	 * @param	url		path to the file to be downloaded
	 */
	private function addDownload(loader:LoaderExtention, type:String, url:String, name:String)	{
		__pendingDownloads++;
        if (name == undefined) {
            name = "download_"+__pendingDownloads;
        }
		var loaderObject:Object = new Object();
		loaderObject.loader = loader;
		loaderObject.type = type;
		loaderObject.url = url;
        loaderObject.name = name;
		__downloadsList.push(loaderObject);
        __downloadsIndex[name] = loader.loader;
	}

    /**
    * quickly adds a download based on the URL
    * detects its type and name based on the url
	* the name is the filname without the extention
	* and without the path - in lowercase
    * creates an object
    *
    * @param    url  the url of th file to load
	* @return	the name of the download
    */
    public function addURL(url:String):String {
        var ext:String = getFileExt(url);
        var name:String = getFileName(url);
        var loader:LoaderExtention;
        var extentionInit:Function;
        extentionInit = __extentions.getExtention(ext);
        loader = new extentionInit(name);
        // have no reason other then preventing a return of local variable as ref
        //__downloadedObjects.push(loader);
        addDownload(loader, ext, url, name);
		return name;
    }

	/**
	* begin loading the added url's
	* @return	true if loading has started, false if loading is happenning
	*/
    public function startLoading():Boolean	{
		if(__downloading) {
			return (false);
		} else {
            var listLen:Number = __downloadsList.length
			for(var i:Number = 0; i < listLen; i++){
				loadObject(__downloadsList[i]);
			}
			return true;
		}
	}
	
	private function reset() {
		__pendingDownloads = 0;
		__downloadsList = new Array();
        __downloadsIndex = new Object();
        __downloadedObjects = new Array();
	}

    public function getFileName(path:String):String {
        var nameStart:Number = path.lastIndexOf("/")+1
        var nameLen:Number = path.lastIndexOf(".") - nameStart;
        var ret:String = path.substr(nameStart,nameLen);
//		ret = ret.toLowerCase();
//		ret = ret.split(" ").join("_");
        return ret;
    }

    private function getFileExt(path:String):String {
        var extStart:Number = path.lastIndexOf(".")+1;
        var ret:String = path.substr(extStart,3);
        return ret;
    }

	private function loadObject(o:Object):Void	{
		var loader:LoaderExtention = o.loader
        loader.load(o.url);
        loader.addEventListener("loadComplete",Delegate.create(this,decreasePending));
	}

	private function decreasePending(evt:Object):Void {
        if (evt.success) {
			__pendingDownloads--;
            if(__pendingDownloads == 0) {
				dispatchEvent({type:EVT_LOAD_COMPLETE, target:this, downloads:_downloads,success:true});
				reset();
            } else if (__pendingDownloads < 0) {
				trace("~4WARNING: LoadinManager pending downloads less then 0. Operation ignored.");
				reset();
			}
        } else {
			__pendingDownloads--;
            trace("~4ERROR: LoadingManager: loading failed: '"+evt.loader.url+"' Still "+__pendingDownloads+" pending");
			dispatchEvent({type:EVT_LOAD_COMPLETE, target:this, downloads:_downloads,success:false,status:evt.status});
        }
	}

    function get _downloads():Object {
        return __downloadsIndex;
    }

    private function initializeExtentions() {
		__extentions = new ExtentionManager();
        __extentions.registerExtention("xml",XmlLoader);
        __extentions.registerExtention("css",CssLoader);
    }
}
