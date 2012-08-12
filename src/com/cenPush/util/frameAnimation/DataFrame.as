package com.cenPush.util.frameAnimation
{
	internal class DataFrame
	{
		internal var name:String;
		internal var sprites:Vector.<DataFrameSprite>;
		
		public function DataFrame(frame:XML)
		{
			name = frame.name;
			
			sprites = new Vector.<DataFrameSprite>();
			
			for each(var sprite:XML in frame.sprite)
			{
				sprites.push(new DataFrameSprite(sprite));
			}
		}
	}
}