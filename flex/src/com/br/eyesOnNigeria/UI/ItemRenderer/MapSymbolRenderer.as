package com.br.eyesOnNigeria.UI.ItemRenderer
{
	import com.br.eyesOnNigeria.DF.AppController;
	import com.br.eyesOnNigeria.DF.Data.FlickrPhotoVO;
	import com.br.eyesOnNigeria.DF.Data.MarkerVO;
	import com.br.eyesOnNigeria.DF.Data.ToolTipItem;
	import com.br.eyesOnNigeria.DF.Data.YouTubeVideoVO;
	import com.br.eyesOnNigeria.DF.events.ToolTipEvent;
	import com.br.eyesOnNigeria.DF.models.GlobalSharedObject;
	import com.br.eyesOnNigeria.DF.models.Themes;
	import com.br.eyesOnNigeria.UI.tooltip.ToolTip;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.MapPoint;
	import com.esri.ags.renderers.Renderer;
	import com.esri.ags.symbols.SimpleFillSymbol;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.messaging.management.Attribute;
	import mx.utils.ObjectUtil;
	
	import spark.filters.GlowFilter;
	
	public class MapSymbolRenderer extends Renderer
	{
		private var aMarkers:ArrayCollection;
		private var map:Map;
		private var acTooltips:ArrayCollection;
		private var global_object:GlobalSharedObject;
		private var selected_year:int = NaN;
		//private var markerList:ArrayCollection;
		//removed by CRB on 2/25 when mouseChildren=false added to ToolTipWrapper
		//private var bKeep:Boolean = false;
		//private var acOldAttributes:Object = new Object();
		
		public function MapSymbolRenderer(markers:ArrayCollection, map:Map, global_object:GlobalSharedObject, tooltips:ArrayCollection=null, selected_year:int=-1)
		{
			//debug("()");
			super();
			this.aMarkers 		= markers;
			this.global_object  = global_object;
			this.map			= map;
			this.acTooltips		= tooltips;
			this.selected_year 	= selected_year;
			//this.markerList 	= new ArrayCollection();
			
			//this.global_object.addEventListener(ToolTipEvent.ROLL_OUT, handleTooltipClose);
			//this.global_object.addEventListener(ToolTipEvent.CLOSE, handleTooltipClose);
		}
		
		override public function getSymbol(gr:Graphic):Symbol {
			var attributes:Object = gr.attributes;
			var mapMarker:MarkerVO;
			var val:*;
			var symbol:Symbol;
			//if (gr.attributes is YouTubeVideoVO && gr.attributes.title) debug(" >> .getSymbol() for video '" + gr.attributes.title + "'");
			
			if (this.aMarkers != null && this.aMarkers.length > 0) {
				for (var i:int=0; i<aMarkers.length; i++) {
					mapMarker = aMarkers[i];
					try {
						val = (mapMarker.fieldname != "" ) ? attributes[mapMarker.fieldname] : "";
					} catch (error:Error) {
						trace("ERROR in MapSymbolRenderer getting value: " + error.message);
						val = "";
					}
					if (mapMarker.fieldname == "" 
							|| (val == mapMarker.value && mapMarker.value != "") 
							|| ((val >= mapMarker.valuemin || isNaN(mapMarker.valuemin)) 
									&& (val <= mapMarker.valuemax || isNaN(mapMarker.valuemax)) 
									&& mapMarker.value == "")
						) {
						if (mapMarker.url.length > 0) {
							symbol = new PictureSymbol(aMarkers,mapMarker.url, mapMarker.size, mapMarker.size);
						} else {
							var sLineStyle:String = (mapMarker.outlinesize > 0) ? SimpleLineSymbol.STYLE_SOLID : SimpleLineSymbol.STYLE_NULL;
							if (gr.geometry.type == "esriGeometryPolygon")
								symbol = new SimpleFillSymbol(SimpleFillSymbol.STYLE_SOLID, mapMarker.color, mapMarker.alpha,
									new SimpleLineSymbol(sLineStyle, mapMarker.outlinecolor, 1, mapMarker.outlinesize));
							else	
								symbol = new SimpleMarkerSymbol(mapMarker.shape, mapMarker.size, mapMarker.color, mapMarker.alpha, 0, 0, 0,
									new SimpleLineSymbol(sLineStyle, mapMarker.outlinecolor, 1, mapMarker.outlinesize));
						}
						if (mapMarker.fieldname != "") break;
					}
				}
			}
			if (this.acTooltips != null && this.acTooltips.length > 0) {
				debug(" :: ADD GRAPHIC EVENTS");
				//gr.addEventListener(Event.REMOVED, clearEvents);
				gr.addEventListener(MouseEvent.ROLL_OVER, showTooltip);
				gr.addEventListener(MouseEvent.ROLL_OUT, hideTooltip);
				if (gr.attributes is FlickrPhotoVO)
					gr.addEventListener(MouseEvent.CLICK, openPhotoPopup);
				else if (gr.attributes is YouTubeVideoVO)
					gr.addEventListener(MouseEvent.CLICK, openVideoPopup);
			
				//trace(" :: selected_year = " + this.selected_year);
				if (!(gr.attributes is FlickrPhotoVO || gr.attributes is YouTubeVideoVO) 
						&& this.selected_year > 1980) {
					//trace(" gr.attributes[" + this.selected_year + "] = " + gr.attributes[this.selected_year.toString()].toString());
					//NOTE: Must use setVisible() and NOT visible= to avoid graphic being deleted from FeatureLayer
					try {
						gr.setVisible(gr.attributes[this.selected_year.toString()].toString() == "1");
					} catch (error:Error) {
						//trace("ERROR: " + error.message);
						//trace(" ... attributes: " + ObjectUtil.toString(gr.attributes));
						//prevent error if FeatureLayer tries to apply year to old graphics (e.g. Jos polygons) before new ones load
						gr.setVisible(false);
					}
				} else {
					gr.setVisible(true);
				}
			}
			
			//super.getSymbol(gr);
			return symbol;
		}
		
		private function clearEvents(event:Event):void {
			debug(".clearEvents()");
			var gr:Graphic = event.currentTarget as Graphic;
			gr.removeEventListener(Event.REMOVED, clearEvents);
			gr.removeEventListener(MouseEvent.ROLL_OVER, showTooltip);
			gr.removeEventListener(MouseEvent.ROLL_OUT, hideTooltip);
			gr.removeEventListener(MouseEvent.CLICK, openPhotoPopup);
			gr.removeEventListener(MouseEvent.CLICK, openVideoPopup);
		}
		
		// ===================================================================================================
		private function showTooltip(event:MouseEvent):void {
			var gr:Graphic = event.currentTarget as Graphic; 
			debug(".showTooltip() -- gr.attributes=" + ObjectUtil.toString(gr.attributes));
			var acAttributes:ArrayCollection = new ArrayCollection();
			var attributes:Object = gr.attributes;
			var lock:Boolean = false;
			var usedAttributes:Array = new Array();
			var mapMarker:MarkerVO;
			var i:int;
			/*
			gr.mouseChildren = false;
			if (attributes == oOldAttributes)
				bKeep=true;
			else {
				handleTooltipClose();
				oOldAttributes = attributes;
			}
			*/
			if  (this.acTooltips != null) {
				//trace("MapSymbolRenderer.showTooltip() :: acTooltips: " + ObjectUtil.toString(this.acTooltips.source));
				
				if (event.type == MouseEvent.CLICK) {
					if (attributes.displayed == true){
						hideTooltip(event);
						gr.attributes.displayed = false;
						lock = false;
					}
					else {
						gr.attributes.displayed = true;
						lock = true;
					}
					//markerList.addItem(gr);
				}
				for (i=0; i<aMarkers.length; i++) {
					mapMarker = aMarkers[i];
					if ((mapMarker.fieldname == "" ) ||
						(((attributes[mapMarker.fieldname] == mapMarker.value) && (mapMarker.value.length > 0))   ||
							((attributes[mapMarker.fieldname] >= mapMarker.valuemin) &&
								(attributes[mapMarker.fieldname] <= mapMarker.valuemax)))) {
						gr.filters = [new GlowFilter(mapMarker.outlinecolor,1,1,1,5,5), new GlowFilter(mapMarker.outlinecolor,0.5,6,6,5,5)];
						break;
					}
					
				}
				//markerList.addItem(gr);

				for (i=0; i<acTooltips.length; i++) {
					if (attributes.hasOwnProperty(acTooltips[i].fieldname) && attributes[acTooltips[i].fieldname] != null)
						usedAttributes.push(acTooltips[i]);
					else if (acTooltips[i].type == ToolTipItem.TYPE_DIVIDER)
						usedAttributes.push(acTooltips[i]);
					else if (acTooltips[i].fieldname == "spacer")
						usedAttributes.push(acTooltips[i]);
				}
				acAttributes = new ArrayCollection(usedAttributes);
				if (gr.geometry.type == "esriGeometryPolygon")
					this.global_object.showTooltip(ToolTip.POSITION_TOP_RIGHT, attributes, acAttributes, lock);
				else							
					this.global_object.showTooltip(this.map.toScreen(gr.geometry as MapPoint).x < this.map.width/2 ? ToolTip.POSITION_TOP_RIGHT : ToolTip.POSITION_TOP_LEFT, attributes, acAttributes, lock);
			}
		}
		
		/*
		private function handleTooltipClose(event:ToolTipEvent=null):void {
			this.global_object.hideTooltip();
			for (var i:int = 0; i<markerList.length; i++) {
				var gr:Graphic = markerList[i];
					gr.filters = [];
					gr.attributes.displayed = false;
			}
			markerList = new ArrayCollection();
		}
		*/

		private function hideTooltip(event:MouseEvent):void {
			debug(".hideTooltip()");
			var gr:Graphic = event.currentTarget as Graphic;
			/*
			if (bKeep)
				bKeep = false;
			else if ((gr.attributes.displayed != true) || (event.type == MouseEvent.CLICK)) {
			*/
				this.global_object.hideTooltip();
				gr.filters = [];
			/*
				bKeep = false;
			}
				*/
		}
		
		// ===================================================================================================
		private function openPhotoPopup(event:MouseEvent):void {
			var gr:Graphic = event.currentTarget as Graphic;
			gr.mouseChildren = false;
			debug(".openPhotoPopup()");
			AppController.photoPopUp(event.currentTarget.attributes);
		}
		private function openVideoPopup(event:MouseEvent):void {
			var gr:Graphic = event.currentTarget as Graphic;
			gr.mouseChildren = false;
			debug(".openVideoPopup()");
			AppController.videoPopUp(event.currentTarget.attributes);
		}
		
		// ===================================================================================================
		private function debug(message:String):void {
			//trace("MapSymbolRenderer" + message);
		}
	}
}