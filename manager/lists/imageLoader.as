ImageLoader = function() {
// 	var mc1= mc;
// 	if (typeof mc == "string") {
// 		mc1 = eval(mc);
// 	}
	this.clip = mc1;
	this.fileName = "";
	this.loaderClip = null;
    this.listener = this;
}

ImageLoader.prototype.defineListener = function(newListener) {
    var listener = newListener;
    this.listener = listener;
	this.loaderClip.listener = this.listener;
    this.loaderClip.onLoadStart = listener.onLoadStart;
	this.loaderClip.onLoadProgress = listener.onLoadProgress;
	this.loaderClip.onLoadComplete = listener.onLoadComplete;
	this.loaderClip.onLoadFail = listener.onLoadFail;
}

ImageLoader.prototype.loadClip = function(fileName,clip) {
    this.clip = clip;
	this.fileName = fileName;
	ImageLoader.prototype.depth++;
	this.loaderClip = _root.createEmptyMovieClip("imageLoaderer"+ImageLoader.prototype.depth,ImageLoader.prototype.depth);
	this.loaderClip.onEnterFrame = loadFunction;
    this.loaderClip.clip = this.clip;
	this.loaderClip.cycles = 0;
    this.loaderClip.loading = false;
    this.defineListener(this.listener);
	this.clip.loadMovie(this.fileName);
}
ImageLoader.prototype.depth = 12200;

function loadFunction() {
	var clip = this.clip;
    var bl = clip.getBytesLoaded();
    var bt = clip.getBytesTotal();
	var percent = Math.floor(bl / bt * 100);
	 if (clip == undefined || bt < -1) {
		if (this.cycles++ == 13) {
			this.removeMovieClip();
			this.onLoadFail.apply(this.listener,[this.clip]);
		}
	} else if (!this.loading) {
        this.loading = true;
        this.onLoadStart.apply(this.listaner,[this.clip]);
		percent = 0;
	}
	this.onLoadProgress.apply(this.listener,[clip,bl,bt])
	if (percent == 100) {
		this.onLoadComplete.apply(this.listener,[this.clip]);
		this.onEnterFrame = null;
		this.removeMovieClip();
	}
}

