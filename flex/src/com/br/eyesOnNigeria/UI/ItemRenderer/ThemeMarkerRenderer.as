package com.br.eyesOnNigeria.UI.ItemRenderer
{
	import com.br.eyesOnNigeria.DF.Data.HeadingVO;
	import com.br.eyesOnNigeria.DF.models.GlobalSharedObject;
	import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.renderers.Renderer;
	import com.esri.ags.symbols.SimpleLineSymbol;
	import com.esri.ags.symbols.SimpleMarkerSymbol;
	import com.esri.ags.symbols.Symbol;
	
	import mx.collections.ArrayCollection;
	
	public class ThemeMarkerRenderer extends Renderer
	{
		public function ThemeMarkerRenderer()
		{
			super();
		}
		
		override public function getSymbol(gr:Graphic):Symbol {
			var oSymbol:SimpleMarkerSymbol = new SimpleMarkerSymbol(SimpleMarkerSymbol.STYLE_CIRCLE, 10, 0xff0000, 1, 0 , 0, 0, 
				new SimpleLineSymbol(SimpleLineSymbol.STYLE_SOLID, 0x000000, 1, 3));
			
			var vo:HeadingVO = gr.attributes as HeadingVO;
			gr.toolTip = vo.label
			return oSymbol;
		}
	}
}