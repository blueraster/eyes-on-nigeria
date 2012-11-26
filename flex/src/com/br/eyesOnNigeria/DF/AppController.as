package com.br.eyesOnNigeria.DF
{

	import com.br.eyesOnNigeria.DF.Data.FlickrPhotoVO;
	import com.br.eyesOnNigeria.DF.Data.FlickrSearchVO;
	import com.br.eyesOnNigeria.DF.Data.PointLayerVO;
	import com.br.eyesOnNigeria.DF.Data.YouTubeVideoVO;
	import com.br.eyesOnNigeria.DF.events.AppEvent;
	import com.br.eyesOnNigeria.DF.events.FlickrEvent;
	import com.br.eyesOnNigeria.DF.events.YouTubeEvent;
	import com.br.eyesOnNigeria.DF.loaders.FlickrLoader;
	import com.br.eyesOnNigeria.DF.loaders.YouTubeLoader;
	import com.br.eyesOnNigeria.DF.models.AppConfig;
	import com.br.eyesOnNigeria.DF.models.FlickrData;
	import com.br.eyesOnNigeria.DF.models.Themes;
	import com.br.eyesOnNigeria.DF.models.YouTubeData;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="photoPopUp", type="com.DF.events.AppEvent")]
	[Event(name="videoPopUp", type="com.DF.events.AppEvent")]
	[Event(name="closeInfoWindow", type="com.DF.events.AppEvent")]
	[Event(name="closePopUp", type="com.DF.events.AppEvent")]
	
	public class AppController extends EventDispatcher
	{
		// PUBLIC METHODS ====================================================================================
		public static function init():void
		{
			instance.init();
		}
		
		public static function closePopUp():void
		{
			instance.dispatchEvent(new AppEvent(AppEvent.CLOSE_POP_UP, false, false));
		}
		
		public static function photoPopUp(flickrPhotoVO:FlickrPhotoVO):void
		{
			//trace("AppController.photoPopUp() :: title=" + flickrPhotoVO.title);
			instance.dispatchEvent(new AppEvent(AppEvent.PHOTO_POPUP, false, false, flickrPhotoVO));
		}
		
		public static function videoPopUp(youtubeVideoVO:YouTubeVideoVO):void
		{
			//trace("AppController.videoPopUp() :: title=" + youtubeVideoVO.title);
			instance.dispatchEvent(new AppEvent(AppEvent.VIDEO_POPUP ,false, false, youtubeVideoVO));
		}
		
		// LOADERS ====================================================================================
		private var oFlickrLoader:FlickrLoader;
		private var oYouTubeLoader:YouTubeLoader;

		// INITIALIZATION ====================================================================================
		private function init():void 
		{
			//trace("******* AppController.init()");
			this.oFlickrLoader = new FlickrLoader(FlickrData.instance.flickr_api_key, null, FlickrData.instance.flickr_user_id);
			this.oFlickrLoader.addEventListener(Event.COMPLETE,handleFlickrInitComplete);
			this.oFlickrLoader.addEventListener(FlickrEvent.PHOTO_SEARCH_COMPLETE,handleInitialFlickrRequest);
			this.oFlickrLoader.loadSecurityFiles();

			this.oYouTubeLoader = new YouTubeLoader(YouTubeData.instance.youtube_api_key, YouTubeData.instance.youtube_user_id);
			this.oYouTubeLoader.addEventListener(YouTubeEvent.YOUTUBE_LOAD_COMPLETE, handleInitialYouTubeRequest);
			this.oYouTubeLoader.searchUserVideos(YouTubeData.instance.search_for);
			
			var oTimer:Timer = new Timer(100, 1);
			oTimer.addEventListener(TimerEvent.TIMER_COMPLETE, handleInitWaitComplete);
			oTimer.start();
		}
		private function handleInitWaitComplete(event:TimerEvent):void {
			var oTimer:Timer = event.currentTarget as Timer;
			oTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, handleInitWaitComplete);
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		//Photo Search =======================================================================================
		private function handleFlickrInitComplete(event:Event):void {
			this.oFlickrLoader.removeEventListener(Event.COMPLETE,handleFlickrInitComplete);
			
			var initialFlickrRequest:FlickrSearchVO = new FlickrSearchVO();
			initialFlickrRequest.perpage = 500;
			initialFlickrRequest.machine_tags.push('eyesonnigeria:');
			instance.oFlickrLoader.photoSearchByTag(initialFlickrRequest);
		}
		private function handleInitialFlickrRequest(event:FlickrEvent):void 
		{
			this.oFlickrLoader.removeEventListener(FlickrEvent.PHOTO_SEARCH_COMPLETE,handleInitialFlickrRequest);
			var photos:ArrayCollection = event.data.photos;
			// save raw photo vos (graphics vary by theme, so we can't calculate them yet)
			FlickrData.instance.photos = photos;
			
			//TEMP: fall back on hard coded data if server fails to return anything
			if (photos.length == 0) this.useTestFlickrData()
			
			//TEMP:
			//for each (var vo:FlickrPhotoVO in photos) {
				//trace(" :: tags = " + ObjectUtil.toString(vo.tags));
			//}
			
			//if theme was selected before this data finished loading, then set up selection of photo graphics now.
			//trace(" :: initial_tags = " + FlickrData.instance.initial_tags.toString());
			if (FlickrData.instance.initial_tags.length > 0) {
				FlickrData.instance.setGraphicsByTags(FlickrData.instance.initial_tags);
				FlickrData.instance.initial_tags = [];
			}
		}
		
		//Video Search =======================================================================================
		private function handleInitialYouTubeRequest(event:YouTubeEvent):void 
		{
			this.oYouTubeLoader.removeEventListener(YouTubeEvent.YOUTUBE_LOAD_COMPLETE, handleInitialYouTubeRequest);
			//var graphics:ArrayCollection = event.data as ArrayCollection;
			//YouTubeData.instance.video_graphics = graphics;
			var videos:ArrayCollection = new ArrayCollection(event.data as Array);
			YouTubeData.instance.videos = videos
			
			if (videos.length == 0) this.useTestYouTubeData();
			
			//if theme was selected before this data finished loading, then set up selection of photo graphics now.
			//trace(" :: initial_tags = " + YouTubeData.instance.initial_tags.toString());
			if (YouTubeData.instance.initial_tags.length > 0) {
				YouTubeData.instance.setGraphicsByTags(YouTubeData.instance.initial_tags);
				YouTubeData.instance.initial_tags = [];
			}
		}
		
		// CONSTRUCTOR =======================================================================================
		public function AppController()
		{
		}
		
		private function debug(message:*):void
		{
			//trace('AppController' + message);
		}
		
		// FOR TESTING =======================================================================================
		private function useTestFlickrData():void {
			var aPhotos:Array = [];
			var vo:FlickrPhotoVO;
			
			vo = new FlickrPhotoVO();
			vo.latitude = 4.785464;
			vo.longitude = 7.001547;
			vo.title = "Forced Evictions in Port Harcourt";
			vo.description = {_content:"An excavator demolishes houses on Njemanze street, Port Harcourt, Nigeria, April 2010."};
			vo.tags = ["eyesonnigeria:location=portharcourt","eyesonnigeria:theme=forcedevictions"];
			vo.url = "http://farm6.static.flickr.com/5282/5263843943_27c9792015.jpg"
			vo.url_m = "http://farm6.static.flickr.com/5282/5263843943_27c9792015.jpg"
			vo.url_o = "not set"
			vo.url_s = "http://farm6.static.flickr.com/5282/5263843943_27c9792015_m.jpg"
			vo.url_sq = "http://farm6.static.flickr.com/5282/5263843943_27c9792015_s.jpg"
			vo.url_t = "http://farm6.static.flickr.com/5282/5263843943_27c9792015_t.jpg"
			vo.url_z = "http://farm6.static.flickr.com/5282/5263843943_27c9792015_z.jpg"
			vo.height_m = 375
			vo.height_o = 0
			vo.height_s = 180
			vo.height_sq = 75
			vo.height_t = 75
			vo.height_z = 450
			vo.width_m = 500
			vo.width_o = 0
			vo.width_s = 240
			vo.width_sq = 75
			vo.width_t = 100
			vo.width_z = 600
			aPhotos.push(vo);

			vo = new FlickrPhotoVO();
			vo.latitude = 4.653792;
			vo.longitude = 7.283963;
			vo.title = "Sunday Pilla";
			vo.description = {_content:"Sunday Pilla and Sebastian Kpalap, Sunday's brother-in-law and a human rights defender, were assaulted after refusing to pay a bribe to a police officer at a checkpoint outside the Divisional Police Headquarters, Kpor, Rivers state on 1 August 2010. They were returning to Bodo town after buying palm wine for the funeral of Kpalap’s father. As they were passing the police station on a motorcycle, they were stopped by a uniformed policeman who asked for 50 Naira. When they refused to pay, the police officer struck Sunday Pilla across the head with a stick. According to Kpalap, four other plainclothes police officers who had been standing outside the station then joined the assault on Pilla. When Sebastian Kpalap asked them to stop, he was beaten across the head with a stick until he lost consciousness. Sunday Pilla was beaten unconscious and taken into the police station.\n\nBoth men were held in the police station for approximately five hours where they were refused medical treatment or access to a lawyer. Sebastian Kpalap was able to contact the Coordinator of the non-governmental organisation he works for, the Centre for Environment, Human Rights and Development (CEHRD), and the organisation eventually secured the release of the two men. Sunday Pilla and Sebastian Kpalap then went to the Terabor General Hospital, where they received treatment for their injuries. The police later claimed that Sebastian Kpalap attempted to disarm a police officer and that Sunday Pilla beat the same police officer."};
			vo.tags = ["eyesonnigeria:theme=policeandjustice","eyesonnigeria:subtheme=policebrutality"];
			vo.url = "http://farm6.static.flickr.com/5205/5324172789_fc26611947.jpg"
			vo.url_m = "http://farm6.static.flickr.com/5205/5324172789_fc26611947.jpg"
			vo.url_o = "not set"
			vo.url_s = "http://farm6.static.flickr.com/5205/5324172789_fc26611947_m.jpg"
			vo.url_sq = "http://farm6.static.flickr.com/5205/5324172789_fc26611947_s.jpg"
			vo.url_t = "http://farm6.static.flickr.com/5205/5324172789_fc26611947_t.jpg"
			vo.url_z = "not set"
			vo.height_m = 279
			vo.height_o = 0
			vo.height_s = 240
			vo.height_sq = 75
			vo.height_t = 100
			vo.height_z = 0
			vo.width_m = 250
			vo.width_o = 0
			vo.width_s = 215
			vo.width_sq = 75
			vo.width_t = 90
			vo.width_z = 0
			aPhotos.push(vo);

			FlickrData.instance.photos = new ArrayCollection(aPhotos);
		}
		
		private function useTestYouTubeData():void {
			//trace("AppController.useTestYouTubeData()");
			var sampleVideo:YouTubeVideoVO = new YouTubeVideoVO();
			sampleVideo.description = 'this is a test video';
			sampleVideo.location = 'port harcourt, nigeria';
			sampleVideo.id = 'yXOJgqNaX_I'; 
			sampleVideo.title = 'Testing';
			sampleVideo.thumbnail = 'http://i.ytimg.com/vi/yXOJgqNaX_I/2.jpg';
			sampleVideo.latitude = 4.785464 - 0.0003;
			sampleVideo.longitude = 7.001547 + 0.0003;
			sampleVideo.keywords = ["forcedevictions","portharcourt"];
			var sampleVideo2:YouTubeVideoVO = new YouTubeVideoVO();
			sampleVideo2.description = 'this is a test video';
			sampleVideo2.location = 'port harcourt, nigeria';
			sampleVideo2.id = 'W1vZQbZlnkg'; 
			sampleVideo2.title = 'Testing';
			sampleVideo2.thumbnail = 'http://i.ytimg.com/vi/W1vZQbZlnkg/2.jpg';
			sampleVideo2.latitude = 4.785464 - 0.0006;
			sampleVideo2.longitude = 7.001547 + 0.0006;
			sampleVideo2.keywords = ["forcedevictions","portharcourt"];
			YouTubeData.instance.videos = new ArrayCollection( [sampleVideo, sampleVideo2] );
		}
		
		// EVENT BUS==========================================================================================
		private static const instance:AppController = new AppController();
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{
			instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void 
		{
			instance.removeEventListener(type, listener, useCapture);
		}
	}
}