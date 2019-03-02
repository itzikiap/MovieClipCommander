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

/**
* wrapper for movieclips. Doesn't do much of its own,
* but provides functionality to MovieClipCommander
* 
* History:
* Version 1.5:
*  + Added managing child clips (and wrappers)
*  + Added destroy\
* Version 1.6 
*  + Added "unwrap" function
* @author I.A.P Itzik Arzoni @gmail.com
* @version 1.5 05/03/2006
*/

dynamic class iap.commander.MovieClipWrapper {
	private var __clip:MovieClip;
	private var __children:IndexedHash;
	private var __parent:MovieClipWrapper;
	private var __DefaultConstructor:Function = MovieClipWrapper;
	
	/**
	* the constructor gets a clip refferance. if this is the only argument, the operation is performed on the clip.
	* if provided clipName, then the new clip is created inside the clipRef
	* if provided linkage, the new created clip eould be attached from the library, rether then created empty
	* @param	clipRef refferance to the clip
	* @param	clipName if exist, new clip name that would be created
	* @param	depth the new clip depth
	* @param	linkage if exist, the linkage of the symbol to attach
	*/
	public function MovieClipWrapper(clipRef:MovieClip,clipName:String,depth:Number,linkage:String) {
		var newClip:MovieClip = defineClip(clipRef,linkage,clipName,depth);
		__clip = newClip;
		if (__clip.commander != undefined) {
			trace("~5ERROR: MovieClipWrapper. The clip "+__clip+" already has a wrapper!");
//			return __clip.commander;
		} else {
			__clip = newClip;
			__children = new IndexedHash();
			linkClip();
		}
	}

	/**
	* define the new clip, either as the refferenced clip, or new clip
	* @param	clipRef	the refferance of the holder clip
	* @param	linkage (optional) library linkage to attach
	* @param	clipName	(optional) name for the new clip
	* @param	depth	(optional)
	*/
	private function defineClip(clipRef:MovieClip,linkage:String,clipName:String,depth:Number):MovieClip {
		var clip:MovieClip;
		if (clipName == undefined) {
			clip = clipRef;
		} else if (linkage == undefined || linkage.length < 1) {
			if (clipRef[clipName] == undefined) {
				clip = clipRef.createEmptyMovieClip(clipName,depth);
			} else {
				clip = clipRef[clipName];
				if (depth != undefined) {
					clip.swapDepths(depth);
				}
			}
		} else {
			clip = clipRef.attachMovie(linkage,clipName,depth);
			if (clip == undefined) {
				trace("~5ERROR: MoveClipWrapper: unable to attach linkage "+linkage+" to "+clipRef+", possibly does not exist.");
			}
		}
		//calcParent(clipRef, clipName);
		return clip;
	}
	
	/**
	* calculates a correct depth depending if the depth or _parent are undefined
	* @param	depth	the input depth
	* @return	the correct depth
	*/
	private function getCorrectDepth(clipRef:MovieClip, depth:Number):Number {
		if (depth == undefined) {
			if (_parent == undefined) {
				depth = clipRef.getNextHighestDepth();
			} else {
				//Ha! tricked you. In "MovieClipCommander" runtime, the object "_depth" would exist :P
				depth = _parent._depth.higher;
			}
		}
		return depth;
	}
	
	/**
	* calculates the __parent movieClipCommander based on existing definition
	* if __clip is defined - gets the commander associated of the _parent of the __clip
	* if not, and clipRef.clipName is defined, then the commander associated with clipRef is taken
	* else, the commander associated with the _parent of clipRef is taken
	* @param	clipRef
	* @param	clipName
	*/
	private function calcParent(clipRef:MovieClip, clipName:String) {
		var clip:MovieClip;
		if (__clip != undefined) {
			clip = __clip; 
		} else if (clipRef[clipName] != undefined) {
			clip = clipRef[clipName];
		} else {
			clip = clipRef;
		}
		if (clip._parent.commander != undefined) {
			__parent = clip._parent.commander;
		}
	}

	/**
	* Creates an unwrapped movie clip inside the movieclip of this wrapper
	* @param	clipName	the name for the new clip
	* @param	depth	depth for the new clip
	* @param	linkage	(optional) if omitted, the movieclip would be created
	* @return	a refference to the movie clip
	*/	
	public function createMovieClip(clipName:String,depth:Number,linkage:String):MovieClip {
		var createdClip:MovieClip = defineClip(__clip,linkage,clipName,depth);
		return createdClip;
	}

	/**
	* creates a child wrapper movie clip with a movieClip
	* can be implemented for different kinds of classes extending "MovieClipWrapper"
	* just supply "childConstructor" parameter
	* @param	clipName	the name of the clip and the new wrapper to be created
	* @param	depth	the depth of the new clip
	* @param	linkage	(optional) linkage to a librery asset
	* @param	childConstructor	(optional) refference to a constructor function to create. Must extend MovieClipWrapper.
	* @return	the newly created wrapper, or refference to the existing child
	*/
	public function createChild(clipName:String, depth:Number, linkage:String, childConstructor:Function):MovieClipWrapper {
		if (!__children.isExist(clipName)) {
			var newConstructor:Function = (childConstructor == undefined)? __DefaultConstructor : childConstructor;
			var newClip:MovieClipWrapper = MovieClipWrapper(new newConstructor(__clip, clipName, depth, linkage));
			if (newClip["__clip"] != undefined) {
				__children.addItem(clipName,newClip);
			} else {
				newClip.destroy();
			}
			return newClip;
		} else {
			trace("~5WARNING: Already existing child "+clipName+" in "+this+". Returning it.");
			return MovieClipWrapper(__children.getItem(clipName));
		}
	}
	
	/**
	* Wrap a child MovieClip in this commander with a commander.
	* Same as "createChild", but with a checking if the movieclip exist
	* @param	clipName	The name to be expected to wrap
	* @param	depth	(Optional)	 New Depth for the Movie Clip
	* @param	childConstructor	(Optional)	 refference to a constructor function to create. Must extend MovieClipWrapper.
	* @return	a refferance to the instance created or undefined
	*/
	public function wrapChild(clipName:String, depth:Number):MovieClipWrapper {
		if (__clip[clipName] != undefined) {
			var ret:MovieClipWrapper = createChild(clipName, depth);
			return ret;
		} else {
			trace("~5ERROR: Attempt to wrap a movie clip that does not exist. "+clipName+" in '"+__clip+"' Operation ignored.");
			return undefined
		}
	}
	
	public function removeChild(name:String) {
		var clip:MovieClipWrapper = getChild(name);
		if (clip == undefined) {
			trace("~5ERROR: Attempt to remove an unexisting movie clip wrapper: "+name+". Operation ignor");
		}
		clip.destroy();
	}
	
	public function unwrap() {
		delete __clip.commander;
		__parent.delChildRef(_name);
		delete __clip;
	}
	
	/**
	* destroy this movieclip wrapper, its clip, and all of its children.
	* also deletes itself from the his parent ref
	*/
	public function destroy() {
		unloadChildren();
		var clip:MovieClip = __clip;
		unwrap();
		clip.removeMovieClip();
		clip.unloadMovie();
	}
	
	/**
	* duplicates a child movie clip and wrap it again
	* [B] deprecated! [/B]
	* @param	clipName	the new clip depth
	* @param	depth
	* @return
	*/
	public function duplicateChild(childName:String, clipName:String, depth:Number):MovieClipWrapper {
		var mcw:MovieClipWrapper = getChild(childName);
		var clip:MovieClip = mcw._clip;
		clip.duplicateMovieClip(clipName, depth);
		var ret:MovieClipWrapper = wrapChild(clipName);
		return ret;
	}

	/**
	* get a chilren wrapper for a clip at any depth, with a given path.
	* getChild("boy1.head.eye");
	* will get you the wrapper for the eye of boy1
	* @param	clipPath
	* @return	the destination child
	*/
	public function getChild(clipPath:String):MovieClipWrapper {
		var path:Array = clipPath.split(".");
		var wrapper:MovieClipWrapper = MovieClipWrapper(__children.getItem(String(path.shift())));
		if (path.length == 0) {
			return wrapper;
		} else {
			return wrapper.getChild(path.join("."));
		}
	}

	/**
	* and destroy all the wrapper child clips
	* does not destroy the clip itself, and the wrapper
	*/
	public function unloadChildren() {
		var childrenNames:Array = __children.names;
		for (var o in childrenNames) {
			var child:MovieClipWrapper = getChild(childrenNames[o]);
			child.destroy();
		}
	}
	
	
	/**
	* delete a wrapper referrance from the children list
	* @param	childName
	* @return	true if succesfull operation
	*/
	public function delChildRef(childName:String):Boolean {
		var ret:Boolean = (__children.removeItem(childName) != undefined);
		return ret;
	}

	/**
	* link a clip to this wrapper
	*/
	private function linkClip() {
		__clip.commander = this;
		calcParent();
	}

	/**
	* the clip being wrapped
	*/
	public function get _clip():MovieClip {
		return __clip;
	}

	/**
	* the parent wrapper
	*/
	public function get _parent():MovieClipWrapper {
		return __parent;
	}

	/**
	* name of the movieclip assosiated with the wrapper
	*/
	public function get _name():String {
		var ret:String = (__clip == undefined)? "NoClip!!":__clip._name
		return ret;
	}

	/**
	* An array of all the childrens
	*/
	public function get _children():Object {
		var childArr:Object = __children.exportObject();
		return childArr;
	}
	function toString():String {
		return "[Commander "+__clip+"]";
	}
	
	public function debugTrace() {
		trace("~2 -------------- debug tracing: "+ this);
		var children:Object = _children;
		for (var o:String in children) {
			trace(">      "+children[o]);
		}
		trace("~2 -------------- done debug tracing");
	}
}
