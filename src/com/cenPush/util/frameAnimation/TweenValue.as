package com.cenPush.util.frameAnimation
{
	public class TweenValue
	{
		internal var x:Number;
		internal var y:Number;
		
		internal var rotation:Number;
		
		internal var scaleX:Number;
		internal var scaleY:Number;
		
		internal var skewX:Number;
		internal var skewY:Number;
		
		internal var color:Number;
		internal var alpha:Number;
		
		public function TweenValue(x:Number = 0, y:Number = 0, rotation:Number = 0, scaleX:Number = 0, scaleY:Number = 0, skewX:Number = 0, skewY:Number = 0, color:Number = 0, alpha:Number = 0)
		{
			this.x = x;
			this.y = y;
			this.rotation = rotation;
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.skewX = skewX;
			this.skewY = skewY;
			this.color = color;
			this.alpha = alpha;
		}
	}
}