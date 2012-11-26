package com.br.eyesOnNigeria.DF.Data
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class YouTubeVideoVO
	{
		public var description:String = "";
		public var id:String = "";
		public var thumbnail:String = "";
		public var title:String = "";
		public var latitude:Number = 0;
		public var longitude:Number = 0;
		public var location:String = "";
		public var duration:Number = 0;
		public var keywords:Array = [];
		public var video_url:String = "";
		
		//Eyes on Nigeria Specific
		public var theme:String = "";
		
		//for tooltips
		public var displayed:Boolean = false;
		
		public function YouTubeVideoVO()
		{
		}
	}
}