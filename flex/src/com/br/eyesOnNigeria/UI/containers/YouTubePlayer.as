package com.br.eyesOnNigeria.UI.containers
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.system.Security;
	
	import mx.controls.Label;
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	import mx.utils.ObjectUtil;
	
	import spark.components.ComboBox;
	import spark.components.SkinnableContainer;
	
	[SkinState(name = "loading")]
	[SkinState(name = "complete")]
	public class YouTubePlayer extends SkinnableContainer 
	{
		private var player:Object;
		private var playerLoader:SWFLoader;
		private var youtubeApiLoader:URLLoader;
		
		private static const PLAYER_URL:String = "http://www.youtube.com/apiplayer?version=3";
		private static const SECURITY_DOMAIN:String = "http://www.youtube.com";
		private static const YOUTUBE_API_PREFIX:String = "http://gdata.youtube.com/feeds/api/videos/";
		private static const YOUTUBE_API_VERSION:String = "2";
		private static const YOUTUBE_API_FORMAT:String = "5";
		private static const WIDESCREEN_ASPECT_RATIO:String = "widescreen";
		private static const QUALITY_TO_PLAYER_WIDTH:Object = { small: 320, medium: 640, large: 854, hd720: 1280};
		
		//Player States
		private static const STATE_ENDED:Number = 0;
		private static const STATE_PLAYING:Number = 1;
		private static const STATE_PAUSED:Number = 2;
		private static const STATE_CUED:Number = 5;
		
		public function YouTubePlayer():void 
		{
			this.addEventListener(FlexEvent.INITIALIZE, onInit);
		}
		
		private function onInit(event:FlexEvent):void
		{
			this.removeEventListener(FlexEvent.INITIALIZE, onInit);
			Security.allowDomain(SECURITY_DOMAIN);
			this.setupPlayerLoader();
		}
		
		//---Setup Video Container-------------------------------------------------------------------
		private function setupPlayerLoader():void
		{
			this.youtubeApiLoader = new URLLoader();
			this.youtubeApiLoader.addEventListener(IOErrorEvent.IO_ERROR, youtubeApiLoaderErrorHandler);
			
			this.playerLoader = new SWFLoader();
			this.playerLoader.addEventListener(Event.INIT, playerLoaderInitHandler);
			this.playerLoader.load(PLAYER_URL);
		}
		
		private function playerLoaderInitHandler(event:Event):void
		{
			this.playerLoader.removeEventListener(Event.INIT, playerLoaderInitHandler);
			this.playerLoader.content.addEventListener("onReady", onPlayerReady);
			this.playerLoader.content.addEventListener("onStateChange", onPlayerStateChange);
			this.playerLoader.content.addEventListener("onError", onPlayerError);
		}
		
		private function onPlayerReady(event:Event):void
		{
			player = playerLoader.content;
			playerLoader.autoLoad = true;
			playerLoader.scaleContent = false;
			playerLoader.maintainAspectRatio = true;
			playerLoader.load(player);
			this.contentGroup.addElement(playerLoader);
			this.loadVideo();
		}
		
		private function onPlayerStateChange(event:Event):void
		{
			switch (Object(event).data) 
			{
				case STATE_ENDED:
					this.stop();
					break;
				case STATE_PLAYING:
					this.skin.setCurrentState('playing');
					break;
				case STATE_PAUSED:
					this.skin.setCurrentState('paused');
					break;
				case STATE_CUED:
					break;
			}
		}
		
		private function onPlayerError(event:*):void 
		{
			this.debug("Player error");
		}
		
		//---Load Video Logic-------------------------------------------------------------------
		private function loadVideo():void 
		{
			var urlVariables:URLVariables = new URLVariables();
			urlVariables.v = YOUTUBE_API_VERSION;
			urlVariables.format = YOUTUBE_API_FORMAT;
			
			var request:URLRequest = new URLRequest(this.videoURL);
			request.data = urlVariables;
			
			this.videoId = this.videoURL.substring(this.videoURL.lastIndexOf('/') + 1)
			
			this.youtubeApiLoader.addEventListener(Event.COMPLETE, onLoadVideoComplete);
			this.youtubeApiLoader.load(request);
		}
		
		private function onLoadVideoComplete(event:Event):void 
		{
			this.youtubeApiLoader.removeEventListener(Event.COMPLETE, onLoadVideoComplete);
	
			var atomXml:XML = new XML(youtubeApiLoader.data as String);
			player.cueVideoById(this.videoId, 0, 'medium');
			player.visible = true;
			player.setSize(FlexGlobals.topLevelApplication.width-275>630?630:FlexGlobals.topLevelApplication.width-275, FlexGlobals.topLevelApplication.height-100>360?360:FlexGlobals.topLevelApplication.height-100);
			player.setPlaybackQuality('medium')
			this.play();
		}
		
		private function youtubeApiLoaderErrorHandler(event:IOErrorEvent):void 
		{
			this.debug("Error making YouTube API request: " + ObjectUtil.toString(event));
		}
		
		//---Lifecyle Methods-------------------------------------------------------------------
		override protected function commitProperties():void
		{
			if(videoURLChanged && this.videoURL != "" && this.player)
			{
				videoURLChanged = false;
				this.videoId = this.videoURL.substring(this.videoURL.lastIndexOf('/') + 1)
				this.loadVideo();
			}
		}
		
		//Public : videoID-------------------------------------------------
		public var videoId:String = '';
		
		//Public : videoURL-------------------------------------------------
		private var _videoURL:String = '';
		private var videoURLChanged:Boolean = false;
		[Bindable('videoURLChanged')]
		public function set videoURL(value:String):void
		{
			if(this._videoURL != value)
			{
				this._videoURL = value;
				this.videoURLChanged = true;
				this.dispatchEvent(new Event('videoURLChanged'));
				this.invalidateProperties();
			}
		}
		
		public function get videoURL():String
		{
			return this._videoURL;
		}
		
		//Debug --------------------------------------------------------------
		private function debug(message:*):void
		{
			//trace('YouTubePlayer' + message);
		}
		
		//Skinning Contract --------------------------------------------------------------
		[SkinPart(required="true")]
		public var playButton:UIComponent;
		
		[SkinPart(required="true")]
		public var pauseButton:UIComponent;
		
		[SkinPart(required="true")]
		public var stopButton:UIComponent;
		
		[SkinPart(required="true")]
		public var rewindButton:UIComponent;
		
		[SkinPart(required="true")]
		public var forwardButton:UIComponent;
		
		private function play(event:MouseEvent = null):void 
		{
			if(player == null)
				return;
			
			player.playVideo();
			this.skin.setCurrentState('playing');
		}
		
		//Exposed as public to enable pausing when closing infowindow
		public function pause(event:MouseEvent = null):void 
		{
			if(player == null)
				return;
			
			player.pauseVideo();
			this.skin.setCurrentState('paused');
		}
		
		public function stop(event:MouseEvent = null):void
		{
			if(player == null)
				return;
			
			player.pauseVideo();
			player.seekTo(0, true);
			this.skin.setCurrentState('paused');
		}
		
		public function rewind(event:MouseEvent = null):void
		{
			if(player == null)
				return;
			
			var time:Number = this.player.getCurrentTime();
			
			if(time == 0)
				return;
			
			player.seekTo(time - 10, true);
		}
		
		public function fastForward(event:MouseEvent = null):void
		{
			if(player == null)
				return;
			
			var time:Number = this.player.getCurrentTime();
			
			if(time == player.getDuration())
				return;
			
			player.seekTo(time + 10, true);
		}
		
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			if(instance == playButton)
			{
				playButton.addEventListener(MouseEvent.CLICK, play);
			}
			
			if(instance == pauseButton)
			{
				pauseButton.addEventListener(MouseEvent.CLICK, pause);
			}
			
			if(instance == stopButton)
			{
				stopButton.addEventListener(MouseEvent.CLICK, stop);
			}
			
			if(instance == rewindButton)
			{
				rewindButton.addEventListener(MouseEvent.CLICK, rewind);
			}
			
			if(instance == forwardButton)
			{
				forwardButton.addEventListener(MouseEvent.CLICK, fastForward);
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			if(instance == playButton)
			{
				playButton.removeEventListener(MouseEvent.CLICK, play);
				playButton.enabled = false;
			}
			
			if(instance == pauseButton)
			{
				pauseButton.removeEventListener(MouseEvent.CLICK, pause);
				pauseButton.enabled = false;
			}
			
			if(instance == stopButton)
			{
				stopButton.removeEventListener(MouseEvent.CLICK, stop);
				stopButton.enabled = false;
			}
			
			if(instance == rewindButton)
			{
				rewindButton.removeEventListener(MouseEvent.CLICK, rewind);
			}
			
			if(instance == forwardButton)
			{
				forwardButton.removeEventListener(MouseEvent.CLICK, fastForward);;
			}
			
			if(instance == contentGroup)
			{
				
			}
		}
		
		override protected function getCurrentSkinState():String
		{
			return currentState;
		}
	}
}

