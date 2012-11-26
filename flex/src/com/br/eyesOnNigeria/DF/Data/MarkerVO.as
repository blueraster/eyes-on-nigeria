package com.br.eyesOnNigeria.DF.Data
{
	[Bindable]
	public class MarkerVO
	{
		public var color:Number 	= 0xFF0000;
		public var size:Number 		= 15;
		public var shape:String 	= "circle";
		public var outlinecolor:Number 	= 0x000000;
		public var outlinesize:Number 	= 1;
		public var array_index:Number = 0;
		public var url:String       = "";
		public var height:Number	= 15;
		public var width:Number		= 15;
		public var fieldname:String = "";
		public var value:String		= " ";
		public var valuemin:Number 	= -1;
		public var valuemax:Number	= -1;
		public var format:String	= "";
		public var precision:Number = 0;
		public var label:String		= "";
		public var alpha:Number		= 1;
		
		public function MarkerVO()
		{
		}
	}
}