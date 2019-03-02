import mx.utils.Delegate;
import mx.events.EventDispatcher;

/**
* @author Itzik I.A.P
*/
class iap.lists.StreamLoad {
	private var DEFAULT_BPS:Number = 102400;

	private var __clip:MovieClip;
	private var __buffer:Number;
	private var __loaded:Number;
	private var __total:Number;
	private var __timer:Number;
	private var __playTime:Number;
	private var __movieTimeLoad:Number;
	private var __playing:Boolean;
	private var __bps:Number;
	private var __bandwidth:Number;
	private var __loading:Boolean;
	private var __playWhenReady:Boolean;
	private var __time1:Number;
	private var __time2:Number;
	private var __playTime:Number;
    private var __loader:MovieClip;

	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;

	function StreamLoad(movieClipRef:MovieClip) {
		__clip = movieClipName;
		__buffer = 0;
		__loaded = 0;
		__total = 0;
		__timer = 0;
		__playTime = 0;
		__movieTimeLoad = 0;
		__playing = false;
		__bandwidth = 0;
		__loading = false;
		__playWhenReady = true;
		__time1 = 0;
		__time2 = 0;
		__playTime = 0;
		__loader = _root.createEmptyMovieClip(movieClipRef._name+"_Loader",movieClipRef.getDepth()+1000);
		setBps(DEFAULT_BPS);
	}

	function setBps = (newBps:Number):Boolean {
		if (!__loading) {
			__bps = newBps;
			return true
		} else {
			return false
		}
	}

	function setMovieTime(newMT:Number):Boolean {
		if (!__loading) {
			__playTime = newMT;
			return true
		} else {
			return false
		}
	}

	/**
	* loads the desired file
	* @param	fileName
	*/
	function load(fileName:String) {
		__clip.loadMovie(fileName);
		__loader.stream = this;
		__loader.onEnterFrame = Delegate.create(this,loadLoop1);
	}

	/**
	* calculate the buffers, called each second
	*/
	function calculateBuffers() {
		// seconds counter
		stream._time1 = stream._time2;
		// calculating bandwidth (bytes/sec)
		stream._bandwidth = stream._loaded / (stream._timer);
		// the time it would tak to load the movie
		stream._movieTimeLoad = stream._bandwidth * stream._playTime;
		// calculating buffer (in each second seperatly). multiple by slack to minimize errors
		this.stream._buffer =  (stream._total - stream._movieTimeLoad) * __bufferSlack;
	}

	/**
	* the first loop to wait for server response
	*/
	function loadLoop1() {
		__loaded = steram._clip.getBytesLoaded();
		__total = stream._clip.getBytesTotal();
		resetTimer();
		if (__total > 24) {
			trace("total bytes of "+fileName+": "+stream._total);
			delete __loader.onEnterFrame;
			loadPass2();
		} else if (checkTimer(1)) {
			loadFailed();
		}
	}

	function loadPass2() {
		var evt:Object = new Object();
		evt.target = this;
		evt.name = "loadInit";
		evt.clip = __clip;
		evt.success = true;
		evt.url = __fileName
		dispatchEvent(evt);
		__loading = true;
	// 	var time = new Date();
		__movieTimeLoad = 0;
		if (this.playTime == 0) {
			__playTime = __total / __bps;
		} else {
			__bps = __total / __playTime;
		}

		__playByte = 0;
		__clip.stop();
		trace("buffering... total play time: " + __playTime+" with Bps of "+__bps);
		__buffer = __total;
		__oldBuffer = 0;
		__loader.onEnterFrame = Delegate.create(this,loadLoop2);
	}

	function loadLoop2() {
		var stream = this.stream;
		stream._loaded = stream._clip.getBytesLoaded();

		var evt:Object = new Object();
		evt.target = this;
		evt.name = "loadProgress";
		evt.clip = __clip;
		evt.time = __timer;
		evt.bytesLoaded = __loaded;
		evt.bytesBuffer = __buffer;
		evt.bytesTotal = __total;
		dispatchEvent(evt);
		if (stream._loaded >= stream._buffer) {
			delete this.onEnterFrame;
			stream.loadPass3();
		}
		if (checkTimer(__timer+1)) {
			trace("\nloaded "+stream._loaded+" bytes in "+(stream._timer)+" seconds");
			calculateBuffer();
			trace("banwidth is: "+stream._bandwidth+" safeplay at "+stream._buffer+". movieTimeLoad is "+stream._movieTimeLoad);

		}
	}
}

streamLoad.prototype.loadPass3 = function() {
	__playing = true;
	trace("|"+this.onPlay+"|   |"+this.onProgress+"|");
	if (__playWhenReady) __clip.play();
	this.onPlay();
	trace("done buffering. start playing");
	__loader.onEnterFrame = function() {
		var stream = this.stream;
		var time = new Date();
		stream._time2 = time.getSeconds();
		stream._loaded = stream._clip.getBytesLoaded();
// 		stream.onProgress(stream._clip);
		if (stream._loaded >= stream._total) {
			delete this.onEnterFrame;
			stream.playLoop();
		}
	}
}

	function loadFailed() {
		var evt:Object = new Object();
		evt.target = this;
		evt.name = "loadFail";
		evt.clip = __clip;
		evt.success = fales;
		evt.url = __fileName
		dispatchEvent(evt);

	}
streamLoad.prototype.playLoop = function() {
	this.onDone();
	__loader.onEnterFrame = function() {
		var stream = this.stream;
		var time = new Date();

// 		stream.onProgress(stream._clip);
		if (stream._clip._currentframe == stream._clip._totalframes) {
			delete this.onEnterFrame;
			stream.onDonePlaying();
		}
	}
}

	function resetTimer() {
		__time1 = int(getTimer()/1000);

	}
	/**
	* updates the time and check it for
	* @param	timerLimit
	* @return true if limit exeeded
	*/
	function checkTimer(timerLimit:Number):Boolean {
		var ret:Boolean = false;
		stream._time2 = int(getTimer()/1000);
		if (stream._time2 > stream._time1) {
			__timer++;
			if (__timer >= timerLimit) {
				ret = true;
			}
		}
		return ret;
	}
streamLoad.prototype.interruptAndPlay = function() {
	trace("interrupting");
	delete __loader.onEnterFrame;
	this.loadPass3();
}

streamLoad.prototype.abort = function(areYouSure) {
	if (areYouSure) {
		trace("aborting");
		__clip.unloadMovie();
		__loader.removeMovieClip();
		__clip.swapDepths(10000);
		__clip.removeMovieClip();
	}
	return areYouSure
}

