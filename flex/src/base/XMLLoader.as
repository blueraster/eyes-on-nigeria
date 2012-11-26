package base
{
	import base.Debug;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class XMLLoader extends EventDispatcher {
		// PUBLIC PROPERTIES =================================================================================
		public var show_error_dialogs:Boolean = true;
		public var callback_pointer:Function;
		public var callback_params:Array;
		
		public var data:Object;
		
		public function get url():String {
			return this.sURL;
		}
		public function get xml():XML {
			var oXML:XML;
			try {
				oXML = XML(oURLLoader.data);
			} catch (error:Error) {
				oXML = new XML();
				if (this.show_error_dialogs) Debug.handleError("Cannot parse XML in " + this.sURL + "\n\n" + error.message, "XML Error");
			}
			return oXML;
		}
		public function get complete():Boolean {
			return this.bLoaded;
		}		
		public function get failed():Boolean {
			return this.bFailed;
		}		
		// PUBLIC METHODS ====================================================================================
		public function load(p_url:String):void {
			debug(".load()");
			this.sURL = p_url;
			this.oURLLoader = new URLLoader();
	   		this.oURLLoader.addEventListener(Event.COMPLETE, onDataLoaded);
	   		this.oURLLoader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
	   		this.oURLLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
	   		this.oURLLoader.load(new URLRequest(this.sURL));
		}

		// PRIVATE PROPERTIES ================================================================================		
		private var sURL:String = "";
		private var oURLLoader:URLLoader;
		private var bLoaded:Boolean = false;
		private var bFailed:Boolean = false;
		
		// CONSTRUCTOR =======================================================================================
		public function XMLLoader():void {
			debug(".XMLLoader()");
		}
		
		// LOAD HANDLING =====================================================================================
		private function onIOError(event:IOErrorEvent):void {
			debug(".onIOError(" + event.toString() + ")");
			var sText:String = event.text; // + "\n url:" + this.sURL;
			this.bFailed = true;
			this.bLoaded = true;
			if (this.show_error_dialogs) {
				Debug.handleError(sText, "XML Data Load Error (" + this.sURL + ")");
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, sText));
			}
		}
		private function onSecurityError(event:SecurityErrorEvent):void {
			debug(".onSecurityError(" + event.toString() + ")");
			var sText:String = event.text; // + "\n url:" + this.sURL;
			this.bFailed = true;
			this.bLoaded = true;
			if (this.show_error_dialogs) {
				Debug.handleError(sText, "XML Data Load Error (" + this.sURL + ")");
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, sText));
			}
		}
		private function onDataLoaded(event:Event):void {				
			debug(".onDataLoaded(" + event + ")");
			this.bFailed = false;
			this.bLoaded = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}		

		// DEBUG =============================================================================================
		private function debug(sText:String):void {
			//trace("XMLLoader" + sText);
		}
	}
}
