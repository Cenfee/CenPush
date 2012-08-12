package com.cenPush.engine 
{
	/**
	 * ...
	 * @author Cenfee
	 */
	public class CPEUtil 
	{
		
		public function CPEUtil() 
		{
			
		}
		
		public static function clamp(v:Number, min:Number = 0, max:Number = 1):Number
        {
            if(v < min) return min;
            if(v > max) return max;
            return v;
        }
		
		public static function getFileExtension(file:String):String
		{
			var extensionIndex:Number = file.lastIndexOf(".");
			if (extensionIndex == -1) {
				return "";
			} else {
				return file.substr(extensionIndex + 1,file.length);
			}
		}
		
	}

}