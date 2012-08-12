package com.cenPush.util.frameAnimation
{
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;

	internal class ImageBlock extends Sprite
	{
		private var _image:Image;
		
		public function ImageBlock(texture:Texture, offsetX:Number, offsetY:Number)
		{
			_image = new Image(texture);
			_image.x = offsetX;
			_image.y = offsetY;
			addChild(_image);
		}
		
		public function get color():uint{ return _image.color; }
		public function set color(value:uint):void{ _image.color = value; }
		
		public function get smoothing():String{ return _image.smoothing; }
		public function set smoothing(value:String):void{ _image.smoothing = value; }
	}
}