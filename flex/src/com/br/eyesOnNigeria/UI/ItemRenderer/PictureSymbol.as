package com.br.eyesOnNigeria.UI.ItemRenderer
{
	import com.esri.ags.symbols.PictureMarkerSymbol;
	
	import mx.collections.ArrayCollection;
	
	
	public class PictureSymbol extends PictureMarkerSymbol
	{

		private var Node:ArrayCollection = new ArrayCollection();
		public function PictureSymbol(Node:ArrayCollection, source:Object=null, width:Number=0, height:Number=0, xoffset:Number=0, yoffset:Number=0, angle:Number=0)
		{
			this.Node = Node;
			super(source, width, height, xoffset, yoffset, angle);
		}

	}
}