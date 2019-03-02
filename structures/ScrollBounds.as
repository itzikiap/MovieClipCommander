
class iap.structures.ScrollBounds {
 	private var __minimum:Number;
	private var __maximum:Number;
	private var __value:Number;
	private var __extent:Number;
	
	/**
	* sets the virtual dimention 
	*/
	private var __vBounds:ScrollBounds;
	
	function ScrollBounds(min:Number, max:Number, val:Number, ext:Number) {
		if (min > max) {
			var t:Number = max;
			max = min;
			min = t;
		} else if (max == min) {
			max++;
		}
		__minimum = min;
		__maximum = max;
		__value = (val == undefined)? min:val
		__extent = (ext == undefined)? 1:ext;
	}
	
	function setVBounds(min:Number, max:Number, val:Number, ext:Number) {
		__vBounds = new ScrollBounds(min, max);
		val = (val == undefined)? val : __value;
		ext = (ext == undefined)? ext : __extent;
		_value = getTranslatedValue(val);
		_extent = getTranslatedValue(ext);
	}
	
	function getTranslatedValue(val:Number) {
		if (val == undefined) {
			val = _value;
		}
		return val * _ratio;
	}
	
	function getRealValue(val:Number):Number {
		if (val == undefined) {
			val = _value;
		}
		return val / _ratio;
	}
	
//{ GETTER-SETTER
	public function set _minimum(p_minimum:Number) {
		this.__minimum = Math.min(p_minimum, __value-1);
		if (_vBounds != undefined) {
			_vBounds._minimum = getRealValue(__minimum);
			_vBounds._value = getRealValue(__value);
			_vBounds._extent = getRealValue(__extent);
		}
	}
	public function set _maximum(p_maximum:Number) {
		this.__maximum = Math.max(p_maximum, __value + __extent+1);
		if (_vBounds != undefined) {
			_vBounds._maximum = getRealValue(__maximum);
			_vBounds._value = getRealValue(__value);
			_vBounds._extent = getRealValue(__extent);
		}
	}
	public function set _value(p_value:Number) {
		__value = Math.max(Math.min(__maximum-__extent, p_value), __minimum);
		if (_vBounds != undefined) {
			_vBounds._value = getRealValue(__value);
		}
	}
	public function set _extent(p_extent:Number) {
		this.__extent = Math.max(Math.min(__maximum - __value, p_extent), __value);
		if (_vBounds != undefined) {
			_vBounds._extent = getRealValue(p_extent);
		}
	}
	public function get _minimum():Number {
		return this.__minimum;
	}
	public function get _maximum():Number {
		return this.__maximum;
	}
	public function get _value():Number {
		return __value;
	}
	public function get _extent():Number {
		return this.__extent;
	}
	public function get _range():Number {
		return __maximum - __minimum;
	}
	public function get _ratio():Number {
		return _range / _vBounds._range;
	}
	public function get _vBounds():ScrollBounds {
		return __vBounds
	}
//}

	function toString():String {
		return "[ScrollBounds "+[_value,_range]+"]"; 
	}
}
