package com.br.eyesOnNigeria.DF.Data
{
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class FlickrSearchVO
	{
		public var page:int = 1;
		public var pages:int;
		public var perpage:int = 25;
		public var photos:ArrayCollection;
		public var total:int = 0;
		public var tags:Array = [];
		public var machine_tags:Array = [];
		public var search_term:String = '';
		
		public var extras:Array = 
			
			['description',
				'license', 
				'date_upload',
				'date_taken',
				'owner_name',
				'icon_server',
				'original_format',
				'last_update',
				'geo',
				'tags',
				'machine_tags',
				'o_dims',
				'views',
				'media',
				'path_alias',
				' url_sq',
				' url_t',
				' url_s',
				' url_m',
				' url_z',
				' url_l',
				' url_o']
		public function FlickrSearchVO()
		{
		}
	}
}