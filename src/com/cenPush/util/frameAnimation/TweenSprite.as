package com.cenPush.util.frameAnimation
{
	import flash.utils.Dictionary;
	
	import starling.animation.IAnimatable;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.textures.TextureAtlas;
	import com.cenPush.util.frameAnimation.DataCharacter;
	import com.cenPush.util.frameAnimation.DataFrame;
	import com.cenPush.util.frameAnimation.DataFrameSprite;
	import com.cenPush.util.frameAnimation.ImageBlock;
	import com.cenPush.util.frameAnimation.Tween;
	import com.cenPush.util.frameAnimation.TweenValue;

	public class TweenSprite extends Sprite implements IAnimatable
	{
		protected const DEG2RAD:Number = Math.PI / 180;
		
		protected var _character:DataCharacter;
		protected var _tween:Tween;
		
		protected var _textureAtlas:TextureAtlas;
		
		protected var _container:Sprite;
		protected var _imageBlocksCache:Dictionary;
		protected var _tweenCache:Dictionary;
		
		protected var _smooth:Boolean = true;
		protected var _propertiesChanged:Boolean = false;
		
		protected var _isPlaying:Boolean;
		protected var _isComplete:Boolean;
		protected var _isLoop:Boolean;
		
		public function TweenSprite(data:XML, textureAtlas:TextureAtlas)
		{
			_character = new DataCharacter(data, onCharacterChangeFrame, onAnimationComplete);
			
			_textureAtlas = textureAtlas;
			
			_container = new Sprite();
			addChild(_container);
			
			_imageBlocksCache = new Dictionary();
			_tweenCache = new Dictionary();
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
				_tween.advanceTime(delta);
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
		
		private function getTween(name:String, targets:Vector.<Object>, startValues:Vector.<TweenValue>, endValues:Vector.<TweenValue>, time:Number):Tween
		{
			var tween:Tween = new Tween(targets, startValues, endValues, time);
			_tweenCache[name] = tween;
			return tween;
		}
		
		private function getTweenValue(sprite:DataFrameSprite):TweenValue
		{
			var tweenValue:TweenValue = new TweenValue();
			tweenValue.x = sprite.tx;
			tweenValue.y = sprite.ty;
			tweenValue.color = sprite.color;
			tweenValue.alpha = sprite.alpha;
			tweenValue.rotation = Math.acos(sprite.a);
			tweenValue.scaleX = sprite.a;
			tweenValue.scaleY = sprite.d;
			tweenValue.skewX = Math.atan(sprite.c);
			tweenValue.skewY = Math.atan(sprite.b);
			return tweenValue;
		}
		
		private function onCharacterChangeFrame():void
		{
			var frame:DataFrame = _character.frame;
			var nextFrame:DataFrame = _character.nextFrame;
				
			if(!nextFrame) nextFrame = frame;
			
			_tween = _tweenCache[frame.name];
			
			if(!_tween)
			{
				var targets:Vector.<Object> = new Vector.<Object>();
				var startValues:Vector.<TweenValue> = new Vector.<TweenValue>();
				var endValues:Vector.<TweenValue> = new Vector.<TweenValue>();
				var time:Number = _character.animation.frame.duration;
				
				var sprites:Vector.<DataFrameSprite> = frame.sprites;
				var nextSprites:Vector.<DataFrameSprite> = nextFrame.sprites;
				
				for(var i:int = 0; i < sprites.length; i++)
				{
					var sprite:DataFrameSprite = sprites[i];
					var nextSprite:DataFrameSprite = nextSprites[i];
					
					var imageBlock:ImageBlock = _imageBlocksCache[sprite.image];
					if(!imageBlock)
					{
						imageBlock = getImageBlock(sprite.image, sprite.offsetX, sprite.offsetY);
						imageBlock.smoothing = _smooth ? "bilinear" : "none";
						_container.addChild(imageBlock);
					}
					
					targets.push(imageBlock);
					startValues.push(getTweenValue(sprite));
					endValues.push(getTweenValue(nextSprite));
					
				}
				
				_tween = getTween(frame.name, targets, startValues, endValues, time);
			}
			
			_tween.resetProperties();
			
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