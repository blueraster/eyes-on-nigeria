package com.br.eyesOnNigeria.DF.Data
{
	[Bindable]
	public class FlickrPhotoVO
	{
		public var description:Object;
		public var farm:String		
		public var height_m:int;	//"375"	
		public var height_o:int;	//"1536"	
		public var height_s:int;	//"180"	
		public var height_sq:int;	//75 [0x4b]	
		public var height_t:int;	//"75"	
		public var height_z:int;	//"480"	
		public var id:String;	//"5163155473"	
		public var isfamily:Boolean;	//0	
		public var isfriend:Boolean;	//0	
		public var ispublic:Boolean;	//1	
		public var latitude:Number;
		public var longitude:Number;
		public var machine_tags:Array;	//""	
		public var owner:String;	//"51045845@N08"	
		public var secret:String;	//"ec2aa4c244"	
		public var server:String;	//"1381"	
		public var tags:Array;	
		public var title:String;
		public var url:String;
		public var url_m:String;
		public var url_o:String;	
		public var url_s:String;	
		public var url_sq:String;	
		public var url_t:String;	
		public var url_z:String;	
		public var views:int;	
		public var width_m:int;
		public var width_o:int;
		public var width_s:int;	
		public var width_sq:int;
		public var width_t:int;	
		public var width_z:int;
		
		//Eyes on Nigeria Specific
		public var theme:String;
		public var location:String;	
		public var state:String;	
		public var photo_id:String;
		public var age:String = "";
		
		//for tooltips
		public var displayed:Boolean = false;
		public function get _content():String {
			return this.description._content;
		}
		
		//Constructor
		public function FlickrPhotoVO()
		{
		}
	}
}