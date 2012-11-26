package com.br.eyesOnNigeria.UI.ItemRenderer
{
	import com.br.eyesOnNigeria.DF.Data.MarkerVO;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Geometry;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	
	import flash.display.Sprite;
	
	import mx.collections.ArrayCollection;
	
	public class TooltipSymbol extends SimpleMarkerSymbol
	{
		private const OVER:SimpleLineSymbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, 0xffff00, 1, 3);
		private var markers:ArrayCollection = new ArrayCollection();
		
		public function TooltipSymbol(Node:ArrayCollection,style:String="circle", size:Number=15, color:Number=0xFF0000, alpha:Number=1, xoffset:Number=0, yoffset:Number=0, angle:Number=0, outline:SimpleLineSymbol=null)
		{
			var NORMAL:SimpleLineSymbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, 0xFFFFFF, 1, 1);
			
			this.markers = Node;
			super(style, size, color, alpha, xoffset, yoffset, angle, NORMAL);
		}
		
		override public function draw(sprite:Sprite, geometry:Geometry, attributes:Object, map:Map):void {
			var outlineColor:Number;
			var mapMarker:MarkerVO;
			var NORMAL:SimpleLineSymbol = new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, outlineColor, 1, 1);
			for (var i:int=0; i<markers.length; i++) {
				mapMarker = markers[i];
				if  ((mapMarker.url.length > 0) && 
					(((attributes[mapMarker.fieldname] == mapMarker.value) && (mapMarker.value.length > 0))    ||
					(attributes[mapMarker.fieldname] >= mapMarker.valuemin) &&
					(attributes[mapMarker.fieldname] <= mapMarker.valuemax)))
				{
					break;
				}
				else {
					if ((mapMarker.fieldname == "" ) || 
					(((attributes[mapMarker.fieldname] == mapMarker.value) && (mapMarker.value.length > 0))   ||
					((attributes[mapMarker.fieldname] >= mapMarker.valuemin) &&
					 (attributes[mapMarker.fieldname] <= mapMarker.valuemax)))) {
						outlineColor = mapMarker.outlinecolor;
						NORMAL.color = mapMarker.outlinecolor;
						this.outline=  NORMAL;
						this.color 	=  mapMarker.color;
						this.size   =  mapMarker.size;
						this.style  =  mapMarker.shape;
						super.draw(sprite, geometry, attributes, map);
						break;
					}
				}
			}
		}

	}
}