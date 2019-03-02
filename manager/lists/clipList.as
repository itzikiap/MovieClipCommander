ClipList = function(linkageString,base,startDepth) {
	this.list = [];
	this.count = 0;
	this.depth = (startDepth == undefined) ? 0 : startDepth;
	this.sd = startDepth;
	this.linkage = linkageString;
	this.baseClip = base;
	trace("list of "+linkageString+" in "+base);
}

ClipList.prototype.makeBase = function(depth) {
	if (this.count == 0) {
		var newBaseClip = this.baseClip.createEmptyMovieClip(this.linkage+"sHolder",depth);
		this.baseClip = newBaseClip;
		return newBaseClip;
	}
}



ClipList.prototype.create = function() {
	var clip = this.baseClip.attachMovie(this.linkage,this.linkage+this.depth,this.depth);
	this.list.push(clip);
	this.count++;
	clip.list = this;
	this.depth = (this.clip > this.sd+3000) ? this.sd : this.depth+1;
	clip.id = this.depth;
 	clip.removeMe = removeMe;
	return clip
}

ClipList.prototype.remove = function (id,playLabel) {
	if (playLabel == undefined) {
		this.list[id].removeMovieClip();
	} else if (playLabel == true) {
		this.list[id].play();
	} else {
		this.list[id].gotoAndPlay(playLabel);
	}

	this.list.splice(id,1);
	this.count--;
}

ClipList.prototype.traceList = function() {
	trace("trasing list:");
	for (var o in this.list) {
		trace("- "+this.list[o]);
	}
}

ClipList.prototype.destroy = function() {
	for (var i = this.count; i >= 0; i--) {
		this.remove(i);
	}
}

function removeMe() {
	for (var o in this.list.list) {
		if (this.list.list[o].id == this.id) {
			this.list.remove(o);
		}
	}
}