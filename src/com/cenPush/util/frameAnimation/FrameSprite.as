package com.cenPush.util.frameAnimation
{
	import flash.utils.Dictionary;
	
	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;

	public class FrameSprite extends Sprite implements IAnimatable
	{
		protected const DEG2RAD:Number = Math.PI / 180;
		
		protected var _character:DataCharacter;
		
		protected var _textureAtlas:TextureAtlas;
		
		protected var _container:Sprite;
		protected var _imageBlocksCache:Dictionary;
		
		protected var _smooth:Boolean = true;
		protected var _propertiesChanged:Boolean = false;
		
		protected var _isPlaying:Boolean;
		protected var _isComplete:Boolean;
		protected var _isLoop:Boolean;
		
		public function FrameSprite(data:XML, textureAtlas:TextureAtlas)
		{
			_character = new DataCharacter(data, onCharacterChangeFrame, onAnimationComplete);
			
			_textureAtlas = textureAtlas;
			
			_container = new Sprite();
			addChild(_container);
			
			_imageBlocksCache = new Dictionary();
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			_character = null;
		}
		public function advanceTime(delta:Number):void
		{
			if(_isPlaying)
			{
				_character.update(delta);
			}
			if (_propertiesChanged)
			{
				onCharacterChangeFrame();
				_propertiesChanged = false;
			}
		
		}
		
		private function getImageBlock(name:String, offsetX:Number, offsetY:Number):ImageBlock
		{
			var imageBlock:ImageBlock = new ImageBlock(_textureAtlas.getTexture(name), offsetX, offsetY);
			_imageBlocksCache[name] = imageBlock;
			return imageBlock;
		}
		
		private function onCharacterChangeFrame():void
		{
			_container.removeChildren();
			_container.unflatten();
			
			var sprites:Vector.<DataFrameSprite> = _character.frame.sprites;
			
			for(var i:int = 0; i < sprites.length; i++)
			{
				var sprite:DataFrameSprite = sprites[i];
				var imageBlock:ImageBlock = _imageBlocksCache[sprite.image];
				
				if(!imageBlock)
					imageBlock = getImageBlock(sprite.image, sprite.offsetX, sprite.offsetY);
				
				_container.addChild(imageBlock);
				
				imageBlock.transformationMatrix.a = sprite.a;
				imageBlock.transformationMatrix.b = sprite.b;
				imageBlock.transformationMatrix.c = sprite.c;
				imageBlock.transformationMatrix.d = sprite.d;
				imageBlock.transformationMatrix.tx = sprite.tx;
				imageBlock.transformationMatrix.ty = sprite.ty;
				imageBlock.color = sprite.color;
				imageBlock.alpha = sprite.alpha;
				
				imageBlock.smoothing = _smooth ? "bilinear" : "none";
			}
			
			_container.flatten();
		}
		
		private function onAnimationComplete():void
		{
			if(!_isLoop)
				pause();
			_isComplete = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function play(name:String, reset:Boolean = false, frame:int = 0):void
		{
			_character.play(name, reset, frame);
			_isPlaying = true;
			_isComplete = false;
		}
		public function pause():void
		{
			_isPlaying = false;
		}
		public function stop():void
		{
			_isPlaying = false;
			_character.resetFrame();
		}
		
		public function clearCache():void
		{
			_imageBlocksCache = new Dictionary();
		}
		
		public function get smooth():Boolean
		{
			return _smooth;
		}
		public function set smooth(value:Boolean):void
		{
			_propertiesChanged = true;
			_smooth = value;
		}
		
		public function get currentFrame():int
		{
			return _character.animation.frameIndex;
		}
		public function set currentFrame(value:int):void
		{
			if(_character.animation)
				_character.animation.reset(value);
			
			_propertiesChanged = true;
		}
		public function get currentAnimation():String
		{
			return _character.animation.name;
		}
		public function get isPlaying():Boolean
		{
			return _isPlaying;
		}
		public function get isComplete():Boolean
		{
			return _isComplete;
		}
		public function get isLoop():Boolean
		{
			return _isLoop;
		}
		public function set isLoop(value:Boolean):void
		{
			_isLoop = value;
		}
		
	}
}