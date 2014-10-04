package events
{
	    import flash.events.Event;
	   
	    public class CommEvent extends Event
	    {
		//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------
		 
		       
		       
		//- PUBLIC & INTERNAL VARIABLES ---------------------------------------------------------------------------
		       		       
		        // event constants
		        public static const ON_UPDATED_CASE:String = "onUpdatedCase";
		        public static const ON_LISTENED_CASE:String = "onListenedCase";

				public var sendTime:int;
				public var receiveTime:int;
				public var appName:String;
				public var caseName:String;
		        public var caseValue:*;
		       
		//- CONSTRUCTOR -------------------------------------------------------------------------------------------
		   
		        public function CommEvent($type:String, $appname:String, $casename:String, $casevalue:*, $sendtime:int, $receivetime:int, $bubbles:Boolean = true, $cancelable:Boolean = false)
		        {
			            super($type, $bubbles, $cancelable);
			            this.caseValue = $casevalue;
						this.caseName = $casename;
						this.appName = $appname;
						this.sendTime = $sendtime;
						this.receiveTime = $receivetime;
		        } 
		   
		//- HELPERS -----------------------------------------------------------------------------------------------
		   
		        public override function clone():Event
		        {
			            return new CommEvent(type, this.appName, this.caseName, this.caseValue, this.sendTime, this.receiveTime, bubbles, cancelable);
		        }
		       
		        public override function toString():String
		        {
			            return formatToString("SocketEvent", "appname", "casename", "casevalue", "sendtime", "receivetime", "bubbles", "cancelable");
		        }
		   
		//- END CLASS ---------------------------------------------------------------------------------------------
	    }
}