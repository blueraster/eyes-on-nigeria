package com.br.eyesOnNigeria.DF.models
{
	import com.br.eyesOnNigeria.DF.Data.DynamicLayerVO;
	import com.br.eyesOnNigeria.DF.Data.HeadingVO;
	import com.br.eyesOnNigeria.DF.Data.ImageLayerVO;
	import com.br.eyesOnNigeria.DF.Data.MarkerVO;
	import com.br.eyesOnNigeria.DF.Data.PointLayerVO;
	import com.br.eyesOnNigeria.DF.Data.ThemeLayerVO;
	import com.br.eyesOnNigeria.DF.Data.ToolTipItem;
	import com.esri.ags.Graphic;
	import com.esri.ags.geometry.Extent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	[Bindable]
	public class Themes extends EventDispatcher
	{
		public var themes_list:ArrayCollection = new ArrayCollection();
		public var theme_markers:ArrayCollection = null;
		
		//TODO: Remove fieldNames when MainUI.mxml is retired
		public var fieldNames:Array = new Array();
		
		public function parseXML(_xml:XML):void {
			debug(".parseXML() -- _xml = " + _xml.toString());
			var aNodes:XMLList = _xml.children();
			var sNodeName:String;
			var aArray:Array = new Array();
			var theme:Object = {};
			var headingInfo:HeadingVO;
			var aThemeMarkers:Array = [];
			for (var i:int=0; i<aNodes.length(); i++) {
				sNodeName = aNodes[i].name();
				headingInfo = new HeadingVO();
				if (aNodes[i].@heading.toString() == "true")
					headingInfo.heading=true;
				else
					headingInfo.heading=false;
				headingInfo.label 			= aNodes[i].@label.toString(); 
				headingInfo.id    			= aNodes[i].@id.toString(); 
				headingInfo.location_image_url 	= aNodes[i].@location_image_url.toString();
				headingInfo.legendTitle 	= aNodes[i].@legendTitle.toString();
				headingInfo.toolTip			= aNodes[i].@toolTip.toString();
				if (!headingInfo.heading) {
					parseTheme(aNodes[i], headingInfo);
					aThemeMarkers.push( new Graphic(headingInfo.extent.center,null,headingInfo) );
				}
				aArray.push(headingInfo);				
			}
			themes_list = new ArrayCollection(aArray);
			theme_markers = new ArrayCollection(aThemeMarkers);
			//trace("Themes : " + ObjectUtil.toString(this));
		}

		private function parseTheme(_xml:XML, headingInfo:HeadingVO):void {
			var aNodes:XMLList = _xml.children();
			var bNode:XMLList;
			var sNodeName:String;
			var imageInfo:ImageLayerVO;
			var pointInfo:PointLayerVO;
			var themeInfo:ThemeLayerVO;
			var dynamicInfo:DynamicLayerVO;
			var i:int;
			for (var j:int=0; j<aNodes.length(); j++) {
				sNodeName = aNodes[j].name();
				switch (sNodeName) {
					case "image_layers":
						bNode = aNodes[j].children();
						for (i=0; i<bNode.length(); i++) {
							imageInfo = new ImageLayerVO();
							imageInfo.id 	= bNode[i].@id.toString();
							imageInfo.type 	= bNode[i].@type.toString();
							imageInfo.label = bNode[i].@label.toString();
							imageInfo.url = bNode[i].@url.toString();
							headingInfo.theme.addItem(imageInfo);
						}
						break;
					case "dynamic_layers":
						bNode = aNodes[j].children();
						for (i=0; i<bNode.length(); i++) {
							dynamicInfo = new DynamicLayerVO;
							dynamicInfo.id 		= bNode[i].@id.toString();
							dynamicInfo.type 	= bNode[i].@type.toString();
							dynamicInfo.label 	= bNode[i].@label.toString();
							dynamicInfo.url 	= bNode[i].@url.toString();
							dynamicInfo.layers  = bNode[i].@layers.toString().split(",");
							headingInfo.theme.addItem(dynamicInfo);
						}
						break;
					case "theme_layers":
						bNode = aNodes[j].children();
						themeInfo = parseThemes(bNode);
						headingInfo.theme.addItem(themeInfo);
						break;
					case "point_layers":
						bNode = aNodes[j].children();
						for (i=0; i<bNode.length(); i++) {
							pointInfo = new PointLayerVO();
							pointInfo.id		= bNode[i].@id;
							pointInfo.type		= bNode[i].@type;
							pointInfo.layer_id 	= bNode[i].@layer_id;
							pointInfo.url 	= bNode[i].@url;
							pointInfo.markers	= parseMarkers(bNode[i].legend);
							pointInfo.fields = [];
							if (bNode[i].@years.toString() != "") {
								pointInfo.years = bNode[i].@years.toString().split(",");
								pointInfo.fields = pointInfo.fields.concat(pointInfo.years);
								//trace(" :: years= " + pointInfo.years);
								//trace(" :: years count = " + pointInfo.years.length);
								//trace(" :: fields= " + pointInfo.fields);
							}
							for each (var m:MarkerVO in pointInfo.markers) {
								if (m.fieldname != "") {
									pointInfo.fields.push(m.fieldname);
									fieldNames.push(m.fieldname);
								}
							}
							if (pointInfo.type != "point") {
								pointInfo.tooltip_labelField = bNode[i].@tooltip_labelField.toString();
								pointInfo.tooltip_data = parseTooltips(XMLList(bNode[i]));
								for each (var t:ToolTipItem in pointInfo.tooltip_data) {
									if (t.fieldname != "") {
										pointInfo.fields.push(t.fieldname);
										fieldNames.push(t.fieldname);
									}
								}
								pointInfo.tags = parseTags(bNode[i]);
								//trace(" :: " + pointInfo.type + " layer: " + ObjectUtil.toString(pointInfo));
							}
							headingInfo.theme.addItem(pointInfo);
						}
						break;
					case "extent":
						headingInfo.extent = new Extent(aNodes[j].@xmin, aNodes[j].@ymin, aNodes[j].@xmax, aNodes[j].@ymax);
						break;
					case "description":
						headingInfo.description = aNodes[j];
						break;
					case "stats":
						headingInfo.stats = new ArrayCollection();
						var oStat:Object;
						bNode = aNodes[j].children();
						for (i=0; i<bNode.length(); i++) {
							oStat = new Object();
							oStat["label"] = bNode[i].@label.toString();
							oStat["value"] = bNode[i].@value.toString();
							headingInfo.stats.addItem(oStat);
						}
						break;
					
				}
			}
		}
		
		private function parseTags(_xml:XML):Array {
			var aArray:Array = new Array();
			var val:String;
			var xNode:XMLList = _xml.children();
			for (var i:int=0; i<xNode.length(); i++) {
				val = xNode[i].name().toString();
				if (val == "tag") {
					aArray.push( xNode[i].toString() );
				}
			}
			//trace(" :: tags = " + aArray.toString());
			return aArray;
		}

		private function parseMarkers(_xml:XMLList):ArrayCollection {
			var oMapMarker:MarkerVO;
			var acReturn:ArrayCollection;
			var aArray:Array = new Array();
			var val:String;
			var i:int=0;
			var xNode:XMLList = _xml.children();
			for (i=0; i<xNode.length(); i++) {
				val = xNode[i].name().toString();
				if (val == "marker") {
					oMapMarker = new MarkerVO();
					oMapMarker.color = Number(xNode[i].@color.toString());
					if (xNode[i].@alpha.toString().length >0)
						oMapMarker.alpha = Number(xNode[i].@alpha.toString());
					oMapMarker.outlinecolor = Number(xNode[i].@outlinecolor.toString());
					if (xNode[i].@outlinesize.toString()!= "") 
						oMapMarker.outlinesize = Number(xNode[i].@outlinesize.toString());
					oMapMarker.shape = xNode[i].@shape.toString();
					oMapMarker.label = xNode[i].@label.toString();
					oMapMarker.url = (xNode[i].@url.toString().length > 0) ? xNode[i].@url.toString():"";
					if (xNode[i].@size.toString() > 0) {
						oMapMarker.size   = Number(xNode[i].@size.toString());
						oMapMarker.height = Number(xNode[i].@size.toString());
						oMapMarker.width  = Number(xNode[i].@size.toString());
					}
					oMapMarker.fieldname = xNode[i].@fieldname.toString();
					oMapMarker.value = (xNode[i].@value.toString().length > 0) ? xNode[i].@value.toString():"";
					oMapMarker.valuemin = (xNode[i].@valuemin.toString().length > 0) ? Number(xNode[i].@valuemin.toString()):NaN;
					oMapMarker.valuemax = (xNode[i].@valuemax.toString().length > 0) ? Number(xNode[i].@valuemax.toString()):NaN;
					oMapMarker.format   = xNode[i].@format.toString();
					if (oMapMarker.format == "$")
						oMapMarker.format = ToolTipItem.FORMAT_DOLLARS;
					else if (oMapMarker.format == ",")
						oMapMarker.format = ToolTipItem.FORMAT_NUMBER;
					else if (oMapMarker.format == "%")
						oMapMarker.format = ToolTipItem.FORMAT_PERCENT;
					else if (oMapMarker.format == "www")
						oMapMarker.format = ToolTipItem.TYPE_URL;
					if (!isNaN(xNode[i].@precision.toString())) 
						oMapMarker.precision = int(xNode[i].@precision);
					aArray.push(oMapMarker);
				}
			}
			acReturn = new ArrayCollection(aArray);
			return acReturn;
		}

		private function parseThemes(_xml:XMLList):ThemeLayerVO {
			var tReturn:ThemeLayerVO = new ThemeLayerVO();
			for (var i:int=0; i<_xml.length(); i++) {
				tReturn.id			= _xml[i].@id;
				tReturn.type		= _xml[i].@type;
				tReturn.layer_id 	= _xml[i].@layer_id;
				tReturn.url 		= _xml[i].@url;
				tReturn.tooltip_labelField = _xml[i].@tooltip_labelField.toString();
				tReturn.markers = parseMarkers(_xml.legend);
				tReturn.tooltip_data = parseTooltips(_xml);
				tReturn.fields = [];
				for each (var m:MarkerVO in tReturn.markers) {
					if (m.fieldname != "") {
						tReturn.fields.push(m.fieldname);
						fieldNames.push(m.fieldname);
					}
				}
				for each (var t:ToolTipItem in tReturn.tooltip_data) {
					if (t.fieldname != "") {
						tReturn.fields.push(t.fieldname);
						fieldNames.push(t.fieldname);
					}
				}
			}
			return tReturn;
		}
		
		private function parseTooltips(_xml:XMLList):ArrayCollection {
			// parse the tooltip node
			var xNode:XMLList = _xml.children();
			var tooltip_labelField:String = _xml.@tooltip_labelField.toString();
			var aTooltips:Array = new Array();
			
			var i:int = 0;
			var val:String;
			var location:Number;
			
			var oToolTipItem:ToolTipItem;
			//heading
			oToolTipItem = new ToolTipItem();
			oToolTipItem.fieldname = tooltip_labelField;
			oToolTipItem.type = ToolTipItem.TYPE_TITLE;
			aTooltips.push(oToolTipItem);
			//items
			for (i=0; i<xNode.length(); i++) {
				val = xNode[i].name().toString();
				if(val == "tooltip_data") {
					oToolTipItem = new ToolTipItem();
					oToolTipItem.fieldname = xNode[i].@fieldname.toString();
					oToolTipItem.label = xNode[i].@label.toString();
					oToolTipItem.format = xNode[i].@format.toString();
					
					if (oToolTipItem.format == "$")
						oToolTipItem.format = ToolTipItem.FORMAT_DOLLARS;
					else if (oToolTipItem.format == ",")
						oToolTipItem.format = ToolTipItem.FORMAT_NUMBER;
					else if (oToolTipItem.format == "%")
						oToolTipItem.format = ToolTipItem.FORMAT_PERCENT;
					else if (oToolTipItem.format == "www")
						oToolTipItem.format = ToolTipItem.TYPE_URL;
					
					if (xNode[i].@divider.toString() == "true")
						oToolTipItem.type = ToolTipItem.TYPE_DIVIDER;
					else if (oToolTipItem.format == "LongText")
						oToolTipItem.type = ToolTipItem.TYPE_LONG_TEXT;
					else if (oToolTipItem.format == ToolTipItem.TYPE_URL)
						oToolTipItem.type = ToolTipItem.TYPE_URL;
					else if (xNode[i].@format.toString() == "title")
						oToolTipItem.type = ToolTipItem.TYPE_TITLE;
					else if (xNode[i].@format.toString().toLowerCase() == "image")
						oToolTipItem.type = ToolTipItem.TYPE_IMAGE;
					else
						oToolTipItem.type = ToolTipItem.TYPE_LABEL_VALUE_PAIR;
					
					if (!isNaN(xNode[i].@precision.toString())) 
						oToolTipItem.precision = int(xNode[i].@precision);
					
					aTooltips.push(oToolTipItem);
				}
			}
			//if (_xml.@type.toString() == "youtube")
				//trace(" :: tooltips: " + ObjectUtil.toString(aTooltips));
			return (aTooltips.length > 0) ? new ArrayCollection(aTooltips) : null;
			//trace(" :::::::: tooltip out fields: " + this.tooltip_outFields);
		}

		public function Themes()
		{
		}
		
		public static const instance:Themes = new Themes();
		
		private function debug(message:String):void {
			//trace("Themes" + message);
		}
	}
}