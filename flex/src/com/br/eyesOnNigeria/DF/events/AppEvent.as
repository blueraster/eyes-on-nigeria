package com.br.eyesOnNigeria.DF.events
{
	import flash.events.Event;
	
	public class AppEvent extends Event
	{
		public static const PHOTO_POPUP:String = 'photoPopUp';
		public static const VIDEO_POPUP:String = 'videoPopUp';
		public static const CLOSE_POP_UP:String = "closePopUp";
		
		public function AppEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
		{
			if (data != null) _data = data;
			super(type, bubbles, cancelable);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		private var _data:Object;
		public function get data():Object
		{
			return _data;
		} 
		
		public function set data(data:Object):void
		{
			_data = data;
		}
		
		override public function clone():Event
		{
			return new AppEvent(type, bubbles, cancelable);
		}
	}
}