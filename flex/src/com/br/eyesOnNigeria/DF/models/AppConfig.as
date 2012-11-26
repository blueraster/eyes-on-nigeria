package com.br.eyesOnNigeria.DF.models
{
	import com.esri.ags.geometry.Extent;
	
	import spark.filters.GlowFilter;
	
	[Bindable]
	public class AppConfig
	{
		public const SYMBOL_GLOW:Array = [new GlowFilter(0xffffff, 1, 4, 4, 1, 3)];
		//NOTE: These values are directly tied to the show/hide markers properties below, with THEME not supporting show/hide
		public const MARKER_TYPE_THEME:String = "theme";
		public const MARKER_TYPE_FIRST:String = "first";
		public const MARKER_TYPE_SECOND:String = "second";
		public const MARKER_TYPE_PHOTO:String = "photo";
		public const MARKER_TYPE_VIDEO:String = "video";
		public const MARKER_TYPE_AGSPOINT:String = "agsTooltip";
		
		public var initial_extent:Extent;

		public var base_mapserver_url:String = "";
		public var topo_url:String = "";
		public var ve_access_key:String = "";
		public var ve_map_style:String = "";
		public var introHeading:String = "";
		public var introText:String = "";
		
		// show/hide markers
		public var show_markers_first:Boolean = true;
		public var show_markers_second:Boolean = true;
		public var show_markers_photo:Boolean = true;
		public var show_markers_video:Boolean = true;
		public var show_markers_agsTooltip:Boolean = true;
		
		public function parseXML(_xml:XML):void {
			debug(".parseXML() -- _xml = " + _xml.toString());
			var aNodes:XMLList = _xml.children();
			var sNodeName:String;
			for (var i:int=0; i<aNodes.length(); i++) {
				sNodeName = aNodes[i].name();
				switch (sNodeName) {
					case "initial_extent":
						this.initial_extent = new Extent(_xml.initial_extent.@xmin, _xml.initial_extent.@ymin, _xml.initial_extent.@xmax, _xml.initial_extent.@ymax);
						break;
					//case "services":
					//	ServerConfig.xml = xml.services as XML;
					//	break;
					default:
						this[sNodeName] = aNodes[i].toString();
						break;
				}
			}
			//trace("AppConfig : " + ObjectUtil.toString(this));
		}
		
		public function AppConfig()
		{
		}
		
		public static const instance:AppConfig = new AppConfig();
		
		private function debug(message:String):void {
			//trace("AppConfig" + message);
		}
	}
}