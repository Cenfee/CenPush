package com.cenPush.util.frameAnimation
{
	public class DataFrameSprite
	{
		internal var image:String;
		internal var a:Number;
		internal var b:Number;
		internal var c:Number;
		internal var d:Number;
		internal var tx:Number;
		internal var ty:Number;
		internal var color:uint;
		internal var alpha:Number;
		internal var offsetX:Number;
		internal var offsetY:Number;
		
		public function DataFrameSprite(sprite:XML)
		{
			image = sprite.image;
			
			a = sprite.a;
			b = sprite.b;
			c = sprite.c;
			d = sprite.d;
			tx = sprite.tx;
			ty = sprite.ty;
			
			color = sprite.color;
			alpha = sprite.alpha;
			
			offsetX = sprite.offsetX;
			offsetY = sprite.offsetY;
		}
	}
}