package com.br.eyesOnNigeria.DF.loaders
{
/*	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
*/	import base.Debug;

import com.br.eyesOnNigeria.DF.Data.FlickrPhotoVO;
import com.br.eyesOnNigeria.DF.Data.FlickrPhotosetVO;
import com.br.eyesOnNigeria.DF.Data.FlickrSearchVO;
import com.br.eyesOnNigeria.DF.events.FlickrEvent;
import com.esri.ags.Graphic;
import com.esri.ags.geometry.MapPoint;
import com.esri.ags.utils.JSON;
import com.esri.ags.utils.WebMercatorUtil;

import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.system.Security;
import flash.system.System;
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.controls.Alert;
import mx.rpc.AsyncResponder;
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.rpc.http.mxml.HTTPService;
import mx.utils.ObjectUtil;

	[Event(name="complete", type="flash.events.Event")]
	[Event(name="searchByTagComplete", type="photo.flickr.FlickrEvent")]
	[Event(name="searchByTextComplete", type="photo.flickr.FlickrEvent")]
	public class FlickrLoader extends EventDispatcher
	{
		private var oLoader:URLLoader = new URLLoader();
		private var oHTTPService:HTTPService = new HTTPService();
		private var flickr_api_key:String;
		private var flickr_secret:String;
		private var flickr_user_id:String;
		
		private const security_policies:Array = [
			'http://farm1.static.flickr.com/crossdomain.xml',
			'http://farm2.static.flickr.com/crossdomain.xml',
			'http://farm3.static.flickr.com/crossdomain.xml',
			'http://farm4.static.flickr.com/crossdomain.xml',
			'http://farm5.static.flickr.com/crossdomain.xml',
			'http://farm6.static.flickr.com/crossdomain.xml'
		]
		
		public function FlickrLoader(flickr_api_key:String, flickr_secret:String = null, flickr_user_id:String = null, target:IEventDispatcher = null)
		{
			debug("() :: api_key=" + flickr_api_key);
			super(target);
			
			this.flickr_api_key = flickr_api_key;
			this.flickr_secret = flickr_secret;
			this.flickr_user_id = flickr_user_id;
		
			this.oLoader.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			this.oLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
		}
		
		public function loadSecurityFiles():void
		{
			debug(".loadSecurityFiles()");
			for each(var f:String in this.security_policies)
			{
				Security.loadPolicyFile(f);
				var domain:String = f.substring(0, f.lastIndexOf('/'))
				Security.allowDomain(domain);
			}
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function getCollectionTree(user_id:String):void
		{
			debug(".getCollectionTree()");
			var params:URLVariables = new URLVariables();
			params.method = 'flickr.collections.getTree';
			params.api_key = this.flickr_api_key;
			params.user_id = user_id;
			params.format = 'json';
			
			var request:URLRequest = new URLRequest('http://api.flickr.com/services/rest/');
			request.data = params;
			
			this.oLoader.addEventListener(Event.COMPLETE, onGetCollectionTreeComplete);
			this.oLoader.load(request);
		}
		
		protected function onGetCollectionTreeComplete(event:Event):void
		{
			debug('.onGetCollectionTreeComplete');
			this.oLoader.removeEventListener(Event.COMPLETE, onGetCollectionTreeComplete);
			var results_dictionary:Dictionary = new Dictionary();
			var raw_result:String = event.currentTarget.data.toString();
			var collections:Array = this.decodeFlickrJSON(raw_result)['collections']['collection'];
			for each(var o:Object in collections)
			{
				//TODO: Implement FlickrCollectionVO here before set loop
				
				for each(var s:Object in o.set)
				{
					var photoset:FlickrPhotosetVO = new FlickrPhotosetVO();
					photoset.id = s.id.toString();
					photoset.title = s.title.toString();
					photoset.description = s.description.toString();
					results_dictionary[o].photosets.push(photoset);
				}
			}
			
			//TODO: Send Dictionary back on FlickrEvent.GetCollectionTreeComplete
			
		}
		
		protected function getPhotoSetPhotos(photoset:FlickrPhotosetVO):void 
		{
			debug(".getPhotoSetPhotos()");
			var photoSetURL:String = 'http://api.flickr.com/services/rest/?';
			photoSetURL += 'method=flickr.photosets.getPhotos';
			photoSetURL += '&api_key=' + this.flickr_api_key;
			photoSetURL += '&photoset_id=' + photoset.id;
			photoSetURL += '&extras=description,tags,machine_tags,views,url_sq, url_t, url_z, url_s, url_m, url_o';
			photoSetURL += '&format=json';
			
			oHTTPService.url = photoSetURL;
			oHTTPService.method = "GET";
			oHTTPService.resultFormat = "text";
			
			var token:AsyncToken = oHTTPService.send();
			token.photosetVO = photoset as Object;
			var responder:AsyncResponder = new AsyncResponder(getPhotosetPhotosResultHandler, getPhotosetPhotosFaultHandler);
			token.addResponder(responder);
		}
		
		protected function getPhotosetPhotosResultHandler(event:ResultEvent, token:Object = null):void 
		{
			debug(".getPhotosetPhotosResultHandler()");
			var photoset:FlickrPhotosetVO = event.token.photosetVO as FlickrPhotosetVO;
			var raw_result:String = event.result.toString();
			var photos:Array = [];
			var photosets:Object = this.decodeFlickrJSON(raw_result).photoset;
			
			for each(var p:Object in photosets.photo) 
			{
				var photoVO:FlickrPhotoVO = parsePhotoVO(p);
				photos.push(photoVO);
			}
			
			photoset.photos = new ArrayCollection(photos);
			this.dispatchEvent(new FlickrEvent(FlickrEvent.PHOTOSET_LOADED, false, false, photoset as Object));
		}
		
		private function getPhotosetPhotosFaultHandler(event:FaultEvent):void 
		{
			Debug.handleLoadError(event.fault, "Flickr Photoset Load Error");
			//debug(String(event.fault));
		}
		
		public function getPublicPhotos(flickrSearchVO:FlickrSearchVO):void
		{
			debug(".getPublicPhotos()");
			var searchURL:String = 'http://api.flickr.com/services/rest/?';
			searchURL += 'method=flickr.people.getPublicPhotos';
			searchURL += '&user_id=' + this.flickr_user_id;
			searchURL += '&api_key=' + this.flickr_api_key;
			searchURL += '&extras=' + flickrSearchVO.extras.join(',');
			searchURL += '&format=json';
			searchURL += '&page=' + flickrSearchVO.page.toString();
			searchURL += '&per_page=' + flickrSearchVO.perpage.toString();
			
			oHTTPService.url = searchURL;
			oHTTPService.method = "GET";
			oHTTPService.resultFormat = "text";
			
			var token:AsyncToken = oHTTPService.send();
			token.flickrSearchVO = flickrSearchVO as Object;
			var responder:AsyncResponder = new AsyncResponder(onGetRecentResult, onPhotoSearchFault);
			token.addResponder(responder);
		}
		
		public function onGetRecentResult(event:ResultEvent, token:Object = null):void
		{
			debug('.onPhotoSearchResult');
			var flickrSearchVO:FlickrSearchVO = event.token.flickrSearchVO as FlickrSearchVO;
			var raw_result:String = event.result.toString();
			var photos:Object = this.decodeFlickrJSON(raw_result).photos;
			
			flickrSearchVO.page = photos.page;
			flickrSearchVO.pages = photos.pages;
			flickrSearchVO.perpage = photos.perpage;
			flickrSearchVO.total = photos.total;
			var photoVOs:Array = [];
			for each(var o:Object in photos.photo)
			{
				var parsedPhoto:FlickrPhotoVO = parsePhotoVO(o);
				photoVOs.push(parsedPhoto);
			}
			
			flickrSearchVO.photos = new ArrayCollection(photoVOs);
			this.dispatchEvent(new FlickrEvent(FlickrEvent.PHOTO_SEARCH_COMPLETE, false, false, flickrSearchVO));
		}
		
		public function photoSearchByTag(flickrSearchVO:FlickrSearchVO, user_id:String = null):void
		{
			debug(".photoSearchByTag()");
			var searchURL:String = 'http://api.flickr.com/services/rest/?';
			searchURL += 'method=flickr.photos.search';
			if(user_id){
				searchURL += '&user_id=' + user_id;
			}else{
				searchURL += '&user_id=' + this.flickr_user_id;
			}
			
			searchURL += '&api_key=' + this.flickr_api_key;
			searchURL += '&tags=' + flickrSearchVO.tags.join(',');
			searchURL += '&machine_tags=' + flickrSearchVO.machine_tags.join(',');
			searchURL += '&tag_mode=all';
			searchURL += '&text=' + flickrSearchVO.search_term;
			searchURL += '&extras=' + flickrSearchVO.extras.join(',');
			searchURL += '&format=json';
			searchURL += '&sort=date-taken-asc';
			searchURL += '&page=' + flickrSearchVO.page.toString();
			searchURL += '&per_page=' + flickrSearchVO.perpage.toString();
			
			oHTTPService.url = searchURL;
			oHTTPService.method = "GET";
			oHTTPService.resultFormat = "text";
			
			var token:AsyncToken = oHTTPService.send();
			token.flickrSearchVO = flickrSearchVO as Object;
			var responder:AsyncResponder = new AsyncResponder(onPhotoSearchResult, onPhotoSearchFault);
			token.addResponder(responder);
		}
		
		public function onPhotoSearchResult(event:ResultEvent, token:Object = null):void
		{
			debug('.onPhotoSearchResult');
			var flickrSearchVO:FlickrSearchVO = event.token.flickrSearchVO as FlickrSearchVO;
			var raw_result:String = event.result.toString();
			var photos:Object = this.decodeFlickrJSON(raw_result).photos;
		
			flickrSearchVO.page = photos.page;
			flickrSearchVO.pages = photos.pages;
			flickrSearchVO.perpage = photos.perpage;
			flickrSearchVO.total = photos.total;
			var photoVOs:Array = [];
			for each(var o:Object in photos.photo)
			{
				var parsedPhoto:FlickrPhotoVO = parsePhotoVO(o);
				photoVOs.push(parsedPhoto);
			}
			
			debug(" :: loaded '" + photoVOs.length + "' photos");
			flickrSearchVO.photos = new ArrayCollection(photoVOs);
			this.dispatchEvent(new FlickrEvent(FlickrEvent.PHOTO_SEARCH_COMPLETE, false, false, flickrSearchVO));
		}
		
		private function onPhotoSearchFault(event:FaultEvent, token:Object = null):void 
		{
			debug(String(event.fault));
		}
		
		public function requestAdditionalPage(searchURL:String):void
		{
			debug(".requestAdditionalPage()");
			this.oLoader.addEventListener(Event.COMPLETE, onAdditionalPageResult);
			this.oLoader.load(new URLRequest(searchURL));
		}
		
		private function onAdditionalPageResult(event:Event):void
		{
			debug('.onAdditionalPageResult');
			this.oLoader.removeEventListener(Event.COMPLETE, onAdditionalPageResult);
			try
			{
				var raw_result:String = event.currentTarget.data.toString();
				var photos:Object = this.decodeFlickrJSON(raw_result).photos;
				
				var photoVOs:Array = [];
				for each(var o:Object in photos.photo)
				{
					photoVOs.push(parsePhotoVO(o));
				}
				
				this.dispatchEvent(new FlickrEvent(FlickrEvent.ADDITIONAL_PAGE_COMPLETE, false, false, photoVOs));
				
			}catch(e:Error){
				//TODO: Determine if "slience" or "Alert" (a.k.a. Debug.handleError) is best for this error 
				//Debug.handleError(e.message, "Flickr Page Parsing Error");
				//debug(e.message);
			}
		}
		
		public function decodeFlickrJSON(flickr_json:String):Object
		{
			debug(".decodeFlickrJSON()");
			flickr_json = flickr_json.replace("jsonFlickrApi(", "");
			flickr_json = flickr_json.substr(0,flickr_json.length - 1);
			var json:Object = JSON.decode(flickr_json);
			return json;
		}
	
		// STATIC ============================================================================================
		public static function parsePhotoVO(json:Object):FlickrPhotoVO
		{
			var photo:FlickrPhotoVO = new FlickrPhotoVO();
			photo.description = json.description || 'no description available';
			photo.farm = json.farm.toString();
			photo.height_m = (json.height_m) ? parseInt(json.height_m) : null;
			photo.height_o = (json.height_o) ? parseInt(json.height_o) : null;	
			photo.height_s = (json.height_s) ? parseInt(json.height_s) : null;
			photo.height_sq = (json.height_sq) ? parseInt(json.height_sq) : null;	
			photo.height_t = (json.height_t) ? parseInt(json.height_t) : null;
			photo.height_z = (json.height_z) ? parseInt(json.height_z) : null;
			photo.id = json.id.toString();		
			photo.isfamily = (json.isfamily == '1') ? true : false;
			photo.isfriend = (json.isfriend == '1') ? true : false;
			photo.ispublic = (json.ispublic == '1') ? true : false;
			photo.latitude = (json.latitude) ? parseFloat(json.latitude) : null;
			photo.longitude = (json.longitude) ? parseFloat(json.longitude) : null;
			photo.machine_tags = json.machine_tags.split(' ') || [];	
			photo.owner = json.owner.toString() || 'owner not set';	
			photo.secret = json.secret.toString() || 'secret not set!';	
			photo.server = json.server.toString() || 'server not set!';
			photo.tags = json.tags.split(' ')  || [];	
			photo.title = json.title.toString() || 'title';
			photo.url = 'http://farm' + json.farm + '.static.flickr.com/' + json.server + '/' + json.id +  '_' + json.secret + '.jpg';
			photo.url_m = json.url_m  || 'not set';
			photo.url_o = json.url_o  || 'not set';;
			photo.url_s = json.url_s || 'not set';;
			photo.url_sq = json.url_sq || 'not set';;	
			photo.url_t = json.url_t || 'not set';;
			photo.url_z = json.url_z || 'not set';;
			photo.views = (json.views != null) ? parseInt(json.views) : null;	
			photo.width_m = (json.width_m) ? parseInt(json.width_m) : null;
			photo.width_o = (json.width_o) ? parseInt(json.width_o) : null;
			photo.width_s = (json.width_s) ? parseInt(json.width_s) : null;	
			photo.width_sq = (json.width_sq) ? parseInt(json.width_sq) : null;
			photo.width_t = (json.width_t) ? parseInt(json.width_t) : null;
			photo.width_z = (json.width_z) ? parseInt(json.width_z) : null;
			
			//Parsed from machine tags
			if(json.machine_tags)
			{
				for each(var t:String in json.machine_tags.split(' '))
				{
					var machine_array:Array = machineTagToArray(t);
					var namespace:String = machine_array[0].toString();
					var predicate:String = machine_array[1].toString();
					var value:String = machine_array[2].toString();
					
					switch(predicate)
					{
						case 'id':
							photo.photo_id = value.toString();
							break;
						
						case 'state':
							photo.state = value.toString();
							break;
						
						case 'location':
							photo.location = value.toString();
							break;
						
						case 'theme':
							photo.theme = value.toString();
							break;
						
						case 'age':
							photo.age = value.toString();
							break;
						
						default:
							break;
					}
				}
			}
			//trace(" :: age=" + photo.age);
			
			return photo;
		}
		
		public static function machineTagToArray(machineTag:String):Array
		{
			//Return an Array of [namespace,predicate,value]
			
			var return_array:Array = [];
			var colon_split:Array = machineTag.split(':');
			var equals_split:Array = colon_split[1].split('=');
			return_array.push(colon_split[0]);
			return_array.push(equals_split[0]);
			return_array.push(equals_split[1]);
			return return_array;
		}
		
		public static function stringToDate( str:String = "" ):Date {
			if ( str == "" ) {
				return null;
			}
			
			var date:Date = new Date();
			// split the date into date / time parts
			var parts:Array = str.split( " " );
			
			// See if we have the xxxx-xx-xx xx:xx:xx format
			if ( parts.length == 2 ) {
				var dateParts:Array = parts[0].split( "-" );
				var timeParts:Array = parts[1].split( ":" );
				
				date.setFullYear( dateParts[0] );
				date.setMonth( dateParts[1] - 1 ); // subtract 1 (Jan == 0)
				date.setDate( dateParts[2] );
				date.setHours( timeParts[0] );
				date.setMinutes( timeParts[1] );
				date.setSeconds( timeParts[2] );
			} else {
				// Create a date based on # of seconds since Jan 1, 1970 GMT
				date.setTime( parseInt( str ) * 1000 );
			}
			
			return date;
		}
		
		public static function dateToString(date:Date):String 
		{
			if (date == null) 
			{
				return "";
			}
			else 
			{
				return date.getFullYear() + "-" + (date.getMonth() + 1)
					+ "-" + date.getDate() + " " + date.getHours()
					+ ":" + date.getMinutes() + ":" + date.getSeconds();
			}
		}
		
		private function handleIOError(event:IOErrorEvent):void
		{
			this.dispatchEvent(new FaultEvent(FaultEvent.FAULT));			
		}
		
		private function handleSecurityError(event:SecurityErrorEvent):void
		{			
			this.dispatchEvent(new FaultEvent(FaultEvent.FAULT));
		}				
		
		
		// DEBUG =============================================================================================
		protected function debug(message:*):void
		{
			//trace('FlickrLoader' + message);
		}
	}
}