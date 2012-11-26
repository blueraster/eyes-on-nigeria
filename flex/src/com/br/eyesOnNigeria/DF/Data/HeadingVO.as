package com.br.eyesOnNigeria.DF.Data
{
	import com.esri.ags.geometry.Extent;
	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class HeadingVO extends Object
	{
		public var heading:Boolean = false;
		public var label:String = "";
		public var id:String= "";
		public var location_image_url:String= "";
		public var toolTip:String = "";
		public var theme:ArrayCollection = new ArrayCollection();
		public var extent:Extent;
		public var description:String = "";
		public var stats:ArrayCollection = new ArrayCollection();
		public var legendTitle:String = "";

		public function HeadingVO()
		{
			super();
		}
	}
}