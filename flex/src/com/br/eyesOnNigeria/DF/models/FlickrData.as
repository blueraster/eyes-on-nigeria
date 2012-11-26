package com.br.eyesOnNigeria.DF.models
{
	import com.br.eyesOnNigeria.DF.Data.FlickrPhotoVO;
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.utils.WebMercatorUtil;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class FlickrData
	{
		public var flickr_api_key:String = '';
		public var flickr_user_id:String = '';
		public var photos:ArrayCollection = new ArrayCollection();
		public var photo_graphics:ArrayCollection = new ArrayCollection();
		public var initial_tags:Array = [];
		public var set_size_tag:String = '';
		
		public function parseXML(_xml:XML):void {
			//trace(".parseXML() -- _xml = " + _xml.toString());
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
			//trace("FlickrData : " + ObjectUtil.toString(this));
		}
		
		public function clearGraphics():void {
			if (this.photo_graphics.length > 0) 
				this.photo_graphics.removeAll();
		}
		
		public function setGraphicsByTags(tags:Array):void {
			//convert photo vos to graphics
			if (this.photos.length > 0) {
				var graphics:Array = [];
				var gr:Graphic;
				var i:int;
				var bFound:Boolean;
				for each (var vo:FlickrPhotoVO in photos) {
					//trace("----- " + vo.title);
					for (i=0; i<tags.length; ++i) {
						bFound = false;
						for each (var tag:String in vo.tags) {
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
				this.photo_graphics = new ArrayCollection(graphics);
			} else {
				//data not loaded yet, so hold onto tags and repeat this selection as soon as possible (see AppController)
				this.initial_tags = tags;
			}
		}
		
		public function FlickrData(){
		}
		
		public static const instance:FlickrData = new FlickrData();
		
	}
}