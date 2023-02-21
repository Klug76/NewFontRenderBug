package com.gs.ui
{
	import flash.events.IEventDispatcher;
	
	public class TEventListener
	{
		public var type_: String;
		public var callback_: Function;
		public var target_: IEventDispatcher;
		public var phase0_: Boolean = false;
		
		public function TEventListener(type: String, listener: Function,
			target: IEventDispatcher = null, phase0: Boolean = false)
		{
			type_ = type;
			callback_ = listener;
			target_ = target;
			phase0_ = phase0;
		}
		
	}

}