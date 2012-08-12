package com.cenPush.engine.debug 
{
	/**
	 * ...
	 * @author Cenfee
	 */
	public class Logger 
	{
		
		public function Logger() 
		{
			
		}
		
		static public function warn(reporter:*, method:String, message:String):void
		{
			trace("warn", method, message);
		}
		
		static public function error(reporter:*, method:String, message:String):void
		{
			trace("error", method, message);
		}
		
		static public function print(reporter:*, message:String):void
		{
			trace("error", message);
		}
		
	}

}