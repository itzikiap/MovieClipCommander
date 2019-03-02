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
import iap.app.GlobalParams
import iap.app.ConfigurationManager
 /**
* abstract loader extention for all who wants to load stuff
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.commander.extentions.AbstractLoader extends iap.services.MovieClipService{
	private var __prefix:String;
	private var __postfix:String;
	
	function init() {
		configurePrefixes()
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

}
