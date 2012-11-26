package com.br.eyesOnNigeria.DF.events
{
	import flash.events.Event;
	
	import com.br.eyesOnNigeria.UI.tooltip.ToolTip;
	
	import mx.collections.ArrayCollection;

	public class ToolTipEvent extends Event
	{		
		public static const SHOW_TOOLTIP:String = "showTooltip";
		public static const HIDE_TOOLTIP:String = "hideTooltip";
		
		public static const LOCK_TOOLTIP:String = "lockTooltip";
		public static const UNLOCK_TOOLTIP:String = "unlockTooltip";
		
		public static const CLOSE:String = "tooltipClose";
		public static const ROLL_OUT:String = "tooltipRollOut";
		
		public var position:String = "";
		
		public var data:Object = {};
		public var config:ArrayCollection = new ArrayCollection();
		public var lock:Boolean = false;
		
		public function ToolTipEvent(type:String, data:Object = null, config:ArrayCollection = null, position:String = "", lock:Boolean = false)
		{
			this.position = position == "" ? ToolTip.POSITION_TOP_LEFT : position;
			this.data = data;
			this.config = config;
			this.lock = lock;
			
			super(type);
		}
		
		// CLONE =============================================================================================
		override public function clone():Event {
			return new ToolTipEvent(type, this.data, this.config, this.position, this.lock);
		}
		
		// getters ===========================================================================================

	}
}