package com.br.eyesOnNigeria.DF.Data
{	
	[Bindable]
	public class ToolTipItem
	{
		/*
		- type (will be used to determine display)
		- fieldname (will be used to get data from data object)
		- label (used for label-value pair)
		- format (used to format the value)
		- precision (used to format the value)
		- multiplier (used for adjust the value before formatting, like for percent multiplying provided value by 100 - has to be configurable because we don't know what is being provided)
		
		Static Constants:
		- TYPE_TITLE
		- TYPE_LABEL_VALUE_PAIR
		- TYPE_LONG_TEXT
		- TYPE_URL
		- TYPE_EMAIL
		- TYPE_DIVIDER
		- FORMAT_NUMBER (format with commas)
		- FORMAT_PERCENT (put % after)
		- FORMAT_DOLLARS (put $ in front and use commas. use 2 digit decimal IF precision is set for that, otherwise no decimal) 
		*/
		
		public static const TYPE_GROUP:String = "typeHeaderText";
		public static const TYPE_TITLE:String = "typeTitle";
		public static const TYPE_LABEL_VALUE_PAIR:String = "typeLabelValuePair";
		public static const TYPE_LONG_TEXT:String = "typeLongText";
		public static const TYPE_IMAGE:String = "typeImage";
		public static const TYPE_URL:String = "typeURL";
		public static const TYPE_EMAIL:String = "typeEmail";
		public static const TYPE_DIVIDER:String = "typeDivider";
		
		public static const FORMAT_NUMBER:String = "formatNumber";
		public static const FORMAT_PERCENT:String = "formatPercent";
		public static const FORMAT_DOLLARS:String = "formatDollars";
						
		public var type:String = "";
		public var fieldname:String = "";
		public var label:String = "";
		public var format:String = "";
		public var precision:Number = -1;
		public var multiplier:Number = 1;		
				
		public function ToolTipItem()
		{
		}
	}
}