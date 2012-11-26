package com.br.eyesOnNigeria.DF.loaders
{			
	import base.Debug;
	
	import com.br.eyesOnNigeria.DF.Data.YouTubeVideoVO;
	import com.br.eyesOnNigeria.DF.events.YouTubeEvent;
	import com.br.eyesOnNigeria.DF.models.YouTubeData;
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.Security;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.StringUtil;

				
	public class YouTubeLoader extends EventDispatcher
	{
		namespace atom = "http://www.w3.org/2005/Atom";
		namespace media = "http://search.yahoo.com/mrss/";
		namespace gd = "http://schemas.google.com/g/2005";
		namespace yt = "http://gdata.youtube.com/schemas/2007";
		namespace georss = "http://www.georss.org/georss";
		namespace gml = "http://www.opengis.net/gml";
		namespace open = "http://a9.com/-/spec/opensearchrss/1.0/";

		private var search:HTTPService = new HTTPService();	
		private var youtube_api_key:String = '';
		private var youtube_user_id:String = '';
		
		private const security_policies:Array = [
			YouTubeData.instance.cross_domain
		]
		
		public function YouTubeLoader(youtube_api_key:String = null, youtube_user_id:String = null)
		{
			debug(".YouTubeLoader()");	
			this.youtube_api_key = youtube_api_key;
			this.youtube_user_id = youtube_user_id;
			
			this.loadSecurityFiles();
		}
		
		protected function loadSecurityFiles():void
		{
			for each(var f:String in this.security_policies)
			{
				Security.loadPolicyFile(f);
				var domain:String = f.substring(0, f.lastIndexOf('/'))
				Security.allowDomain(domain);
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function searchUserVideos(search_term:String):void
		{
			var searchURL:String = YouTubeData.instance.user_search_prefix + this.youtube_user_id + YouTubeData.instance.user_search_suffix + "?"
			searchURL += 'key=' + this.youtube_api_key;
			searchURL += '&q=' + search_term;
			search.url = searchURL;
			search.resultFormat = 'e4x';
			search.addEventListener(ResultEvent.RESULT, onSearchResult);
			search.addEventListener(FaultEvent.FAULT, onSearchFault);
			search.send();
		}

		private function onSearchResult(event:ResultEvent):void {			
			use namespace atom;
			use namespace media;
			use namespace gd;
			use namespace yt;
			use namespace georss;
			use namespace gml;
			use namespace open;
			
			var aVideos:Array = [];
			var videoVO:YouTubeVideoVO;
			var aKeywords:Array;
			var sKeywords:String;
			var sPos:String;
			var aPos:Array;
			for each(var entry:XML in event.result..entry) 
			{
				sPos = entry.where.Point.pos.toString();
				aPos = sPos.split(" ");
				if (sPos != "" && aPos.length >= 2) {
					debug(" :: video at " + sPos);
					videoVO = new YouTubeVideoVO();
					videoVO.description = entry.content.toString();
					videoVO.id = extractVideoId(entry.id.toString());
					videoVO.title = entry.title.toString();
					videoVO.location = entry.location.toString();
					videoVO.thumbnail = entry.group.thumbnail[1].@url.toString();
					videoVO.duration = parseFloat(entry.group.duration.toString());
					videoVO.video_url = entry.id.toString();
					//TODO: Replace with tagged values
					//videoVO.latitude = 4.785464 - (aVideos.length+1)*0.0003;
					//videoVO.longitude = 7.001547 + (aVideos.length+1)*0.0003;
					videoVO.latitude = parseFloat(aPos[0]);
					videoVO.longitude = parseFloat(aPos[1]);
					/*
					aKeywords = [];
					for each (var cat:XML in entry.category) {
						aKeywords.push(cat.@term.toString());
					}
					debug(" :::: keywords: " + aKeywords.toString());
					videoVO.keywords = aKeywords;
					*/
					sKeywords = entry.group.keywords.toString();
					sKeywords = StringUtil.trimArrayElements(sKeywords, ",");
					videoVO.keywords = sKeywords.split(",");
					debug(" :::: keywords: " + videoVO.keywords.toString());
					
					aVideos.push(videoVO);
				}
			}
			debug(" :: '" + aVideos.length + "' videos found");
			this.dispatchEvent(new YouTubeEvent(YouTubeEvent.YOUTUBE_LOAD_COMPLETE, false, false, aVideos));
		}
		
		private static function extractVideoId(videoSearchResultId:String):String
		{
			var id: String = videoSearchResultId.substring(videoSearchResultId.lastIndexOf('/')+1)
			return id;
		}
		
		private function onSearchFault(event:FaultEvent):void
		{
			Debug.handleLoadError(event.fault, "YouTube List Failed To Load");
			this.dispatchEvent(new YouTubeEvent(YouTubeEvent.YOUTUBE_LOAD_COMPLETE, false, false, []));
		}

						
		// DEBUG ====================================================================================================================
		private function debug(sText:String):void {
			//trace("YouTubeLoader" + sText);
		}
	}
}