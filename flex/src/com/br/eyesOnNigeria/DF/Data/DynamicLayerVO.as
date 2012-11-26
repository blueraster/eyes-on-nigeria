package com.br.eyesOnNigeria.DF.Data
{
	[Bindable]
	public class DynamicLayerVO extends Object
	{
		public var type:String  = "dynamic";
		public var id:String    = "";
		public var label:String = "";
		public var layers:Array = new Array(); 
		public var url:String = "";

		public function DynamicLayerVO()
		{
			super();
		}
	}
}