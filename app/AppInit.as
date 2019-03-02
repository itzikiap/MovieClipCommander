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
import iap.app.groups.GroupsManager;
import iap.commander.extentions.CustomMouse;
import iap.commander.extentions.DepthManager;
import iap.commander.MovieClipCommander;

/**
* AppInit class for initializing configuration and global things
* to support the application
*
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.AppInit {
	static private var initialized:Boolean = false;
	/**
	* configurationLoadComplete - dispatches when all the configuration files
	* has done loading
	* extra info:
	* 	[B]downloads[/B] - a downloads object containing all the objects
	*/
	static var EVT_CONFIGURATION_LOAD_COMPLETE:String = ConfigurationManager.EVT_CONFIGURATION_LOAD_COMPLETE;
	
	/**
	* A refference to a default commander created on the root
	*/
	static var ROOT_COMMANDER:MovieClipCommander;
	/**
	* A refference to the root depth extention
	*/
	static var ROOT_DEPTH:DepthManager;
	/**
	* if created, a refference to a custom mouse extention
	*/
	static var CUSTOM_MOUSE:CustomMouse;
	/**
	* A refference to the configuration class
	*/
	static var CONFIGURATION:ConfigurationManager;
	
	/**
	* initialize the AppInit configuration and mouse and stuff
	* reads the default flash vars to initialize in the global params
	* also loads specified configuration files, if not undefined
	* @param	configurationFilesNames	(optional) an array of configuration files to load
	* @param	loadListener	(optional) a listener object to the EVT_CONFIGURATION_LOAD_COMPLETE event
	*/
	public static function init(configurationFilesNames:Array, loadListener:Object) {
		if (!initialized) {
			GlobalParams.init();
			GroupsManager.initialize();
			if (_root.commander != undefined) {
				ROOT_COMMANDER = _root.commander;
			} else {
				ROOT_COMMANDER = new MovieClipCommander(_root);
			}
			ROOT_DEPTH = ROOT_COMMANDER._depth;
			CONFIGURATION = new ConfigurationManager();
			initialized = true;
		}
		if (configurationFilesNames != undefined) {
			loadConfigurationFiles(configurationFilesNames, loadListener);
		}
	}
	
	/**
	* creates a custome mouse movie clip commander
	* @param	mouseFileName	an external SWF to load the custom mouse
	*/
	static function createCustomMouse(mouseFileName:String) {
		var mouseMc:MovieClipCommander = MovieClipCommander(ROOT_COMMANDER.createChild("mouse", 17000));
		CUSTOM_MOUSE = CustomMouse(mouseMc.registerExtention("mouse", CustomMouse, [mouseFileName]));
	}
	
	/**
	* loads specified configuration files and sends the load complete event to the
	* specified listener
	* @param	configurationFilesNames	(optional) an array of configuration files to load
	* @param	loadListener	(optional) a listener object to the EVT_CONFIGURATION_LOAD_COMPLETE event
	*/
	static function loadConfigurationFiles(configurationFilesNames:Array, loadListener:Object) {
		CONFIGURATION.loadConfigurationFiles(configurationFilesNames);
		if (loadListener != undefined) {
			CONFIGURATION.addEventListener(ConfigurationManager.EVT_CONFIGURATION_LOAD_COMPLETE, loadListener);
		}
	}
}

