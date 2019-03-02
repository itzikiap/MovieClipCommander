SoundList = function() {
	this.list = [];
	this.count = 0;
	this.depth = 1;
	this.sd = 1;

	this.baseClip = _root.createEmptyMovieClip("sounds",15000);
}

SoundList.prototype.create = function(linkageString,pen,volume) {
	this.linkage = linkageString;
	var clip = this.baseClip.createEmptyMovieClip("sound"+this.depth,this.depth);
	var newSound = new Sound(clip);
	newSound.clip = clip;
	newSound.id = this.depth;
	this.list.push(newSound);
	this.count++;
	newSound.list = this;
	this.depth = (this.newSound > this.sd+3000) ? this.sd : this.depth+1;
 	newSound.removeMe = removeMe;
	newSound.onSoundComplete = removeMe;
	newSound.attachSound(linkageString);
	newSound.start();
	if (pen <> undefined) {
		newSound.setPan(pen);
	}
	if (volume <> undefined) {
		newSound.setVolume(volume);
	}
	return newSound
}

SoundList.prototype.remove = function (id) {
	this.list[id].stop();
	this.list[id].clip.removeMovieClip();
	this.list.splice(id,1);
	this.count--;
}

SoundList.prototype.destroy = function() {
	for (var i = count; i >= 0; i--) {
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

Sound.prototype.toString = function() {
	return "[sound: "+this.id+"]";
}