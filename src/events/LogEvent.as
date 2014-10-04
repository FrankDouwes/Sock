package events
{
	import flash.events.Event;
	   
	    public class LogEvent extends Event
	    {
		//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------
		       
		//- PUBLIC & INTERNAL VARIABLES ---------------------------------------------------------------------------
		       		       
		// event constants
		public static const ON_LOG:String = "onLog";
		
		public var lMessage:String;
		public var lFormat:String;
		public var lType:String;
		       
		//- CONSTRUCTOR -------------------------------------------------------------------------------------------
		   
		public function LogEvent($type:String, $lMessage:String, $lFormat:String, $lType:String, $bubbles:Boolean = true, $cancelable:Boolean = false)
		{
			super($type, $bubbles, $cancelable);
			this.lMessage = $lMessage;
			this.lFormat = $lFormat;
			this.lType = $lType;
		} 
		   
		//- HELPERS -----------------------------------------------------------------------------------------------
		   
		        public override function clone():Event
		        {
			            return new LogEvent(type, this.lMessage, this.lFormat, this.lType, bubbles, cancelable);
		        }
		       
		        public override function toString():String
		        {
			            return formatToString("LogEvent", "message", "format", "type", "bubbles", "cancelable");
		        }
		   
		//- END CLASS ---------------------------------------------------------------------------------------------
	    }
}