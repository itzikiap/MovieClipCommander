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
* a simple class to mesure time
* @author I.A.P Itzik Arzoni @gmail.com)
* @version 1.1
*/

class iap.time.Timer {
	private var __time1:Number;
	private var __time2:Number;
	private var __delta:Number;
	
	public function Timer() {
		reset();
	}
	
	public function reset() {
		__time1 = getTimer();
		__time2 = __time1;
		__delta = 0;
	}
	
	public function getMs():Number {
		__time2 = getTimer();
		__delta = __time2 - __time1;
		return __delta;
	}
	
	public function getSeconds():Number {
		return int(getMs() / 1000);
	}
}