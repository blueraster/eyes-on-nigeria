package com.br.eyesOnNigeria.DF.models
{
	import com.br.eyesOnNigeria.DF.events.ToolTipEvent;
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;


	[Bindable]
	public dynamic class GlobalSharedObject extends EventDispatcher
	{
		public var bDataGridVisible:Boolean = false;//ds 12/12

		public function GlobalSharedObject()
		{
		}
				
		public function showTooltip(position:String, data:Object, config:ArrayCollection, lock:Boolean = false):void {
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.SHOW_TOOLTIP, data, config, position, lock));
		}
		public function hideTooltip():void {
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.HIDE_TOOLTIP));
		}
		public function lockTooltip():void {
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.LOCK_TOOLTIP));
		}
		public function unlockTooltip():void {
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.UNLOCK_TOOLTIP));
		}
		public function rollOutTooltip():void {
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.ROLL_OUT));
		}
		public function tooltipClose():void {
			this.dispatchEvent(new ToolTipEvent(ToolTipEvent.CLOSE))
		}
	}
}