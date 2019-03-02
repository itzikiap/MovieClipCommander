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
 import iap.app.ConfigurationManager;
import iap.app.GlobalParams;
import iap.manager.LoadingManager;

/**
* LoadManager extention for AppCommander
* --------------------------------------
* Wraps a LoadingManager class and provide a way to synchronize 
* a download of several data files. 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.extentions.LoadManager extends iap.services.Service {
	/**
	* Fires when loading of all components is complete
	* extra info:
	*   [B]downloads[/B] - all the downloads requested by getURL sorted by the names returned as a string from getURL
	*/
	static var EVT_LOAD_COMPLETE:String = "loadManagerComplete";
	
	private var __prefix:String;
	private var __postfix:String;
	private var __loadManager:LoadingManager;
	private var __dictionary:Object;
	private var __downloads:Object;
	
	private var __downloading:Boolean;
	private var __autoLoad:Boolean

	private var __pending:Array;

	private function init()	{
		__loadManager = new LoadingManager();
		__dictionary = new Object();
		__downloads = new Object();
		__loadManager.addEventListener(LoadingManager.EVT_LOAD_COMPLETE, this);
		__downloading = false;
		__autoLoad = false;
		__pending = new Array();
		configurePrefixes();
	}
	
	/**
	* adds a Url to download
	* @param	fileName	the fileName to download
	* @param	name	the name to give the download. (if omitted, the name is auto generated from the file name
	* @return	the name given to the download
	*/
	public function addURL(fileName:String, name:String):String {
		addToPending(fileName, name);
		if (!__downloading && __autoLoad) {
			startLoading();
		}
		if (name == undefined) {
			name = __loadManager.getFileName(fileName);
		}
		return name;
	}
	
	private function addToPending(fileName:String, name:String) {
		__pending.push({fileName:fileName, name:name});
	}
	
	/**
	* sets the URL to download and add it to the dictionary
	* @param	fileName	the filename to load
	* @param	name	the name of the 
	*/
	private function setUrlToDownload(fileName:String, name:String) {
		var newFileName:String = getProperFileName(fileName);
		var newName:String = __loadManager.addURL(newFileName);
		if (name == undefined) {
			name = newName;
		}
		__dictionary[newName] = name;
		return name;
	}
	
	private function flushPendingDownloads() {
		for (var o:String in __pending) {
			setUrlToDownload(__pending[o].fileName, __pending[0].name);
		}
		__pending = new Array();
	}
	
	/**
	* begin loading the files
	*/
	public function startLoading() {
		if (!__downloading) {
			flushPendingDownloads();
			__loadManager.startLoading();
		}
	}
	
	/**
	* gets an XML from the downloads
	* @param	name	the name of the download
	* @return	an XML object
	*/
	public function getXML(name:String):XML{
		return XML(__downloads[name]);
	}
	
	/**
	* resets the downloads  list
	*/
	private function reset() {
		__downloading  = false;
		__pending = new Array();
		//__dictionary = new Array();
		//__downloads = new Array();
	}
	
	/**
	* convert the new downlods by the dictionary definition
	* @param	downloadsObj	the raw donlods object
	*/
	private function importDownloads(downloadsObj:Object) {
		for (var o:String in downloadsObj) {
			__downloads[__dictionary[o]] = downloadsObj[o];
		}
	}
	
	/**
	* initialize the prefixes to add to the URL when loading
	*/
	private function configurePrefixes() {
		__prefix = GlobalParams.getParam("configuration_"+ConfigurationManager.PARAM_SERVER_PATH_PREFIX);
		__postfix = GlobalParams.getParam("configuration_"+ConfigurationManager.PARAM_SERVER_PATH_SUFFFIX).split(",").join("&");
	}
	
	/**
	* gets the file name after adding the prefixes to it
	* @param	fileName	the input file name
	* @return	a file name with all the prefixes
	*/
	public function getProperFileName(fileName:String):String {
		if (__prefix.length > 0) {
			fileName = __prefix+fileName;
		}
		if (__postfix.length > 0) {
			fileName = fileName + "&"+__postfix;
		}
		return fileName;
	}

	
	public function handleEvent(evt:Object) {
		//trace(this+", handle event of type: "+[evt.type,__pending.length] );
		switch (evt.type) {
			case LoadingManager.EVT_LOAD_COMPLETE:
				importDownloads(evt.downloads);
				reset();
				if (__pending.length > 0) {
					startLoading();
				} else {
					dispatchEvent(EVT_LOAD_COMPLETE, {downloads:__downloads, success:true});
				}
				if (!evt.success) {
					trace("~5ERROR: Loading manager failed loadin with status: "+evt.status);
				}
				break;
		}
	}
//{ GETTER-SETTER
	/**
	* set true to automatically start downloading at the first url request
	*/
	public function set _autoLoad(p_autoLoad:Boolean) {
		this.__autoLoad = p_autoLoad;
	}
	public function get _downloading():Boolean {
		return this.__downloading;
	}
	public function get _autoLoad():Boolean {
		return this.__autoLoad;
	}
//}
}
