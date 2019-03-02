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
* extention for intializing the flash vars
* 
* @author      I.A.P Itzik Arzoni (itzik.mcc@gmail.com)
*/
class iap.app.extentions.configuration.InitVars extends iap.services.Service {
	function init(flashVarsArr:Array) {
		for (var o:String in flashVarsArr) {
			var value:String = _root[flashVarsArr[o]];
			value = (value == undefined)? "": value;
			__commander["_params"].setParam("configuration_"+flashVarsArr[o], value);
			__commander["_params"].registerGlobalParam("configuration_"+flashVarsArr[o]);
		}
	}
}
