package com.br.eyesOnNigeria.DF.Data
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class FlickrPhotosetVO
	{
		public var description:String;
		public var id:String;
		public var ownerId:String;
		public var photoCount:String;
		public var photos:ArrayCollection;
		public var primaryPhotoId:String;
		public var secret:String;
		public var server:String;
		public var title:String;
	
		public function FlickrPhotosetVO()
		{
		}
	}
}