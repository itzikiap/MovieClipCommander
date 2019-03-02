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
 import iap.services.*
/**
* Description here...
* @author Default
* @version 0.1
*/

class iap.commander.extentions.Move implements Service {
	private var __manager:ServiceProvider;
	private var __caller:iap.commander.MovieClipCommander;

	private var __direction:String;
	private var __speed:String;

	public function Move(manager:ServiceProvider) {
		__manager = manager;
	}

	public function registerService(caller:ServiceProvider) {
		__caller = caller;
	}

	public function add

}