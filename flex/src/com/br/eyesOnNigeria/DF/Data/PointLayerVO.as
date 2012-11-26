package com.br.eyesOnNigeria.DF.Data
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class PointLayerVO extends Object
	{
		public var type:String="point";
		public var id:String="";
		public var layer_id:String = "";
		public var tooltip_labelField:String = "";
		public var tooltip_data:ArrayCollection = new ArrayCollection();
		public var markers:ArrayCollection = new ArrayCollection();
		public var fields:Array = [];
		public var tags:Array = [];
		public var years:Array = [];
		public var url:String = "";

		public function PointLayerVO()
		{
			super();
		}
	}
}