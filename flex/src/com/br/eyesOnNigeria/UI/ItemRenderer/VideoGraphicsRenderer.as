package com.br.eyesOnNigeria.UI.ItemRenderer
{
	import com.br.eyesOnNigeria.DF.AppController;
	import com.br.eyesOnNigeria.DF.Data.FlickrPhotoVO;
	import com.br.eyesOnNigeria.DF.Data.YouTubeVideoVO;
	import com.br.eyesOnNigeria.UI.containers.PhotoToolTip;
	import com.esri.ags.Graphic;
	import com.esri.ags.renderers.Renderer;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.ClassFactory;
	import mx.core.IToolTip;
	import mx.events.ToolTipEvent;
	import mx.managers.PopUpManager;
	
	import spark.filters.GlowFilter;
	
	public class VideoGraphicsRenderer extends Renderer
	{
		private var glowGraphic:spark.filters.GlowFilter = new GlowFilter(0xdf732a,1,6,6,5,1,false,false);
		private var defaultsym:SimpleMarkerSymbol = new SimpleMarkerSymbol('circle',8,0xff0000,.8,0,0,0,new SimpleLineSymbol('solid',0x00ff00,1,2));
		private var tip:PhotoToolTip;

		public function VideoGraphicsRenderer()
		{
			super();
		}
		
		override public function getSymbol(graphic:Graphic):Symbol
		{
			graphic.addEventListener(MouseEvent.CLICK, onGraphicClick);
			graphic.addEventListener(MouseEvent.MOUSE_OVER, onGraphicMouseOver);
			graphic.addEventListener(MouseEvent.MOUSE_OUT, onGraphicMouseOut);
			graphic.addEventListener(ToolTipEvent.TOOL_TIP_CREATE, createToolTip);
			graphic.toolTip = ' ';
			
			return defaultsym;
		}
		
		private function onGraphicClick(event:MouseEvent):void
		{
			var graphic:Graphic = event.target as Graphic;
			var youtubeVideoVO:YouTubeVideoVO = graphic.attributes as YouTubeVideoVO;
			AppController.videoPopUp(youtubeVideoVO);
		}
		
		private function onGraphicMouseOver(event:MouseEvent):void
		{
			var graphic:Graphic = event.target as Graphic;
			graphic.filters = [glowGraphic];
		}
		
		private function onGraphicMouseOut(event:MouseEvent):void
		{
			var graphic:Graphic = event.target as Graphic;
			graphic.filters = [];
		}
		
		private function createToolTip(event:ToolTipEvent):void
		{
			var graphic:Graphic = event.target as Graphic;
			tip = new PhotoToolTip();
			tip.source = graphic.attributes['thumbnail'];
			event.toolTip = tip;
		}
	}
}