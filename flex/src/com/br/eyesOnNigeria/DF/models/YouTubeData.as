package com.br.eyesOnNigeria.DF.models
{
	import com.br.eyesOnNigeria.DF.Data.YouTubeVideoVO;
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import mx.collections.ArrayCollection;
	 
	[Bindable]
	public class YouTubeData {
		// config
		public var youtube_api_key:String = '';
		public var youtube_user_id:String = '';
		public var search_for:String = '';
		public var cross_domain:String = '';
		public var user_search_prefix:String = '';
		public var user_search_suffix:String = '';
		
		//data
		public var videos:ArrayCollection = new ArrayCollection();
		public var video_graphics:ArrayCollection = new ArrayCollection();
		public var initial_tags:Array = [];
		
		public function parseXML(_xml:XML):void {
			//trace("YouTubeData.parseXML() -- _xml = " + _xml.toString());
			var aNodes:XMLList = _xml.children();
			var sNodeName:String;
			for (var i:int=0; i<aNodes.length(); i++) {
				sNodeName = aNodes[i].name();
				switch (sNodeName) {
					
					default:
						this[sNodeName] = aNodes[i].toString();
						break;
				}
			}
			//trace("YouTubeData : " + ObjectUtil.toString(this));
		}
		
		// ===================================================================================================
		public function clearGraphics():void {
			if (this.video_graphics.length > 0) 
				this.video_graphics.removeAll();
		}
		public function setGraphicsByTags(tags:Array):void {
			//trace("YouTubeData :: videos: " + ObjectUtil.toString(this.videos.toArray()));
			if (this.videos.length > 0) {
				var graphics:Array = [];
				var gr:Graphic;
				var i:int;
				var bFound:Boolean;
				for each (var vo:YouTubeVideoVO in this.videos) {
					/*
					mp = new MapPoint(vo.longitude, vo.latitude);
					mp = WebMercatorUtil.geographicToWebMercator(mp) as MapPoint;
					aGraphics.push( new Graphic(mp, null, vo) );
					*/
					//trace("----- " + vo.title);
					//trace(" : tags=" + tags.toString());
					if (tags.length == 0) {
						bFound = true;
					} else {
						for (i=0; i<tags.length; ++i) {
							bFound = false;
							for each (var tag:String in vo.keywords) {
								//trace(" :: checking " + tags[i] + " ?= " + tag);
								if (tags[i] == tag) {
									//trace(" :::: YES");
									//trace(" :: MATCHED " + tags[i]);
									bFound = true;
									break;
								}
							}
							//if no match then there is no sense continuing, just skip to next vo
							if (!bFound) {
								//trace(" :: DID NOT MATCH " + tags[i]);
								break;
							}
						}
					}
					if (bFound && (vo.latitude != 0 || vo.longitude != 0)) {
						//trace(" :: location: " + vo.latitude + "x" + vo.longitude);
						gr = new Graphic();
						gr.attributes = vo;
						gr.geometry = WebMercatorUtil.geographicToWebMercator(new MapPoint(vo.longitude, vo.latitude)) as MapPoint;
						//trace(" :: Flicker point at " + vo.longitude + "x" + vo.latitude + " = " + gr.geometry.toString());
						graphics.push(gr);
					}
				}
				//trace("FlickrData.setGraphicsByTags() :: found '" + graphics.length + "' graphics out of '" + this.photos.length + "'");
				this.video_graphics = new ArrayCollection(graphics);
				//trace("YouTubeData :: number of graphics = " + this.video_graphics.length);
			} else {
				//data not loaded yet, so hold onto tags and repeat this selection as soon as possible (see AppController)
				this.initial_tags = tags;
			}
		}
		
		// ===================================================================================================
		//SINGLETON========================================================
		public static const instance:YouTubeData = new YouTubeData();
		
		public function YouTubeData() {
		}
	}
}

