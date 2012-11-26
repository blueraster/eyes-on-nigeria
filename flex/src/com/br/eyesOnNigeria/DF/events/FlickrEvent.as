package com.br.eyesOnNigeria.DF.events
{
	import flash.events.Event;

	public class FlickrEvent extends Event
	{
		public static const PHOTO_SEARCH_INITIALIZED:String = "photoSearchInitialized";
		public static const PHOTO_SEARCH_SENT:String = "photoSearchSent";
		public static const PHOTO_SEARCH_COMPLETE:String = "photoSearchComplete";
		public static const ADDITIONAL_PAGE_COMPLETE:String = "additionalPageComplete";
		public static const GET_BEST_OF_PHOTOSET:String = "getBestOfPhotoset";
		public static const GET_GALLERY_PHOTOSETS:String = "getGalleryPhotosets";
		public static const PHOTOSET_LOADED:String = "photosetLoaded";
								
		
		// CLONE =============================================================================================
		override public function clone():Event {
			return new FlickrEvent(type, bubbles, cancelable);
		}
		
		public function FlickrEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:Object=null)
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

	}
}