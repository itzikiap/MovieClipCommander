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
 import iap.app.extentions.configuration.InitVars;
import iap.app.extentions.LoadManager;

/**
* Configuration manager - enables a configuration managment for the application
* can be configured to get configuration vars from the flash vars
* can be configured to start the application after a settings file has been loaded
* 
* the flash vars are registered as GlobalParam using the Information extention
* Each of them gets a "configuration_" prefix
* i.e: if a configuration is called: "appState"
* the global param will be called: "configuration_appState"
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.ConfigurationManager extends iap.app.AppCommander {
	/**
	* configurationLoadComplete - dispatches when all the configuration files
	* has done loading
	* extra info:
	* 	[B]downloads[/B] - a downloads object containing all the objects
	*/
	static var EVT_CONFIGURATION_LOAD_COMPLETE:String = "configurationLoadComplete";
	static var PARAM_SERVER_PATH_PREFIX:String = "serverPathPrefix";
	static var PARAM_SERVER_PATH_SUFFFIX:String = "serverPathPostfix";
	private var __initVars:InitVars;
	private var __loadManager:LoadManager;

	/**
	* creates a ConigurationManager instance
	* @param	flashVars	an array of flash vars to scan
	*/
	function ConfigurationManager(flashVars:Array) {
		if (flashVars == undefined) {
			flashVars = new Array();
		}
		__initVars = InitVars(registerExtention("initVars", InitVars, [flashVars.concat([PARAM_SERVER_PATH_PREFIX, PARAM_SERVER_PATH_SUFFFIX])]));
		__loadManager = LoadManager(registerExtention("loadManager", LoadManager));
	}
	
	/**
	* loads a bounch of configuration files.
	* dispatches an event when the loading is complete
	* @param	fileList	a list of files to load in an array
	*/
	public function loadConfigurationFiles(fileList:Array) {
		for (var o:String in fileList) {
			__loadManager.addURL(fileList[o]);
		}
		__loadManager.startLoading();
		addEventListener(LoadManager.EVT_LOAD_COMPLETE, this);
	}
	
	/**
	* handleEvent method
	*/
	private function handleEvent(evt:Object) {
		//trace(this+", handle event of type: "+[evt.type]);
		switch (evt.type) {
			case LoadManager.EVT_LOAD_COMPLETE:
				if (evt.success) {
					dispatchEvent({downloads:evt.downloads}, EVT_CONFIGURATION_LOAD_COMPLETE);
				}
				break;
		}
	}
}
