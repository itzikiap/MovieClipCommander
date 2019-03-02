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
 import iap.basic.IndexedHash;
import iap.app.extentions.sequences.IAnimationStep;
import iap.app.extentions.sequences.SequenceStep;
import iap.commander.ICommander;
import iap.time.FrameDelay;

/**
* Sequence Manager extention for AppCommander and MovieClipCommander
* Enables you to define a series of steps defined as a command and an event that end the command,
* and threat them as a sequence. It uses other extentions as the source for the commands and events
*
* @author I.A.P Itzik Arzoni and Itzik Bachar
* @version 1.1
*/
class iap.app.extentions.sequences.SequenceManager extends iap.services.Service {
	/**
	* sequenceDone -
	* {[B]sequenceName[/B]:__currentSequenceName}
	*/
	static var EVT_SEQUENCE_DONE:String = "sequenceDone";
	/**
	* sequenceDelay -
	* internal event for sequences steps of delay
	* The dealy is in frames
	*/
	static var EVT_DELAY:String = "sequenceDelay";
	/**
	* use this event to tell the sequencer not to wait for an event
	* but to jump for the next step
	*/
	static var EVENTLESS_STEP:String = "eventlessStep";
	
	
	private var __sequences:IndexedHash;
	private var __currentSequence:Array;
	private var __currentSequenceName:String;
	private var __nextEvent:String;
	private var __stepNumber:Number;
	private var __delayer:FrameDelay;
	
	private var __isRunning:Boolean;
	
	/**
	* initialize the extention
	*/
	private function init() {
		__sequences = new IndexedHash();
		__delayer = new FrameDelay();
	}
	
	/**
	* open a definition of a new sequence
	* every steps added would be added to this sequence, but only until the command "saveSequence"
	* @param	sequenceName	the defined name of the sequence
	*/
	public function defineSequence(sequenceName:String) {
		if (__currentSequenceName.length > 0 && __currentSequence.length > 0) {
			saveSequence();
		}
		newSequence();
		__currentSequenceName = sequenceName;
	}
	
	/**
	* add a step of a custom AnimationStep class
	* @param	stepthe animation step definition
	*/
	public function addSequenceStep(step:IAnimationStep) {
		__currentSequence.push(step);
	}
	
	/**
	* add a command step to the sequnce
	* @param	extentionName	the name of the extention as defined in the "registerExtention"" method
	* @param	command		the method to call from the extention
	* @param	args	an array of arguments to pass to the command
	* @param	event	the the event to wait
	* @param	customeCommander	if the extention is not registered in the same commander as the sequencer.
	*/
	public function addStep(extentionName:String, command:String, args:Array, event:String, customeCommander:ICommander) {
		var step:IAnimationStep = new SequenceStep(extentionName, command, args, event);
		step.setCustomeCommander(customeCommander);
		addSequenceStep(step);
	}
	
	/**
	* start a definition for a new sequence
	*/
	private function newSequence() {
		__currentSequence = new Array();
		__currentSequenceName = new String();
		__nextEvent = "";
		__stepNumber = 0;
	}
	
	/**
	* saves the steps defined after "defineSequence"
	*/
	public function saveSequence() {
		__sequences.addItem(__currentSequenceName, __currentSequence);
		newSequence();
	}
	
	/**
	* run a defined sequence
	* @param	sequenceName	the name of the sequence to run
	*/
	public function run(sequenceName:String) {
		activeSequence(sequenceName);
		executeNextStep();
	}
	
	public function stopSequence() {
		newSequence();
	}
	
	/**
	* activate a sequence
	* @param	sequenceName	the name of the sequence to activate
	*/
	private function activeSequence(sequenceName:String) {
		newSequence();
		__currentSequence = __sequences.getItem(sequenceName);
		__currentSequenceName = sequenceName;
	}
	
	/**
	* a service to create a delay step in the sequence
	* @param	frames	how many frames to delay
	*/
	public function delay(frames:Number) {
		__delayer = new FrameDelay();
		__delayer.clearFuncList();
		__delayer.delta = frames;
		__delayer.addFunc(this, doneDelay);
		__delayer.run();
	}
	
	/**
	* the delay is done
	*/
	private function doneDelay() {
		__delayer.clearFuncList();
		handleEvent({type:EVT_DELAY,commander:__commander});
	}
	
	/**
	* A must have function for a service
	*/
	public function unregisterService() {
		executeNextStep = undefined;
		stopSequence();
	}
	
	/**
	* executes the next step in the sequence
	*/
	private function executeNextStep() {
		
		if (__stepNumber == __currentSequence.length) {
			dispatchEvent(EVT_SEQUENCE_DONE, {sequenceName:__currentSequenceName});
			newSequence();
		} else {
			var stepDef:IAnimationStep = __currentSequence[__stepNumber];
			var commander:ICommander = stepDef.getCommander(__commander);
			__nextEvent = stepDef.getEvent();
			if(__nextEvent!=EVENTLESS_STEP)	{
				commander.addEventListener(__nextEvent, this);
			}
			stepDef.execute(__commander);
			if (__nextEvent == EVENTLESS_STEP) {
				handleEvent({type:__nextEvent,commander:commander})
			}
		}
	}
	
	private function handleEvent(evt:Object) {
		if (__nextEvent == undefined && evt.type == EVT_DELAY) {
			__nextEvent = evt.type
		}
		if (evt.type == __nextEvent) {
			evt.commander.removeEventListener(__nextEvent, this);
			__stepNumber++;
			executeNextStep();
		}
	}
	
	public function get _isRunning():Boolean {
		return __currentSequence.length > 0;
	}
	
	public function get _currentSequence():Array { return __currentSequence; }
	
	public function get _stepNumber():Number { return __stepNumber; }
	
	public function get _delayer():FrameDelay { return __delayer; }
}
