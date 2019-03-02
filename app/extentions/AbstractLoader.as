
class iap.app.extentions.AbstractLoader extends iap.services.MovieClipService{
	private var __prefix:String;
	private var __postfix:String;
	
	function init() {
		configurePrefixes()
	}
	
	private function configurePrefixes() {
		__commander["_params"].registerGlobalParam("configuration_serverPathPrefix");
		__prefix = __commander["_params"].getString("configuration_serverPathPrefix");
		__commander["_params"].registerGlobalParam("configuration_serverPathPostfix");
		__postfix = __commander["_params"].getString("configuration_serverPathPostfix").split(",").join("&");
	}
	
	public function getProperFileName(fileName:String):String {
		if (__prefix.length > 0) {
			fileName = __prefix+fileName;
		}
		if (__postfix.length > 0) {
			fileName = fileName + "&"+__postfix;
		}
		return fileName;
	}

}
