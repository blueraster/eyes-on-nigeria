package com.br.eyesOnNigeria.DF.Data
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class ThemeLayerVO extends Object
	{
		public var type:String = "theme";
		public var id:String = "";
		public var layer_id:String  = "";
		public var tooltip_labelField:String = "";
		public var tooltip_data:ArrayCollection = new ArrayCollection();
		public var markers:ArrayCollection = new ArrayCollection();
		public var fields:Array = [];
		public var url:String = "";
		public function ThemeLayerVO()
		{
			super();
		}
	}
}