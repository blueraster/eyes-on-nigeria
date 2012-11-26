package com.br.eyesOnNigeria.DF.events
{
	import flash.events.Event;

	public class YouTubeEvent extends Event
	{	
		public static const YOUTUBE_LOAD_COMPLETE:String = "youTubeLoadComplete";		
		
		public function YouTubeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
		{
			if (data != null) _data = data;
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event 
		{
			return new FlickrEvent(type, bubbles, cancelable);
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
	}
}