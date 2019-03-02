
class iap.basic.Utils {
	//Trim a string:
	static function stringTrim(txt_str:String, chars:String):String {
		if (chars == undefined) {
			chars = " \t";
		}
		while (chars.indexOf(txt_str.charAt(0)) > -1) {
			txt_str = txt_str.substring(1, txt_str.length);
		}
		while (chars.indexOf(txt_str.charAt(txt_str.length-1))> -1) {
			txt_str = txt_str.substring(0, txt_str.length-1);
		}
		// trace(txt_str);
		return txt_str;
	};


	static function stringTrimNewLine(text_str:Array, seperator:String, chars:String):String {
		var temp_array = text_str.split(chr(13)+chr(10));
		var temp1_array = [];
		for (i=0; i < temp_array.length; i++) {
			if (trim(temp_array[i]) != "") {
				temp1_array.push(stringTrim(temp_array[i], chars));
			}
		}
		var new_str = temp1_array.join(seperator);
		return new_str;
	}
}
