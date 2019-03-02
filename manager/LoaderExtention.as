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
import iap.events.EventDispatcher;
import iap.functionUtils.Delegate;
/**
 * LoaderExtention
 * Description:	  base class for extentions to loadingManager. Must be extended
 * @author        Itzik I.A.P
 * @version		  1
 */

class iap.manager.LoaderExtention{
    // the actual data object, wather its XML or CSS or what ever. Must be instenciated in the derived class
    private var __loader:Object;
    // the url of the file
    private var __url:String;

    // evet dispatcher functions
    private var dispatchEvent:Function;
    public var addEventListener:Function;
    public var removeEventListener:Function;

    /**
    * constructor function
    */
    function LoaderExtention() {
        EventDispatcher.initialize(this);
    }

    /**
    * the main load command. only pass URL
    */
    public function load(urlToLoad:String) {
        __url = urlToLoad;
		var delegated = Delegate.create(this,loadComplete)
        registerListener("onLoad",delegated);
        startLoading(urlToLoad);
    }

    /**
    * the listener registration function
    * taking into account each data set has its own listeners,
    * this function provide the basic "callback" listener,
    * and must be overwriten for more complex listeners
    * @param  listenerName the name of the listener
    * @param listenerFunction the callback function of the listener.
    */
    private function registerListener(listenerName:String,listenerFunction:Function) {
        __loader[listenerName] = listenerFunction;
    }
    // this function must be overwriten in descendent classes
    private function startLoading(url:String) {
        __loader.load(url);
    }

    private function loadComplete(success:Boolean) {
        var evt:Object = new Object();
        evt.type = "loadComplete";
        evt.target = __loader;
        evt.loader = this;
        evt.success = success;
		evt.status = __loader.status;
        dispatchEvent(evt);
    }

    function get url():String {
        return __url;
    }

    function get loader():Object {
        return __loader;
    }
}

