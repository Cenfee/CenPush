package com.cenPush.util.frameAnimation
{
	internal class DataAnimationFrame
	{
		internal var name:String;
		internal var duration:Number;
		
		public function DataAnimationFrame(frame:XML)
		{
			name = frame.name;
			duration = frame.duration;
			duration /= 1000;
		}
	}
}