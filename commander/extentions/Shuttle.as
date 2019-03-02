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
 import iap.commander.extentions.Labels;
/**
* Shuttle control for movieClip
* Allow s play the clip in reverse
* V1.2 (by Yohai Rozen):
*	different speed shutteling using interval
*
* @author I.A.P Itzik Arzoni @gmail.com
* @version 1.0
*/
class iap.commander.extentions.Shuttle extends iap.services.MovieClipService {
	/**
	* shuttlePlay - dispatches just before the shuttle begins to play
	* extra info:
	* 		{[B]frame[/B]:__currentFrame,
	* 		[B]destination[/B]:__destFrame,
	* 		[B]speed[/B]:__speed}
	*/
	static var EVT_SHUTTLE_PLAY:String = "shuttlePlay";
	/**
	* shuttleStop - dispatches when the shuttle stops the playing
	* extra info:
	* 		{[B]frame[/B]:__currentFrame,
	* 		[B]speed[/B]:__speed}
	* 		{[B]label[/B]: the label stopped (if mapped before),
	*/
	static var EVT_SHUTTLE_STOP:String = "shuttleStop";
	/**
	* shuttleAbort - dispatches when the shuttle stops the playing 
	* before it reaches the destination.
	* extra info:
	* 		{[B]frame[/B]:__currentFrame,
	* 		[B]speed[/B]:__speed}
	* 		{[B]label[/B]: the label stopped (if mapped before),
	*/
	static var EVT_SHUTTLE_ABORT:String = "shuttleAbort";
	
	//private vars
	private var __destFrame:Number;
	private var __speed:Number;
	private var __currentFrame:Number;
	private var __origFrame:Number;
	private var __loop:Boolean;
	private var __labels:Labels;
	private var __playing:Boolean;
	private var __byInterval:Boolean;
	private var __interval:Number;
	private var __intervalID:Number;

	public function init() {
		__clip.stop();
		__speed = 0;
		__destFrame = 0;
		__currentFrame = 0;
		__playing = false;
		__byInterval = false;
		__loop = false;
	}
	
	public function mapLabels(labelsArr:Array) {
		__labels = Labels(__commander.uniqueExtention("label", Labels, [labelsArr]));
	}
	
	/**
	* shuttle from specified frame to destination frame
	* @param	fromFrame
	* @param	toFrame
	*/
	public function shuttle(fromFrame, toFrame) {
		__clip.gotoAndStop(fromFrame);
		shuttleTo(toFrame);
	}
	
	/**
	* plays the movie clip current frame of the clip to the destination frame
	* @param	frameNum	the destination frame, or destinatio label
	*/
	public function shuttleTo(frameNum) {
		__playing = true;
		if (isNaN(frameNum)) {
			frameNum = __labels.getFrame(frameNum);
		}
		__destFrame = Math.max(Math.min(frameNum, __clip._totalframes),1);
		__currentFrame = __clip._currentframe;
		__origFrame = __currentFrame;
		beginShuttle();
		if (__currentFrame > __destFrame) {
			__speed = -1;
		} else if (__currentFrame < __destFrame){
			__speed = 1;
		} else {
			playDone();
		}
	}
	
//	public function test() {
//		dispatchEvent(EVT_SHUTTLE_STOP);
//	}
	
	public function jumpTo(frameNum) {
		shuttle(frameNum, frameNum);
		playDone();
	}
	
	function gotoAndStop(frameNum) {
		__clip.gotoAndStop(frameNum);
	}
	
	
	public function stop() {
		__clip.stop();
		playDone(true);
	}
	
	private function beginShuttle() {
		dispatchEvent(EVT_SHUTTLE_PLAY, {frame:__currentFrame, destination:__destFrame, speed:__speed});
		if(__byInterval){
			initInterval();
		} else {
			registerClipEvent("onEnterFrame", this);
		}
	}
	
	private function initInterval() {
		clearInterval(__intervalID);
		__intervalID = setInterval(this, "onEnterFrame", __interval);
	}
	
	private function onEnterFrame() {
		__currentFrame += __speed;
		__clip.gotoAndStop(__currentFrame);
		if (__currentFrame == __destFrame) {
			playDone();
		}
		if(__byInterval){
			updateAfterEvent();
		}
	}
	
	private function playDone(isAborted:Boolean) {
		if (__loop && isAborted != true) {
			__currentFrame = __origFrame;
		} else {
			__playing = false;
			var eventName:String;
			if(isAborted==true){
				eventName=EVT_SHUTTLE_ABORT;
			} else {
				eventName=EVT_SHUTTLE_STOP;
			}
			if(__byInterval)clearInterval(__intervalID);
			else removeClipEvent("onEnterFrame");
			dispatchEvent(eventName, {frame:__currentFrame, speed:__speed, label:__labels._currentLabel});
		}
	}
	
	public function set _interval(interval:Number){
		__interval = interval;
		__byInterval = true;
		if (__playing) {
			initInterval();
		}
	}
	
	public function get _speed():Number {
		return __speed;
	}
	
	public function get _lastFrame():Number {
		return __clip._totalframes;
	}
	public function get _firstFrame():Number {
		return 1;
	}
	
	public function get _playing():Boolean {
		return __playing;
	}
	
	public function get _loop():Boolean {
		return __loop;
	}
	public function set _loop(val:Boolean):Void {
		__loop = val;
	}
	
	public function get _currentLabel():String {
		return __labels._currentLabel;
	}

}
